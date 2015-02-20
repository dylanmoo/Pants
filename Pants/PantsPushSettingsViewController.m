//
//  PantsPushSettingsViewController.m
//  Pants
//
//  Created by Dylan Moore on 2/16/15.
//  Copyright (c) 2015 Dylan Moore. All rights reserved.
//

#import "PantsPushSettingsViewController.h"
#import "PantsStore.h"
#import "APIClient.h"

@interface PantsPushSettingsViewController ()

@property (nonatomic, strong) NSDate *timeForNotificationsNew;

@end

@implementation PantsPushSettingsViewController

#define INTERVAL 5

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.titleLabel setFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:32]];
    [self.titleLabel setTextColor:DEFAULT_SUPER_LIGHT_BLUE];
    
    [self.topLabel setFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:20]];
    [self.topLabel setTextColor:DEFAULT_SUPER_LIGHT_BLUE];
    [self.topLabel setTextAlignment:NSTextAlignmentLeft];
    [self.topLabel setNumberOfLines:0];
    
    [self.setTimeButton setTitleFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:60]];
    [self.setTimeButton setTitleColor:DEFAULT_SUPER_LIGHT_BLUE forState:UIControlStateNormal];
    [self.setTimeButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.setTimeButton setUserInteractionEnabled:YES];
    [self.setTimeButton setContentEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];

    if([[PantsStore sharedStore] timeForNotifications]){
        [self.setTimeButton setTitle:@"Saved!" forState:UIControlStateNormal];
        [self setTimeForDatePicker:[[PantsStore sharedStore] timeForNotifications]];
    }else{
        [self.setTimeButton setTitle:@"Set" forState:UIControlStateNormal];
    }
    
    [self.datePicker setValue:DEFAULT_SUPER_LIGHT_BLUE forKeyPath:@"textColor"];
    SEL selector = NSSelectorFromString( @"setHighlightsToday:" );
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature :
                                [UIDatePicker
                                 instanceMethodSignatureForSelector:selector]];
    BOOL no = NO;
    [invocation setSelector:selector];
    [invocation setArgument:&no atIndex:2];
    [invocation invokeWithTarget:self.datePicker];
    
    self.setTimeButton.layer.cornerRadius = 7;
    self.setTimeButton.layer.borderColor = DEFAULT_SUPER_LIGHT_BLUE.CGColor;
    self.setTimeButton.layer.borderWidth = 2;
    
    [self.denyButton setTitleColor:DEFAULT_RED_COLOR forState:UIControlStateNormal];
    [self.denyButton.titleLabel setFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:22]];
    [self.denyButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceTokenSaved) name:kNotificationDeviceTokenSaved object:nil];

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
    
    
    if([[PantsStore sharedStore] userHasDeviceToken]){
        [self saveNewPushNotificationDate];
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

}
- (IBAction)datePickerValueChanged:(id)sender {
    
    self.timeForNotificationsNew = self.datePicker.date;
    
    if(![self currentDateIsEqualToNewDate:self.timeForNotificationsNew]){
        [self.setTimeButton setTitle:@"Set" forState:UIControlStateNormal];
    }else{
        [self.setTimeButton setTitle:@"Saved!" forState:UIControlStateNormal];
    }
    
}

- (IBAction)denyButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
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

-(void)deviceTokenSaved{
    if([[PantsStore sharedStore] userHasDeviceToken]){
        [self saveNewPushNotificationDate];
        return;
    }
}

- (void)saveNewPushNotificationDate{
    if(![self currentDateIsEqualToNewDate:self.timeForNotificationsNew]){
        [self.activityIndicator startAnimating];
        [self.setTimeButton setTitle:@"" forState:UIControlStateNormal];
        [[APIClient sharedClient] updateTimeForNotifications:self.timeForNotificationsNew withCompletion:^(NSError *error) {
            [self.activityIndicator stopAnimating];
            if(!error){
                [self.setTimeButton setTitle:@"Saved!" forState:UIControlStateNormal];
                [self setTimeForDatePicker:[[PantsStore sharedStore] timeForNotifications]];
            }else{
                [self.setTimeButton setTitle:@"Retry" forState:UIControlStateNormal];
            }
        }];
        
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
