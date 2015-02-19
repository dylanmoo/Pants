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

- (void)setUserID:(NSString*)userID;

- (void)setUserWeatherNotificationDate:(NSDate*)date;

- (BOOL)needsToCreateNewUser;

@end
