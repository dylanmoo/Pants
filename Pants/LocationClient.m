//
//  FoursquareClient.m
//  LetsAt
//
//  Created by Dylan Moore on 1/25/14.
//  Copyright (c) 2014 Dylan Moore. All rights reserved.
//

#import "LocationClient.h"
#import "AFHTTPRequestOperation.h"
#import "PantsStore.h"

NSString *myCurrentLatitude = @"";
NSString *myCurrentLongitude = @"";
NSString *myCurrentCity;
CLLocationManager *locationManager;


@implementation LocationClient


+ (LocationClient *)sharedClient
{
    static LocationClient *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] init];

    });
    return _sharedClient;
}

#pragma mark Foursquare

-(void)updateUsersLocation{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.pausesLocationUpdatesAutomatically = YES;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if(IS_IOS8){
        int authStatus = [CLLocationManager authorizationStatus];
        
        if(authStatus== kCLAuthorizationStatusNotDetermined){
            [locationManager requestWhenInUseAuthorization];
        }else if(authStatus == kCLAuthorizationStatusDenied){
            [self locationServicesDisabled];
        }else if(authStatus == kCLAuthorizationStatusRestricted){
            [self locationServicesDisabled];
        }else{
            [locationManager startUpdatingLocation];
        }
    }else{
        [locationManager startUpdatingLocation];
    }
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if(IS_IOS8){
        if(status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways)
        {
            [locationManager startUpdatingLocation];
        }else if(status == kCLAuthorizationStatusDenied)
        {
            [self locationServicesDisabled];
        }
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"LocationManager DidFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil && locationManager) {
        NSLog(@"Current location %@",currentLocation);
        [locationManager stopUpdatingLocation];
        myCurrentLongitude = [NSString localizedStringWithFormat:@"%.03f", currentLocation.coordinate.longitude];
        myCurrentLatitude = [NSString localizedStringWithFormat:@"%.03f", currentLocation.coordinate.latitude];
        NSLog(@"Location: %@, %@",myCurrentLatitude,myCurrentLongitude);
        NSDictionary *updatedLocation = [[NSDictionary alloc] initWithObjectsAndKeys:myCurrentLongitude,@"lon",myCurrentLatitude,@"lat", nil];
        [[NSUserDefaults standardUserDefaults] setObject:updatedLocation forKey:@"lastLocation"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLocationUpdated object:nil];
    }
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLocationServicesEnabled object:nil];
}

-(NSDictionary*)currentLocation{
    
    if([myCurrentLatitude isEqualToString:@""] || [myCurrentLongitude isEqualToString:@""]){
        NSDictionary *currentLocation = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastLocation"];
        
        if(!currentLocation) return nil;
        
        myCurrentLatitude = currentLocation[@"lat"];
        myCurrentLongitude = currentLocation[@"lon"];
        
    }
    
    return @{@"lat": myCurrentLatitude,@"lon":myCurrentLongitude};
}

- (NSString*)currentLatitude{
    return myCurrentLatitude;
}

- (NSString*)currentLongitude{
    return myCurrentLongitude;
}

-(NSString*)currentCity{
    NSString *currentCity = [[NSUserDefaults standardUserDefaults] objectForKey:@"last_city"];
    
    if(!currentCity){
        currentCity = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastCity"];
    }
    
    if(!currentCity) return nil;
    
    myCurrentCity = currentCity;
    
    return myCurrentCity;
}

- (void)locationServicesDisabled{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLocationServicesDisabled object:nil];
}

- (void)locationFromZipCode:(NSString*)zipcode completionHandler:(void (^)(CLLocation *newLocation))block {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:zipcode completionHandler:^(NSArray *placemarks, NSError *error) {
        if(placemarks.count>0){
            CLPlacemark *placemark = placemarks[0];
            if(placemark){
                if(block){
                        block(placemark.location);
                }
            }
        }
        
        if(block){
            block(nil);
        }
    }];
}

@end
