//
//  PantsPushSettingsViewController.m
//  Pants
//
//  Created by Dylan Moore on 2/16/15.
//  Copyright (c) 2015 Dylan Moore. All rights reserved.
//

#import "PantsPushSettingsViewController.h"
#import "PantsStore.h"

@interface PantsPushSettingsViewController ()

@property (nonatomic, strong) NSDate *timeForNotificationsNew;

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
    
    NSDate *timeForNotifications = [[PantsStore sharedStore] timeForNotifications];
    
    [self setDatePickerDate:timeForNotifications];
    
    if(timeForNotifications)
    {
        [self updateButtonWithDate:timeForNotifications];
    }
    else
    {
        [self.setTimeButton setTitle:@"8 A.M.?" forState:UIControlStateNormal];
    }
    
    self.setTimeButton.layer.cornerRadius = 7;
    self.setTimeButton.layer.borderColor = DEFAULT_RED_COLOR.CGColor;
    self.setTimeButton.layer.borderWidth = 2;
    
    [self.denyButton setTitleColor:DEFAULT_RED_COLOR forState:UIControlStateNormal];
    [self.denyButton.titleLabel setFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:18]];
    [self.denyButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDatePicker) name:kNotificationDeviceTokenSaved object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)setTimeButtonPressed:(id)sender {
    //Show time picker
    
    NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
    if (store == nil) {
        [[[UIAlertView alloc] initWithTitle:@"Sign in to iCloud" message:@"Sign into iCloud in your settings app to enable push notifications" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
        return;
    }
    
    UIApplication *application = [UIApplication sharedApplication];
    // Register for Push Notitications, if running iOS 8
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {
        // Register for Push Notifications before iOS 8
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    }
    
    if([[PantsStore sharedStore] timeForNotifications]){
        [self showDatePicker];
    }
}



- (void)showDatePicker{
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.doneButtonDistanceFromBottom.constant = 18 + self.datePicker.height;
        self.datePickerDistanceFromBottom.constant = 0;
        [self.view layoutIfNeeded];
    } completion:nil];
    
}

- (void)hideDatePicker{
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.doneButtonDistanceFromBottom.constant = 18;
        self.datePickerDistanceFromBottom.constant = -200;
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (IBAction)denyButtonPressed:(id)sender {
    if(self.timeForNotificationsNew){
        [[PantsStore sharedStore] setUserWeatherNotificationDate:self.timeForNotificationsNew];
    }
    
    [self hideDatePicker];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)datePickerValueChanged:(id)sender {
    
    self.timeForNotificationsNew = self.datePicker.date;
    
    [self updateButtonWithDate:self.timeForNotificationsNew];
}

- (void)updateButtonWithDate:(NSDate*)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    
    NSString *ampm = components.hour>12 ? @"P.M." :@"A.M.";
    
    NSString *time = [NSString stringWithFormat:@"%ld:%ld %@",(long)components.hour%12,(long)components.minute, ampm];
    [self.setTimeButton setTitle:[NSString stringWithFormat:@"%@",time] forState:UIControlStateNormal];
}

- (void)setDatePickerDate:(NSDate*)date{
    
    if(!date){
        NSCalendar *calendar = [NSCalendar currentCalendar];
        [calendar setTimeZone:[NSTimeZone systemTimeZone]];
        NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
        components.hour = 8;
        components.minute = 0;
        
        date = [components date];
        
    }else{
    
        [self.datePicker setDate:date];
    }
    
    
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
