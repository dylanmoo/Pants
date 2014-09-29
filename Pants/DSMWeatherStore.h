//
//  DSMWeatherStore.h
//  Pants
//
//  Created by Dylan Moore on 9/29/14.
//  Copyright (c) 2014 Dylan Moore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface DSMWeatherStore : NSObject <CLLocationManagerDelegate,NSURLConnectionDelegate>

+ (DSMWeatherStore*)sharedStore;

@property (nonatomic, strong) CLLocationManager *locationManager;

@end
