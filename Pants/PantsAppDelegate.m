//
//  DSMAppDelegate.m
//  Pants
//
//  Created by Dylan Moore on 6/30/14.
//  Copyright (c) 2014 Dylan Moore. All rights reserved.
//

#import "PantsAppDelegate.h"
#import "Mixpanel.h"
#import "PantsStore.h"
#import <Appirater.h>
#import "APIClient.h"
#import "LocationClient.h"

#define MIXPANEL_TOKEN @"10368102de1354bfe301c6f5212fe883"



@implementation PantsAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Initialize the library with your
    // Mixpanel project token, MIXPANEL_TOKEN
    [Appirater setAppId:@"900751118"];
    [Appirater setDaysUntilPrompt:7];
    [Appirater setUsesUntilPrompt:0];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    [Appirater setDebug:NO];
    
    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
    
    // Later, you can get your instance with
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Launched"];
    
    [Appirater appLaunched:YES];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Closed"];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];

    [mixpanel track:@"Opened"];
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel.people addPushDeviceToken:deviceToken];
    
    [[APIClient sharedClient] updateDeviceToken:deviceToken];
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    if(![userInfo objectForKey:@"aps"]) completionHandler(UIBackgroundFetchResultNoData);
    
    NSDictionary *apns = [userInfo objectForKey:@"aps"];
    
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
    localNotification.alertBody = @"GOT PUSH";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];

    
    if(![apns objectForKey:@"type"]) completionHandler(UIBackgroundFetchResultNoData);
    
    NSString *type = [apns objectForKey:@"type"];
    
    UILocalNotification* localNotification2 = [[UILocalNotification alloc] init];
    localNotification2.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
    localNotification2.alertBody = @"TYPE FOUND";
    localNotification2.timeZone = [NSTimeZone defaultTimeZone];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification2];
    
    if(![type isEqualToString:@"update_location"]) completionHandler(UIBackgroundFetchResultNoData);
    
    UILocalNotification* localNotification3 = [[UILocalNotification alloc] init];
    localNotification3.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
    localNotification3.alertBody = @"UPDATE LOCATION";
    localNotification3.timeZone = [NSTimeZone defaultTimeZone];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification3];
    
    if([[LocationClient sharedClient] currentLocation]){
        
        UILocalNotification* localNotification4 = [[UILocalNotification alloc] init];
        localNotification4.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
        localNotification4.alertBody = @"CURRENT LOCATION";
        localNotification4.timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification4];
        
        [[LocationClient sharedClient] updateLocationWithBlock:^(NSString *lat, NSString *lon) {
            
            UILocalNotification* localNotification5 = [[UILocalNotification alloc] init];
            localNotification5.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
            localNotification5.alertBody = [NSString stringWithFormat:@"AFTER LOCATION BLOCK"];
            localNotification5.timeZone = [NSTimeZone defaultTimeZone];
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification5];
            
            [[APIClient sharedClient] updateLocationWithCompletion:^(NSError *error) {
                if(!error){
                    completionHandler(UIBackgroundFetchResultNewData);
                }else{
                    completionHandler(UIBackgroundFetchResultNoData);
                }
            }];
        }];
    }
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // Show alert for push notifications recevied while the
    // app is running
}

@end
