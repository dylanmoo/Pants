//
//  DSMViewController.m
//  Pants
//
//  Created by Dylan Moore on 6/30/14.
//  Copyright (c) 2014 Dylan Moore. All rights reserved.
//

#import "DSMViewController.h"
#import <Firebase/Firebase.h>
#import <CoreLocation/CoreLocation.h>

@interface DSMViewController (){
    NSMutableData *_responseData;
}

@property (weak, nonatomic) IBOutlet UIImageView *pantsIcon;



@end



@implementation DSMViewController

NSString *WEATHER_API_KEY = @"fb98ed1c58fd01aca10a0ede95cc4758";

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
}

-(void)viewDidAppear:(BOOL)animated{
    
    [locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    NSLog(@"%@",[locations lastObject]);
    CLLocation *currentLocation = [locations lastObject];
    [self getWeatherForLat:currentLocation.coordinate.latitude andLon:currentLocation.coordinate.longitude];
    [locationManager stopUpdatingLocation];
}

-(void)getWeatherForLat:(float)lat andLon:(float)lon{
    NSString *path = [NSString stringWithFormat:@"https://api.forecast.io/forecast/%@/%f,%f",WEATHER_API_KEY,lat,lon];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
    // Create url connection and fire request
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}



-(void)findPants{
    
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    NSLog(@"Data: %@",_responseData);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
