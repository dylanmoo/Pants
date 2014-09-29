//
//  DSMStore.m
//  Pants
//
//  Created by Dylan Moore on 9/2/14.
//  Copyright (c) 2014 Dylan Moore. All rights reserved.
//

#import "DSMStore.h"
#import "Mixpanel.h"

@implementation DSMStore

static DSMStore *SINGLETON = nil;

static bool isFirstAccess = YES;

#pragma mark - Public Method

+ (id)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isFirstAccess = NO;
        SINGLETON = [[super allocWithZone:NULL] init];    
    });
    
    return SINGLETON;
}

- (BOOL)isFirstTimeUser
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"opened"]){
        return NO;
    }

    
    return YES;
}

- (void)setDateForFirstUse
{
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"dateForFirstUse"]){
        
        NSDate *dateForFirstUse = [NSDate date];
        
        [[NSUserDefaults standardUserDefaults] setObject:dateForFirstUse forKey:@"dateForFirstUse"];
    
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        int timeInterval = dateForFirstUse.timeIntervalSince1970;
        
        NSString *identifier = [NSString stringWithFormat:@"%d",timeInterval];
        
        [mixpanel createAlias: identifier
                forDistinctID:mixpanel.distinctId];
        
        [mixpanel identify:identifier];
        
    }
}

#pragma mark - Life Cycle

+ (id) allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

+ (id)copyWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}

+ (id)mutableCopyWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}

- (id)copy
{
    return [[DSMStore alloc] init];
}

- (id)mutableCopy
{
    return [[DSMStore alloc] init];
}

- (id) init
{
    if(SINGLETON){
        return SINGLETON;
    }
    if (isFirstAccess) {
        [self doesNotRecognizeSelector:_cmd];
    }
    self = [super init];
    return self;
}


@end
