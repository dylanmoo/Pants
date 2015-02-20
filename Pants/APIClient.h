//
//  APIClient.h
//  Raft
//
//  Created by Dylan Moore on 6/9/13.
//  Copyright (c) 2013 Raft. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"
#import "PantsStore.h"
#import "PantsWeather.h"

@interface APIClient : AFHTTPRequestOperationManager

+ (APIClient *)sharedClient;

//USING

- (void)updateDeviceToken:(NSData*)token;

-(void)updateTimeForNotifications:(NSDate *)newDate withCompletion:(void (^)(NSError *error))completionBlock;

- (void)saveUbiquityToken:(NSData*)token;

- (void)getWeatherWithCompletion:(void (^)(PantsWeather *weather))completionBlock;

- (void)signIn;

@end
