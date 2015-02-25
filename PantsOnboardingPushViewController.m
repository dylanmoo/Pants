//
//  PantsOnboardingPushViewController.m
//  Pants
//
//  Created by Dylan Moore on 2/19/15.
//  Copyright (c) 2015 Dylan Moore. All rights reserved.
//

#import "PantsOnboardingPushViewController.h"
#import "PantsStore.h"
#import "APIClient.h"

@interface PantsOnboardingPushViewController ()

@property (nonatomic, strong) NSDate *timeForNotificationsNew;

@end

@implementation PantsOnboardingPushViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = DEFAULT_YELLOW_COLOR;
    
    self.titleLabel.textColor = DEFAULT_RED_COLOR;
    self.mainLabel.textColor = DEFAULT_RED_COLOR;
    
    [self.mainLabel setFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:36]];
    
    [self.skipButton setTitleColor:DEFAULT_RED_COLOR forState:UIControlStateNormal];
    [self.skipButton.titleLabel setFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:15]];
    [self.skipButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self.skipButton setTitle:@"Nah" forState:UIControlStateNormal];
    
    [self.setTimeButton setTitleFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:60]];
    [self.setTimeButton setTitleColor:DEFAULT_RED_COLOR forState:UIControlStateNormal];
    [self.setTimeButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.setTimeButton setUserInteractionEnabled:YES];
    [self.setTimeButton setContentEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
    
    if([[PantsStore sharedStore] timeForNotifications]){
        [self.setTimeButton setTitle:@"Saved!" forState:UIControlStateNormal];
        [self setTimeForDatePicker:[[PantsStore sharedStore] timeForNotifications]];
    }else{
        [self setTimeForDatePicker:self.datePicker.date];
        [self.setTimeButton setTitle:@"Set it!" forState:UIControlStateNormal];
    }
    
    [self.datePicker setValue:DEFAULT_RED_COLOR forKeyPath:@"textColor"];
    SEL selector = NSSelectorFromString( @"setHighlightsToday:" );
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature :
                                [UIDatePicker
                                 instanceMethodSignatureForSelector:selector]];
    BOOL no = NO;
    [invocation setSelector:selector];
    [invocation setArgument:&no atIndex:2];
    [invocation invokeWithTarget:self.datePicker];
    
    self.setTimeButton.layer.cornerRadius = 7;
    self.setTimeButton.layer.borderColor = DEFAULT_RED_COLOR.CGColor;
    self.setTimeButton.layer.borderWidth = 2;
    
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

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(buttonIndex==0)
    {
        //Canceled
        if([self.delegate respondsToSelector:@selector(pushNotificationsAccepted:)]){
            [self.delegate pushNotificationsAccepted:NO];
        }
    }else{
        //Accepted
        [self.activityIndicator startAnimating];
        [self.setTimeButton setTitle:@"" forState:UIControlStateNormal];
        self.setTimeButton.enabled = NO;
        
        [[PantsStore sharedStore] registerForPushNotifications];
    }
}

- (void)deviceTokenSaved{
    if([[PantsStore sharedStore] userHasDeviceToken]){
        [self saveNewPushNotificationDate];
    }else{
        if([self.delegate respondsToSelector:@selector(pushNotificationsAccepted:)]){
            [self.delegate pushNotificationsAccepted:NO];
        }
    }
}

- (void)deviceTokenNotSaved{
    if([self.delegate respondsToSelector:@selector(pushNotificationsAccepted:)]){
        [self.delegate pushNotificationsAccepted:NO];
    }
}

- (IBAction)setTimeButtonPressed:(id)sender {
    //Show time picker
    
    UIAlertView *preAlert = [[UIAlertView alloc] initWithTitle:@"Let Pants Send You Push Notifications?" message:@"This will allow you to see the day's forecast without having to open up the app"  delegate:self cancelButtonTitle:@"Not Now" otherButtonTitles:@"Send Them", nil];
    [preAlert show];
    
    
}
- (IBAction)datePickerValueChanged:(id)sender {
    
    self.timeForNotificationsNew = self.datePicker.date;
    
    if(![self currentDateIsEqualToNewDate:self.timeForNotificationsNew]){
        [self.setTimeButton setTitle:@"Set it!" forState:UIControlStateNormal];
    }else{
        [self.setTimeButton setTitle:@"Saved!" forState:UIControlStateNormal];
    }
    
}

- (void)updateButtonWithDate:(NSDate*)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    
    NSString *ampm = components.hour>12 ? @"P.M." :@"A.M.";
    
    NSInteger hour = components.hour%12 == 0 ? 12 : components.hour%12;
    NSString *minute = components.minute < 10 ? [NSString stringWithFormat:@"0%ld", (long)components.minute] : [NSString stringWithFormat:@"%ld", (long)components.minute];
    
    NSString *time = [NSString stringWithFormat:@"%ld:%@ %@",(long)hour,minute, ampm];
    [self.setTimeButton setTitle:[NSString stringWithFormat:@"%@",time] forState:UIControlStateNormal];
    
    
    
}

- (BOOL)currentDateIsEqualToNewDate:(NSDate*)newDate{
    
    NSDate *currentDate = [[PantsStore sharedStore] timeForNotifications];
    
    if(!currentDate) return false;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    NSDateComponents *compsOfNewDate = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:newDate];
    NSDateComponents *compsOfCurrentDate = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:currentDate];
    
    if(compsOfCurrentDate.hour != compsOfNewDate.hour) return false;
    
    if(compsOfCurrentDate.minute != compsOfNewDate.minute) return false;
    
    return true;
}

- (void)setTimeForDatePicker:(NSDate*)dateToSet{
    self.timeForNotificationsNew = dateToSet;
    [self.datePicker setDate:self.timeForNotificationsNew];
}

- (void)saveNewPushNotificationDate{
        [[APIClient sharedClient] updateTimeForNotifications:self.timeForNotificationsNew withCompletion:^(NSError *error) {
            [self.activityIndicator stopAnimating];
            if(!error){
                [self.setTimeButton setTitle:@"Saved!" forState:UIControlStateNormal];
                [self setTimeForDatePicker:[[PantsStore sharedStore] timeForNotifications]];
                
                if([self.delegate respondsToSelector:@selector(pushNotificationsAccepted:)]){
                    [self.delegate pushNotificationsAccepted:YES];
                }
            }else{
                self.setTimeButton.enabled = YES;
                [self.setTimeButton setTitle:@"Retry" forState:UIControlStateNormal];
            }
        }];
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
