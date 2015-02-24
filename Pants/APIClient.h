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
#import "EmojiQuote.h"

@interface APIClient : AFHTTPRequestOperationManager

+ (APIClient *)sharedClient;

//USING

- (void)updateDeviceToken:(NSData*)token;

-(void)updateTimeForNotifications:(NSDate *)newDate withCompletion:(void (^)(NSError *error))completionBlock;

- (void)saveUbiquityToken:(NSData*)token;

- (void)getWeatherWithCompletion:(void (^)(PantsWeather *weather, EmojiQuote *emojiQuote))completionBlock;

- (void)signInWithCompletion:(void (^)(NSError *error))completionBlock;

- (void)updateLocationWithCompletion:(void (^)(NSError *error))completionBlock;

@end
