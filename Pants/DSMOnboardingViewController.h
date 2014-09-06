//
//  DSMOnboardingViewController.h
//  Pants
//
//  Created by Dylan Moore on 9/1/14.
//  Copyright (c) 2014 Dylan Moore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSMInsetLabel.h"
#import "LetterTileButton.h"

typedef void(^actionBlock)(UIButton *actionButton);

@interface DSMOnboardingViewController : UIViewController

@property (nonatomic, strong) LetterTileButton *acceptButton;
@property (nonatomic, strong) UIButton *denyButton;
@property (nonatomic, strong) DSMInsetLabel *titleLabel;
@property (nonatomic, strong) DSMInsetLabel *subtitleLabel;

@property (nonatomic, strong) actionBlock acceptButtonBlock;
@property (nonatomic, strong) actionBlock denyButtonBlock;


@end
