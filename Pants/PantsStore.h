//
//  PantsStore.h
//  Pants
//
//  Created by Dylan Moore on 2/14/15.
//  Copyright (c) 2015 Dylan Moore. All rights reserved.
//

#import "CoreDataStore.h"

@interface PantsStore : CoreDataStore

+ (PantsStore *)sharedStore;

- (NSString*)userID;

- (NSDate*)timeForNotifications;

- (BOOL)userHasDeviceToken;

- (void)setUserID:(NSString*)userID;

- (void)setUserWeatherNotificationDate:(NSDate*)date;

- (BOOL)needsToCreateNewUser;

- (void)registerForPushNotifications;

@end
