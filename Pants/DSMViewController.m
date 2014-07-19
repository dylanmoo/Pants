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
    NSArray *hourlyWeather;
    NSString *pantsString;
    NSString *noPantsString;
    CLLocation *currentLocation;
    BOOL pantsOn;
    int pantsOnHour;
    float tempThreshold;
}

@property (weak, nonatomic) IBOutlet UILabel *pantsLabel;
@property (weak, nonatomic) IBOutlet UILabel *noPantsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIImageView *timerView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end



@implementation DSMViewController

NSString *WEATHER_API_KEY = @"fb98ed1c58fd01aca10a0ede95cc4758";

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    pantsString = @"#PANTS";
    noPantsString = @"#NOPANTS";
    
    //Setup Location manager
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.noPantsLabel setFont:[UIFont fontWithName:@"SignPainter-HouseScript" size:35]];
     [self.pantsLabel setFont:[UIFont fontWithName:@"SignPainter-HouseScript" size:35]];
    [self.timerLabel setFont:[UIFont fontWithName:@"SignPainter-HouseScript" size:16]];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    [self.backgroundImageView addGestureRecognizer:panGesture];
    [self.backgroundImageView setUserInteractionEnabled:YES];
    
    tempThreshold = 73.0f;
    [self.activityIndicator startAnimating];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(share:)];
    [tapGesture requireGestureRecognizerToFail:panGesture];
    [self.view addGestureRecognizer:tapGesture];
    
   
}

-(void)share:(UITapGestureRecognizer*)recognizer{
        NSMutableArray *sharingItems = [NSMutableArray new];
    [sharingItems addObject:@"I'm wearing #NOPANTS today! "];
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
        [self presentViewController:activityController animated:YES completion:nil];
}

-(void)panned:(UIPanGestureRecognizer*)recognizer{
    
    if(recognizer.state == UIGestureRecognizerStateBegan)
    {
        NSLog(@"BEGAN");
        CGPoint location = [recognizer locationInView:self.view];
        /*
        recognizer.view.frame = CGRectMake(recognizer.view.frame.origin.x,location.y,recognizer.view.frame.size.width,recognizer.view.frame.size.height);
        [self.timerLabel setCenter:CGPointMake(self.timerLabel.center.x, location.y)];
        [self.timerView setCenter:CGPointMake(self.timerView.center.x, location.y)];
    */
         }
    
    CGPoint translation = [recognizer translationInView:self.view];
    
    recognizer.view.frame = CGRectMake(recognizer.view.frame.origin.x,recognizer.view.frame.origin.y + translation.y,recognizer.view.frame.size.width,recognizer.view.frame.size.height);
    [self.timerLabel setCenter:CGPointMake(self.timerLabel.center.x, self.timerLabel.center.y + translation.y)];
     [self.timerView setCenter:CGPointMake(self.timerView.center.x, self.timerView.center.y + translation.y)];
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        NSLog(@"LIFT");
        [self showPantsAtHour:pantsOnHour];
    }
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //[self findPantsAndNoPantsStrings];
    [locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"Location Error: %@",error);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    NSLog(@"%@",[locations lastObject]);
    currentLocation = [locations lastObject];
    
    [locationManager stopUpdatingLocation];
    [self getWeatherForLat:currentLocation.coordinate.latitude andLon:currentLocation.coordinate.longitude];
}

-(void)getWeatherForLat:(float)lat andLon:(float)lon{
    NSString *path = [NSString stringWithFormat:@"https://api.forecast.io/forecast/%@/%f,%f",WEATHER_API_KEY,lat,lon];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
    // Create url connection and fire request
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}



-(void)findPantsAndNoPantsStrings{
    Firebase *firebaseForPants = [[Firebase alloc] initWithUrl:@"https://pantson.firebaseio.com/"];
    [firebaseForPants observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if(snapshot.value){
            noPantsString = snapshot.value[@"noPantsString"];
            pantsString = snapshot.value[@"pantsString"];
            if(pantsOn){
                [self.pantsLabel setText:pantsString];
            }else{
                [self.pantsLabel setText:noPantsString];
            }
        }
    }];
    
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
    NSError *error = nil;
    
    NSDictionary *weather = [NSJSONSerialization JSONObjectWithData:_responseData options:kNilOptions error:&error];

    NSLog(@"Data: %@",weather);
    
    NSDictionary *hourly = weather[@"hourly"];
    hourlyWeather = hourly[@"data"];
    
    [self processHourlyWeatherForPants];
    
}


-(void)processHourlyWeatherForPants{
    
    NSDate *date = [NSDate date];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    NSDateComponents *comps = [calendar components:NSHourCalendarUnit fromDate:date];
    NSLog(@"COMPS;%@",comps);
    int secondsUntilMidnight = (23-comps.hour)*60*60;
    NSDate *outUntilDate = [date dateByAddingTimeInterval:secondsUntilMidnight];
    int hourToPutOnPants = comps.hour;

    bool foundFirstHourForPants = false;
    
    for(NSDictionary *hour in hourlyWeather){
        NSNumber *hourEpoch = hour[@"time"];
        
        // (Step 1) Create NSDate object
        NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:hourEpoch.intValue];
        NSLog (@"Epoch time %d equates to UTC %@", hourEpoch.intValue, epochNSDate);
        
        // (Step 2) Use NSDateFormatter to display epochNSDate in local time zone
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
        NSLog (@"Epoch time %d equates to %@", hourEpoch.intValue, [dateFormatter stringFromDate:epochNSDate]);
        
        NSDate *hourDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:epochNSDate]];
        
        if([hourDate compare:outUntilDate]==NSOrderedAscending){
            //Add to average Temp
            NSLog(@"%@ is earlier than %@",hourDate,outUntilDate);
           NSNumber *temp = hour[@"temperature"];
            
            if(temp.intValue<tempThreshold){
                if(foundFirstHourForPants){
                    break;
                }else{
                    foundFirstHourForPants = true;
                    
                    NSDateComponents *comps = [calendar components:NSHourCalendarUnit fromDate:hourDate];
                    NSLog(@"Comps for Hour ;%@",comps);
                    hourToPutOnPants = comps.hour;
                }
            }else{
                foundFirstHourForPants = false;
            }
        }
        
    }
    
    [self showPantsAtHour:hourToPutOnPants];
}

-(void)showPantsAtHour:(int)hour{
    pantsOnHour = hour;
    //Find placement of bar
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    NSDateComponents *comps = [calendar components:NSHourCalendarUnit fromDate:date];

    int hoursLater = hour - comps.hour;
    int hoursLeft = 23-comps.hour;
    float spacing = 60;
    
    float distanceFromTop = (hoursLater*((self.view.bounds.size.height-(2*spacing))/hoursLeft))+spacing;
    
    float noPantsCenter = distanceFromTop/2;
    float pantsCenter = ((self.view.bounds.size.height-distanceFromTop)/2) + distanceFromTop;
    
    NSString *time = [NSString stringWithFormat:@"%d %@",(hour>12?hour-12:hour),(hour>12 ? @"PM":@"AM") ];
    [self.timerLabel setText:time];
    
    
   
    [self.pantsLabel setText:pantsString];
    [self.noPantsLabel setText:noPantsString];
    
    [self.activityIndicator setHidesWhenStopped:YES];
    [self.activityIndicator stopAnimating];
    [UIView animateWithDuration:.5 delay:0 usingSpringWithDamping:.6 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.pantsLabel setAlpha:1];
        [self.noPantsLabel setAlpha:1];
        [self.timerLabel setAlpha:1];
        [self.pantsLabel setCenter:CGPointMake(self.pantsLabel.center.x, pantsCenter)];
        [self.noPantsLabel setCenter:CGPointMake(self.noPantsLabel.center.x, noPantsCenter)];
        [self.backgroundImageView setFrame:CGRectMake(self.backgroundImageView.frame.origin.x,distanceFromTop,self.backgroundImageView.frame.size.width,self.backgroundImageView.frame.size.height)];
        
        [self.timerView setCenter:CGPointMake(self.timerView.center.x, distanceFromTop)];
        [self.timerLabel setCenter:CGPointMake(self.timerLabel.center.x, distanceFromTop)];
       // [self.pantsLabel setTransform:CGAffineTransformMakeScale(1, 1)];
       // [self.noPantsLabel setTransform:CGAffineTransformMakeScale(1, 1)];
        
    } completion:^(BOOL finished) {
        //[self.backgroundImageView setUserInteractionEnabled:YES];
    }];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.backgroundImageView setAlpha:1];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    [self.timerLabel setText:@"Failed,\nTry again"];
     [self.backgroundImageView setUserInteractionEnabled:YES];
}

- (int)epochForDateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:year];
    [components setMonth:month];
    [components setDay:day];
    NSDate *date = [calendar dateFromComponents:components];
    return [date timeIntervalSince1970];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
