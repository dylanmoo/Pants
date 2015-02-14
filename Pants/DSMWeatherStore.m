//
//  DSMWeatherStore.m
//  Pants
//
//  Created by Dylan Moore on 9/29/14.
//  Copyright (c) 2014 Dylan Moore. All rights reserved.
//

#import "DSMWeatherStore.h"

@implementation DSMWeatherStore

static DSMWeatherStore *SINGLETON = nil;

#pragma mark - Public Method

+ (id)sharedStore
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SINGLETON = [[super allocWithZone:NULL] init];
    });
    
    return SINGLETON;
}

@end
