//
//  DSMOnboardingViewController.h
//  Pants
//
//  Created by Dylan Moore on 9/1/14.
//  Copyright (c) 2014 Dylan Moore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PantsInsetLabel.h"
#import "LetterTileButton.h"
#import "PantsOnboardingPushViewController.h"

typedef void(^actionBlock)(UIButton *actionButton);

@protocol PantsOnboardingDelegate <NSObject>

- (void)finishedOnboarding;

@end

@interface PantsOnboardingViewController : UIViewController <PantsOnboardingPushDelegate>

@property (nonatomic, strong) IBOutlet LetterTileButton *acceptButton;
@property (nonatomic, strong) IBOutlet UIButton *denyButton;
@property (nonatomic, strong) IBOutlet PantsInsetLabel *titleLabel;
@property (nonatomic, strong) IBOutlet PantsInsetLabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) actionBlock acceptButtonBlock;
@property (nonatomic, strong) actionBlock denyButtonBlock;

@property (nonatomic, weak) NSObject<PantsOnboardingDelegate> *delegate;


@end
