//
//  DSMOnboardingViewController.m
//  Pants
//
//  Created by Dylan Moore on 9/1/14.
//  Copyright (c) 2014 Dylan Moore. All rights reserved.
//

#import "PantsOnboardingViewController.h"
#import "Mixpanel.h"
#import "LocationClient.h"
#import "APIClient.h"

@interface PantsOnboardingViewController (){
    BOOL locationAccessGranted;
}

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
    
    [self.denyButton setTitle:@"Skip" forState:UIControlStateNormal];
    
    [self.acceptButton setTitle:@"Okay!" forState:UIControlStateNormal];
    
    locationAccessGranted = false;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationAccessGranted:) name:kNotificationLocationServicesEnabled object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationAccessDenied:) name:kNotificationLocationServicesDisabled object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationAccessError:) name:kNotificationLocationServicesError object:nil];
    
    [self.denyButton setTitle:@"Nah" forState:UIControlStateNormal];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Showing Onboarding"];


}

- (void)locationAccessGranted:(NSNotification*)notification{
    //Show stop loading
    if(locationAccessGranted) return;
    
    locationAccessGranted = true;
    [[APIClient sharedClient] signInWithCompletion:^(NSError *error) {
        if(!error){
            [self showPushNotificationController];
        }else{
            [self.acceptButton setTitle:@"Okay!" forState:UIControlStateNormal];
            self.acceptButton.enabled = YES;
            [self.activityIndicator stopAnimating];
            //Can't sign in so show pants
            if([self.delegate respondsToSelector:@selector(finishedOnboarding)]){
                [self.delegate finishedOnboarding];
            }
        }
    }];
}

- (void)locationAccessDenied:(NSNotification*)notification{
    //Show stop loading
    self.acceptButton.enabled = YES;
    [self.acceptButton setTitle:@"Retry!" forState:UIControlStateNormal];
    [self.activityIndicator stopAnimating];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry..." message:@"We really need your location. Please enable by going to Settings>Pants>Location. This app is useless otherwise." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
    [alert show];
    
}

- (void)locationAccessError:(NSNotification*)notification{
    //Show stop loading
    self.acceptButton.enabled = YES;
    [self.activityIndicator stopAnimating];
    [self.acceptButton setTitle:@"Retry!" forState:UIControlStateNormal];
    [self.subtitleLabel setText:@"We're having trouble connecting you. Try again with better service please."];
    
}

- (void)showPushNotificationController{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    PantsOnboardingPushViewController *pushView = (PantsOnboardingPushViewController*)[storyboard instantiateViewControllerWithIdentifier:@"pantsOnboardingPushView"];
    pushView.delegate = self;
    
    [self.navigationController pushViewController:pushView animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)acceptButtonPressed:(id)sender {
    if(self.acceptButtonBlock){
        self.acceptButtonBlock(self.acceptButton);
    }else{
        [self.acceptButton setTitle:@"" forState:UIControlStateNormal];
        self.acceptButton.enabled = NO;
        [self.activityIndicator startAnimating];
        NSLog(@"Accept Pressed");
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"Accepted Location Access"];
        
        //Ask for permission
        [[LocationClient sharedClient] updateUsersLocation];
    }
}

- (IBAction)denyButtonPressed:(id)sender {
    if(self.denyButtonBlock){
        self.denyButtonBlock(self.denyButton);
    }else{
        NSLog(@"Deny Pressed");
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"Denied Location Access"];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry..." message:@"We really need your location so we can give you the most accurate time to put on pants. Please press Okay." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidDisappear:animated];
}

- (void)pushNotificationsAccepted:(BOOL)accepted{
    if([self.delegate respondsToSelector:@selector(finishedOnboarding)]){
        [self.delegate finishedOnboarding];
    }
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
