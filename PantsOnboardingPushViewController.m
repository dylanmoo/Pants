//
//  PantsOnboardingPushViewController.m
//  Pants
//
//  Created by Dylan Moore on 2/19/15.
//  Copyright (c) 2015 Dylan Moore. All rights reserved.
//

#import "PantsOnboardingPushViewController.h"
#import "PantsStore.h"

@interface PantsOnboardingPushViewController ()

@end

@implementation PantsOnboardingPushViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = DEFAULT_YELLOW_COLOR;
    
    self.mainLabel.textColor = DEFAULT_RED_COLOR;
    self.subtitleLabel.textColor = DEFAULT_RED_COLOR;
    
    [self.mainLabel setFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:32]];
    [self.subtitleLabel setFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:20]];
    
    [self.acceptButton setTitleFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:60]];
    [self.acceptButton setTitleColor:DEFAULT_YELLOW_COLOR forState:UIControlStateSelected];
    [self.acceptButton setTitleColor:DEFAULT_RED_COLOR forState:UIControlStateNormal];
    [self.acceptButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.acceptButton setUserInteractionEnabled:YES];
    [self.acceptButton setContentEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
    
    self.acceptButton.layer.cornerRadius = 7;
    self.acceptButton.layer.borderColor = DEFAULT_RED_COLOR.CGColor;
    self.acceptButton.layer.borderWidth = 2;
    
    [self.skipButton setTitleColor:DEFAULT_RED_COLOR forState:UIControlStateNormal];
    [self.skipButton.titleLabel setFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:18]];
    [self.skipButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self.skipButton setTitle:@"Skip" forState:UIControlStateNormal];
    
    [self.acceptButton setTitle:@"Yes Please!" forState:UIControlStateNormal];
    
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceTokenSaved) name:kNotificationDeviceTokenSaved object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceTokenNotSaved) name:kNotificationDeviceTokenCouldNotBeSaved object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)skipButtonPressed:(id)sender {
    if([self.delegate respondsToSelector:@selector(pushNotificationsAccepted:)]){
        [self.delegate pushNotificationsAccepted:NO];
    }
}

- (IBAction)acceptPressed:(id)sender {
    UIAlertView *preAlert = [[UIAlertView alloc] initWithTitle:@"Let Pants Send You Push Notifications?" message:@"This will allow you to see the day's forecast without having to open up the app"  delegate:self cancelButtonTitle:@"Not Now" otherButtonTitles:@"Send Them", nil];
    [preAlert show];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(buttonIndex==0)
    {
        //Canceled
        if([self.delegate respondsToSelector:@selector(pushNotificationsAccepted:)]){
            [self.delegate pushNotificationsAccepted:NO];
        }
    }else{
        //Accepted
        [[PantsStore sharedStore] registerForPushNotifications];
        [self.acceptButton setTitle:@"" forState:UIControlStateNormal];
        self.acceptButton.enabled = NO;
        [self.activityIndicator startAnimating];
    }
}

- (void)deviceTokenSaved{
    if([self.delegate respondsToSelector:@selector(pushNotificationsAccepted:)]){
        [self.delegate pushNotificationsAccepted:YES];
    }
}

- (void)deviceTokenNotSaved{
    if([self.delegate respondsToSelector:@selector(pushNotificationsAccepted:)]){
        [self.delegate pushNotificationsAccepted:NO];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidDisappear:animated];
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
