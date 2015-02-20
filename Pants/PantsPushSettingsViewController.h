//
//  PantsPushSettingsViewController.h
//  Pants
//
//  Created by Dylan Moore on 2/16/15.
//  Copyright (c) 2015 Dylan Moore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PantsInsetLabel.h"
#import "LetterTileButton.h"

@interface PantsPushSettingsViewController : UIViewController

@property (nonatomic, strong) IBOutlet LetterTileButton *setTimeButton;
@property (nonatomic, strong) IBOutlet UIButton *denyButton;
@property (nonatomic, strong) IBOutlet PantsInsetLabel *topLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
