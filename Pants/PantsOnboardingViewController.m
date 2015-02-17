//
//  DSMOnboardingViewController.m
//  Pants
//
//  Created by Dylan Moore on 9/1/14.
//  Copyright (c) 2014 Dylan Moore. All rights reserved.
//

#import "PantsOnboardingViewController.h"

@interface PantsOnboardingViewController ()


@end

@implementation PantsOnboardingViewController

- (id)init
{
    self = [super init];
    if (self){
        
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:DEFAULT_YELLOW_COLOR];
    
    [self.titleLabel setFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:72]];
    [self.titleLabel setTextColor:DEFAULT_RED_COLOR];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self.subtitleLabel setFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:32]];
    [self.subtitleLabel setTextColor:DEFAULT_RED_COLOR];
    [self.subtitleLabel setTextAlignment:NSTextAlignmentLeft];
    [self.subtitleLabel setNumberOfLines:0];
    
    [self.acceptButton setTitleFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:72]];
    [self.acceptButton setTitleColor:DEFAULT_YELLOW_COLOR forState:UIControlStateSelected];
    [self.acceptButton setTitleColor:DEFAULT_RED_COLOR forState:UIControlStateNormal];
    [self.acceptButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.acceptButton setUserInteractionEnabled:YES];
    [self.acceptButton setContentEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
    
    self.acceptButton.layer.cornerRadius = 7;
    self.acceptButton.layer.borderColor = DEFAULT_RED_COLOR.CGColor;
    self.acceptButton.layer.borderWidth = 2;
    
    [self.denyButton setTitleColor:DEFAULT_RED_COLOR forState:UIControlStateNormal];
    [self.denyButton.titleLabel setFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:18]];
    [self.denyButton.titleLabel setTextAlignment:NSTextAlignmentCenter];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)acceptButtonPressed:(id)sender {
    self.acceptButtonBlock(self.acceptButton);
}
- (IBAction)denyButtonPressed:(id)sender {
    self.denyButtonBlock(self.denyButton);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
