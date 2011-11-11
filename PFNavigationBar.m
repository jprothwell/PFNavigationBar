//
//  PFNavigationBar.m
//
//  Created by David Charlec on 06/11/11.
//  Copyright (c) 2011 Pulpfingers. All rights reserved.
//

#import "PFNavigationBar.h"

@interface PFNavigationBar (Private)
- (CGFloat)buttonWidth:(UIButton *)button;
- (void)leftButtonAction;
- (void)rightButtonAction;
- (void)backButtonAction;
@end

@implementation PFNavigationBar

@synthesize delegate;
@synthesize titleLabel;


- (id)initWithViewController:(UIViewController*)controller {
    self = [super initWithFrame:CGRectMake(0, 0, 320, 44)];
    if (self) {
        viewController = [controller retain];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        UILabel *label = [[UILabel alloc] initWithFrame:self.frame];
        label.font = [UIFont boldSystemFontOfSize:12.0];
        label.textColor = [UIColor whiteColor];
        label.shadowColor = [UIColor blackColor];
        label.shadowOffset = CGSizeMake(0, 1);
        [label setBackgroundColor:[UIColor clearColor]];
        self.titleLabel = label;
        [label release];
        
        [self addSubview:self.titleLabel];

        height = 44.0;
        autoAdjustButtonWidth = NO;
        autoUpdateBackButtonLabel = YES;
        [viewController.view insertSubview:self atIndex:999];
    }
    
    return self;
}

- (void)setAutoAdjustButtonWidth:(BOOL)autoAdjust {
    autoAdjustButtonWidth = autoAdjust;
}

- (void)setAutoUpdateBackButtonLabel:(BOOL)autoAdjust {
    autoUpdateBackButtonLabel = autoAdjust;
}

- (void)setHeight:(CGFloat)navBarHeight {
    height = navBarHeight;
    [self setNeedsDisplay];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.frame];
    [backgroundImageView setImage:backgroundImage];
    [backgroundImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self insertSubview:backgroundImageView atIndex:0];
    [backgroundImageView release];
}

- (void)setButton:(UIButton*)button forType:(PFNavigationBarButtonType)type {
    if (type == PFNavigationBarButtonTypeLeft)  {
        leftButton = [button retain];
        [leftButton addTarget:self action:@selector(leftButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (type == PFNavigationBarButtonTypeRight) {
        rightButton = [button retain];
        [rightButton addTarget:self action:@selector(rightButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (type == PFNavigationBarButtonTypeBack)  {
        backButton = [button retain];
    }
    
    [self setNeedsDisplay];
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if(!hidden) {
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect {
    
    CGFloat screenHeight;
    
    if(UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        screenHeight = 320;
    } else {
        screenHeight = 480;
    }
    
    BOOL isStatusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
    
    if(!isStatusBarHidden) {
        screenHeight -= 20;
    }
    
    CGRect newFrame = viewController.view.frame;
    newFrame.size.height = height;       
    newFrame.origin.y = viewController.view.frame.size.height - screenHeight;

    [self setFrame:newFrame];
            
    if(!leftButton && backButton) {
        // Check if there's a need for a back button

        NSArray *viewControllers = viewController.navigationController.viewControllers;
        NSInteger viewControllersCount = [viewControllers count];
        NSLog(@"Check if there's a need for a back button => %i", viewControllersCount);        
        if(viewControllersCount > 1) {
            leftButton = backButton;
            if(autoUpdateBackButtonLabel) {                

                UIViewController *previousViewController = [viewControllers objectAtIndex:viewControllersCount - 2];
                
                NSString *previousTitle = previousViewController.title;
                
                if(previousTitle) {
                    if(previousTitle.length == 0) {
                        previousTitle = NSLocalizedString(@"Back", nil);
                    }
                }  else {
                    previousTitle = NSLocalizedString(@"Back", nil);
                } 
                
                [leftButton setTitle:previousTitle forState:UIControlStateNormal];
            }
            [leftButton addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
            
        }
    }    

    if(leftButton)  [self insertSubview:leftButton aboveSubview:titleLabel];
    if(rightButton) [self insertSubview:rightButton aboveSubview:titleLabel];
    
    CGFloat leftButtonWidth = [self buttonWidth:leftButton];
    CGFloat rightButtonWidth = [self buttonWidth:rightButton];
    
    if(rightButton && leftButton) {
        titleLabel.textAlignment = UITextAlignmentCenter;
        [titleLabel setHidden:YES];
    } else {
        [titleLabel setHidden:NO];
        if(!rightButton && !leftButton) {
            titleLabel.textAlignment = UITextAlignmentCenter;
        } else {
            if(!leftButton) {          
                titleLabel.textAlignment = UITextAlignmentLeft;
            } else {
                titleLabel.textAlignment = UITextAlignmentRight;
            }
        }
    }
    
    // set the x value for the right button
    CGFloat totalWidth = self.frame.size.width;

    newFrame = leftButton.frame;
    newFrame.origin.x = LEFT_MARGIN;
    [leftButton setFrame:newFrame];
    
    newFrame = rightButton.frame;
    newFrame.origin.x = totalWidth - rightButtonWidth - RIGHT_MARGIN;
    [rightButton setFrame:newFrame];
    
    newFrame = titleLabel.frame;
    newFrame.origin.x = leftButtonWidth + LEFT_MARGIN;
    if(leftButtonWidth > 0) newFrame.origin.x += TITLE_PADDING;
    CGFloat margin = TITLE_PADDING;
    newFrame.size.width = totalWidth - (margin * 2) - leftButtonWidth - rightButtonWidth;
    newFrame.size.width -= LEFT_MARGIN;
    newFrame.size.width -= RIGHT_MARGIN;
    newFrame.size.height = self.frame.size.height;
    
    [titleLabel setFrame:newFrame];
    titleLabel.text = viewController.title;
    
}

- (CGFloat)buttonWidth:(UIButton *)button {
    
    if(!button) return 0.0;
    
    if(autoAdjustButtonWidth) {
    
        CGSize size = [button.titleLabel.text sizeWithFont:button.titleLabel.font constrainedToSize:CGSizeMake(125, MAXFLOAT) lineBreakMode:UILineBreakModeTailTruncation];
        
        CGRect newFrame = button.frame;
        newFrame.size.width = size.width + 25;
        [button setFrame:newFrame];
        return newFrame.size.width;
        
    } else {        
        return button.frame.size.width;
    }
}

#pragma mark -
#pragma mark button actions

- (void)leftButtonAction {
    if([self.delegate respondsToSelector:@selector(buttonWasTouched:withType:)]) {
        [self.delegate buttonWasTouched:leftButton withType:PFNavigationBarButtonTypeLeft];
    }
}

- (void)backButtonAction {
    [viewController.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonAction {
    if([self.delegate respondsToSelector:@selector(buttonWasTouched:withType:)]) {
        [self.delegate buttonWasTouched:rightButton withType:PFNavigationBarButtonTypeRight];
    }
}

- (void)dealloc {
    [rightButton release];
    [leftButton release];
    [titleLabel release];
    [super dealloc];
}
@end
