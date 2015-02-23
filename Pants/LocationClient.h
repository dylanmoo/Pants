//
//  FoursquareClient.h
//  LetsAt
//
//  Created by Dylan Moore on 1/25/14.
//  Copyright (c) 2014 Dylan Moore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "AFHTTPRequestOperationManager.h"

@interface LocationClient : AFHTTPRequestOperationManager <CLLocationManagerDelegate>

+ (LocationClient *)sharedClient;

@property (copy)void (^afterUpdateLocationBlock)(NSString *lat, NSString *lon);

- (void)updateUsersLocation;
- (void)updateLocationWithBlock:(void (^)(NSString *lat, NSString *lon))completionBlock;

- (NSDictionary*)currentLocation;
- (NSString*)currentLatitude;
- (NSString*)currentLongitude;

- (NSString*)currentCity;

@end
