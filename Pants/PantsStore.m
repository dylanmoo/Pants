//
//  PantsStore.m
//  Pants
//
//  Created by Dylan Moore on 2/14/15.
//  Copyright (c) 2015 Dylan Moore. All rights reserved.
//

#import "PantsStore.h"
#import "User.h"

@interface PantsStore(){
    User *user;
}

@end

@implementation PantsStore

#pragma mark Initialization
+ (PantsStore *)sharedStore
{
    
    static PantsStore *store = nil;
    
    if (!store) {
        
        store = (PantsStore*)[super sharedStore];
        
    }
    
    return store;
}

-(id)init{
    self = [super init];
    
    if (self) {
        
        user = [self fetchUser];
        
        [self saveContext:NO];
    }
    return self;
    
}

- (User*)fetchUser{
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"User" inManagedObjectContext:self.mainContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setReturnsObjectsAsFaults:NO];
    
    NSError *Fetcherror;
    NSMutableArray *array = [[self.mainContext executeFetchRequest:request error:&Fetcherror] mutableCopy];
    
    if (array.count == 1) {
        // Update User with data from JSON
        return array[0];
        
    }else{
        
        //Delete extras if there are some
        if(array.count > 1){
            for(User *extraUser in array){
                [self.mainContext deleteObject:extraUser];
            }
        }
        
        //Create blank new user
        user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:self.mainContext];
        return user;
    }

}

- (NSString*)userID{
    
    //Return user id if already saved
    if(user.user_id){
        NSLog(@"User %@",user.user_id);
        return user.user_id;
    }
    
    //Not saved
    //Look for user id in iCloud
    NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
    if (store != nil) {
        if([store objectForKey:kUserID]){
            //Found user id in iCloud
            NSString *userId = [store objectForKey:kUserID];
            [user setUser_id:[NSString stringWithFormat:@"%@",userId]];
            [self saveContext:NO];
            NSLog(@"User %@",userId);
            return userId;
        }else{
            //No user id in iCloud
            return nil;
        }
    }else{
        //No store
        return nil;
    }

}

- (BOOL)needsToCreateNewUser{
    
    NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
    if (store == nil) {
        return NO;
        
    }
    
    if([store objectForKey:kUserID])
    {
        return NO;
        
    }
    else{
        return YES;
        
    }
}

- (BOOL)userHasDeviceToken{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kDeviceToken];
}

- (void)setUserWeatherNotificationDate:(NSDate*)date{
    [user setWeather_notification_date:date];
    [self saveContext:NO];
}

- (NSDate*)timeForNotifications{
    return user.weather_notification_date;
}

- (void)setUserID:(NSString*)userID{
    [user setUser_id:[NSString stringWithFormat:@"%@",userID]];
    [self saveContext:NO];
}

@end
