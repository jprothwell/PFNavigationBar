//
//  PFNavigationBar.h
//
//  Created by David Charlec on 06/11/11.
//  Copyright (c) 2011 Pulpfingers. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LEFT_MARGIN 5.0f;
#define RIGHT_MARGIN 5.0f;
#define TITLE_PADDING 6.0f;


typedef enum {
    PFNavigationBarButtonTypeLeft,
    PFNavigationBarButtonTypeRight,
    PFNavigationBarButtonTypeBack
} PFNavigationBarButtonType;

@protocol PFNavigationBarDelegate;

@interface PFNavigationBar : UIView {
        
    CGFloat height;
    UIViewController *viewController;
    UIButton *leftButton;
    UIButton *rightButton;
    UIButton *backButton;
    
    BOOL autoAdjustButtonWidth;
    BOOL autoUpdateBackButtonLabel;

}

@property (assign) id<PFNavigationBarDelegate> delegate;
@property (nonatomic, retain) UILabel *titleLabel;

- (id)initWithViewController:(UIViewController*)controller;
- (void)setButton:(UIButton*)button forType:(PFNavigationBarButtonType)type;
- (void)setBackgroundImage:(UIImage *)backgroundImage;
- (void)setHeight:(CGFloat)height;
- (void)setAutoAdjustButtonWidth:(BOOL)autoAdjust;
- (void)setAutoUpdateBackButtonLabel:(BOOL)autoAdjust;

@end

/**** DELEGATE PROTOCOL ****/

@protocol PFNavigationBarDelegate <NSObject>
@optional
- (void)buttonWasTouched:(UIButton*)button withType:(PFNavigationBarButtonType)buttonType;
@end
