//
//  APIClient.m
//  Raft
//
//  Created by Dylan Moore on 6/9/13.
//  Copyright (c) 2013 Raft. All rights reserved.
//

#import "APIClient.h"
#import "AFHTTPRequestOperation.h"
#import "CoreDataStore.h"
#import "Mixpanel.h"
#import "LocationClient.h"
#import "PantsWeather.h"
#import "NSDate+HumanInterval.h"

@interface APIClient ()

@end

@implementation APIClient

BOOL creatingNewUser;

+ (APIClient *)sharedClient
{
    static APIClient *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kPantsBaseURL]];
    });
    return _sharedClient;
}

-(id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    NSLog(@"Build Number: %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]);
    creatingNewUser = false;
    
    return self;
}

-(void)updateDeviceToken:(NSData *)token{
    if(token && [[PantsStore sharedStore] userID]){
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        // Make sure identify has been called before sending
        // a device token.
        // This sends the deviceToken to Mixpanel
        [mixpanel.people addPushDeviceToken:token];
        
        [mixpanel track:@"SIGNUP-Updating Device Token" properties:nil];
        
        NSString *path = [NSString stringWithFormat:@"api/v1/users/%@/sns_endpoints",[[PantsStore sharedStore] userID]];
        
        
        const unsigned *tokenBytes = [token bytes];
        NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                              ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                              ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                              ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
        NSLog(@"Updating Device Token: %@",hexToken);
        
        NSDictionary *userDic = [[NSDictionary alloc] initWithObjectsAndKeys:hexToken,kDeviceToken,[[PantsStore sharedStore] userID],@"user_id", nil];
        
        
        NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:userDic,@"sns_endpoint", nil];
        
        [self saveDeviceToken:token];
        
        
        [self POST:path
            parameters:params
            success:^(AFHTTPRequestOperation *operation, id JSON)
            {
                NSLog(@"Confirming user has updated device token");
            
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error)
            {
                NSLog(@"Not updating device token for user: %@", error.description);
                
            }];
    }
}

- (void)saveDeviceToken:(NSData*)token {
    // Save Local Copy
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:token forKey:kDeviceToken];
    
    // Save To iCloud
    NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
    
    if (store != nil) {
        if([store objectForKey:kDeviceToken]){
            NSData *savedToken = [store objectForKey:kDeviceToken];
            if([savedToken isEqualToData:token]){
                [[[UIAlertView alloc] initWithTitle:@"Test" message:@"Device token found on iCloud is same as new one" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
            }else{
                [[[UIAlertView alloc] initWithTitle:@"Test" message:@"Device token found on iCloud is different from new one. Saving new one." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
                
                [store setObject:token forKey:kDeviceToken];
                [store synchronize];
            }
        }else{
            [[[UIAlertView alloc] initWithTitle:@"Test" message:@"Device token not found on iCloud. Saving new one to iCloud." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
            
            [store setObject:token forKey:kDeviceToken];
            [store synchronize];
        }
    }else{
        [[[UIAlertView alloc] initWithTitle:@"Test" message:@"No iCloud store found." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
    }
}

- (void)updateNotificationTime:(NSDate*)dateForNotification {
    
        NSString *userId = [[PantsStore sharedStore] userID];
        
        if(userId){
            
            NSString *path = [NSString stringWithFormat:@"api/v1/users/%@",userId];
            NSDictionary *params = @{@"user":@{@"weather_notification_at":dateForNotification.toGlobalTime}};
            
            [self PATCH:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"User Succesfully updated date for notification: %@", responseObject);
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"User Failed to update date: %@", error);
                
            }];
            
        }
    
}


- (void)signIn {
    if([[LocationClient sharedClient] currentLocation]){
        
        NSString *lastLongitude = [[LocationClient sharedClient] currentLongitude];
        NSString *lastLatitude = [[LocationClient sharedClient] currentLatitude];
        
        
        NSString *userId = [[PantsStore sharedStore] userID];
        
        if(!userId && [[PantsStore sharedStore] needsToCreateNewUser] && !creatingNewUser){
            
            creatingNewUser = true;
            
            NSLog(@"Creating new user");
            
            
            NSString *path = [NSString stringWithFormat:@"api/v1/users"];
            NSDictionary *params = @{@"user":@{@"last_latitude":lastLatitude, @"last_longitude":lastLongitude}};
            
            [self POST:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"User Succesfully Signed in: %@", responseObject);
                
                if([responseObject objectForKey:@"id"]){
                    NSString *newUserID = [responseObject objectForKey:@"id"];
                    [[PantsStore sharedStore] setUserID:newUserID];
                    [self saveUserID:newUserID];
                }
                
                creatingNewUser = false;
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"User Failed to sign in: %@", error);
                
                creatingNewUser = false;
                
            }];
            
        }
        
        
    }
}

- (void)getWeatherWithCompletion:(void (^)(PantsWeather *weather))completionBlock{
    if([[LocationClient sharedClient] currentLocation]){
        
        NSString *lastLongitude = [[LocationClient sharedClient] currentLongitude];
        NSString *lastLatitude = [[LocationClient sharedClient] currentLatitude];
        
        NSString *userId = [[PantsStore sharedStore] userID];
        
        NSString *path = userId ? [NSString stringWithFormat:@"api/v1/users/%@/weather",userId] : @"api/v1/weather";
        
            NSDictionary *params = @{@"lat":lastLatitude, @"lng":lastLongitude};
            
            [self GET:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"User Succesfully Fetched Weather: %@", responseObject);
                
                PantsWeather *weather = [[PantsWeather alloc] initWithDictionary:responseObject];
                
                if(completionBlock){
                    completionBlock(weather);
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"User Failed to fetch weather: %@", error);
                
                if(completionBlock){
                    completionBlock(nil);
                }
                
            }];
        
        
    }
}

- (void)saveUserID:(NSString*)userID {
    // Save Local Copy
    
    if(userID){
        
        NSLog(@"Saving User ID to iCloud %@",userID);
        
        // Save To iCloud
        NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
        
        if (store != nil) {
            if([store objectForKey:kUserID]){
                NSString *savedID = [store objectForKey:kUserID];
                if([userID isEqualToString:savedID]){
                    [[[UIAlertView alloc] initWithTitle:@"Test" message:@"ID found on iCloud is same as new one" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
                    
                }else{
                    [[[UIAlertView alloc] initWithTitle:@"Test" message:@"ID found on iCloud is different from new one. Saving new one." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
                    
                    [store setObject:userID forKey:kUserID];
                    [store synchronize];
                }
            }else{
                [[[UIAlertView alloc] initWithTitle:@"Test" message:@"ID not found on iCloud. Saving new one to iCloud." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
                
                [store setObject:userID forKey:kUserID];
                [store synchronize];
            }
        }else{
            [[[UIAlertView alloc] initWithTitle:@"Test" message:@"No iCloud store found." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
        }
        
    }
}


@end