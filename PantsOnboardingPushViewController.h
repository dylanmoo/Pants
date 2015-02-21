//
//  PantsOnboardingPushViewController.h
//  Pants
//
//  Created by Dylan Moore on 2/19/15.
//  Copyright (c) 2015 Dylan Moore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LetterTileButton.h"
#import "PantsInsetLabel.h"

@protocol PantsOnboardingPushDelegate <NSObject>

- (void)pushNotificationsAccepted:(BOOL)accepted;

@end

@interface PantsOnboardingPushViewController : UIViewController <UIAlertViewDelegate>

@property (nonatomic, weak) NSObject<PantsOnboardingPushDelegate> *delegate;
@property (weak, nonatomic) IBOutlet PantsInsetLabel *titleLabel;
@property (weak, nonatomic) IBOutlet PantsInsetLabel *mainLabel;
@property (weak, nonatomic) IBOutlet PantsInsetLabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet LetterTileButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
