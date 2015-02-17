//
//  PantsPushSettingsViewController.m
//  Pants
//
//  Created by Dylan Moore on 2/16/15.
//  Copyright (c) 2015 Dylan Moore. All rights reserved.
//

#import "PantsPushSettingsViewController.h"

@interface PantsPushSettingsViewController ()

@end

@implementation PantsPushSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.topLabel setFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:32]];
    [self.topLabel setTextColor:DEFAULT_RED_COLOR];
    [self.topLabel setTextAlignment:NSTextAlignmentLeft];
    [self.topLabel setNumberOfLines:0];
    
    [self.bottomLabel setFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:32]];
    [self.bottomLabel setTextColor:DEFAULT_RED_COLOR];
    [self.bottomLabel setTextAlignment:NSTextAlignmentLeft];
    [self.bottomLabel setNumberOfLines:0];
    
    [self.setTimeButton setTitleFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:72]];
    [self.setTimeButton setTitleColor:DEFAULT_YELLOW_COLOR forState:UIControlStateSelected];
    [self.setTimeButton setTitleColor:DEFAULT_RED_COLOR forState:UIControlStateNormal];
    [self.setTimeButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.setTimeButton setUserInteractionEnabled:YES];
    [self.setTimeButton setContentEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
    [self.setTimeButton setTitle:@"8 A.M.?" forState:UIControlStateNormal];
    
    self.setTimeButton.layer.cornerRadius = 7;
    self.setTimeButton.layer.borderColor = DEFAULT_RED_COLOR.CGColor;
    self.setTimeButton.layer.borderWidth = 2;
    
    [self.denyButton setTitleColor:DEFAULT_RED_COLOR forState:UIControlStateNormal];
    [self.denyButton.titleLabel setFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:18]];
    [self.denyButton.titleLabel setTextAlignment:NSTextAlignmentCenter];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)setTimeButtonPressed:(id)sender {
    //Show time picker
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
