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
#import "DSMOnboardingViewController.h"
#import "DSMStore.h"
#import "Mixpanel.h"

@interface DSMViewController (){
    NSMutableData *_responseData;
    NSArray *hourlyWeather;
    NSString *pantsString;
    NSString *noPantsString;
    CLLocation *currentLocation;
    NSDate *todaysMaxTempDate;
    BOOL pantsOn;
    BOOL viewAppeared;
    int pantsOnHour;
    float tempThreshold;
}

@property (strong, nonatomic) UILabel *pantsLabel;
@property (weak, nonatomic) IBOutlet UILabel *noPantsLabel;
@property (strong, nonatomic) UIImageView *backgroundImageView;
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
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    
    
    [self.timerLabel setCenter:self.view.center];
    
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height/2)];
    [self.backgroundImageView setBackgroundColor:DEFAULT_BLUE_COLOR];
    [self.backgroundImageView setTop:self.timerLabel.centerY];
    [self.view insertSubview:self.backgroundImageView belowSubview:self.timerView];
    
    self.pantsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 102)];
    [self.pantsLabel setText:@"#PANTS"];
    [self.pantsLabel setTextColor:DEFAULT_LIGHT_BLUE_COLOR];
    [self.pantsLabel setTextAlignment:NSTextAlignmentCenter];
    [self.pantsLabel setCenterY:self.backgroundImageView.bounds.size.height/2];
    [self.pantsLabel setCenterX:self.view.centerX];
    [self.backgroundImageView addSubview:self.pantsLabel];
    
    [self.noPantsLabel setTextColor:DEFAULT_RED_COLOR];
    
    [self.view setBackgroundColor:DEFAULT_YELLOW_COLOR];
    
    [self.noPantsLabel setFont:[UIFont fontWithName:@"SignPainter-HouseScript" size:35]];
    [self.pantsLabel setFont:[UIFont fontWithName:@"SignPainter-HouseScript" size:35]];
    [self.timerLabel setFont:[UIFont fontWithName:@"SignPainter-HouseScript" size:16]];
    
    
    
    tempThreshold = 73.0f;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(share:)];
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(share:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:tapGesture2];
    
    [self.backgroundImageView setUserInteractionEnabled:YES];
    [self.backgroundImageView addGestureRecognizer:tapGesture];
    
    viewAppeared = false;
    
}

-(void)didBecomeActive:(NSNotification*)notification
{
    [self findLocation];
}

-(void)share:(UITapGestureRecognizer*)recognizer
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];

        NSMutableArray *sharingItems = [NSMutableArray new];
    if([recognizer.view isEqual:self.backgroundImageView]){
        [sharingItems addObject:@"I'm wearing #PANTS today! "];
        
        [mixpanel track:@"Sharing #PANTS"];
    }else{
        [sharingItems addObject:@"I'm wearing #NOPANTS today! "];
        
        [mixpanel track:@"Sharing #NOPANTS"];
    }
    
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
        [self presentViewController:activityController animated:YES completion:nil];
}

-(void)findLocation{
    [self.locationManager startUpdatingLocation];
    [self.activityIndicator startAnimating];
    [self.timerLabel setAlpha:0];
}

-(void)panned:(UIPanGestureRecognizer*)recognizer
{
    
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
        [self findLocation];
    }
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(!viewAppeared){
        if([[DSMStore sharedInstance] isFirstTimeUser]){
            [self showOnboarding];
        }else{
            [self findLocation];
        }
    }
    
    viewAppeared = true;
}

-(void)showOnboarding
{
    DSMOnboardingViewController *onb = [[DSMOnboardingViewController alloc] init];
    [self presentViewController:onb animated:YES completion:^{
        onb.titleLabel.text = @"#PANTS";
        onb.subtitleLabel.text = @"helps you figure out whether or not you should wear pants today. We do a bunch of complicated math and analyze when the weather is just right for pants. We need your location, okay?";
        [onb.acceptButton setTitle:@"Okay!" forState:UIControlStateNormal];
        __weak typeof(self) weakSelf = self;
        [onb setAcceptButtonBlock:^(UIButton *actionButton){
            NSLog(@"Accept Pressed");
            Mixpanel *mixpanel = [Mixpanel sharedInstance];
            
            [mixpanel track:@"Accepted Location Access"];
            
            [weakSelf dismissViewControllerAnimated:YES completion:^{
                [self findLocation];
            }];
        }];
        
        [onb.denyButton setTitle:@"Nah" forState:UIControlStateNormal];
        __weak typeof(onb) weakOnb = onb;
        [onb setDenyButtonBlock:^(UIButton *actionButton){
            NSLog(@"Deny Pressed");
            Mixpanel *mixpanel = [Mixpanel sharedInstance];
            
            [mixpanel track:@"Denied Location Access"];
            
            weakOnb.subtitleLabel.text = @"really needs your location so we can give you the most accurate time to put on pants...Thank you!!";
    
        }];
        
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"Showing Onboarding"];
    }];
    
}


-(void)showLocationError
{
    DSMOnboardingViewController *onb = [[DSMOnboardingViewController alloc] init];
    [self presentViewController:onb animated:YES completion:^{
        onb.titleLabel.text = @"#PANTS";
        onb.subtitleLabel.text = @"really needs your location. Can you go to:\n\n->Settings\n->Privacy\n->Location\n->Pants and turn it on?";
        [onb.subtitleLabel sizeToFit];
        [onb.subtitleLabel setTop:onb.titleLabel.bottom];
        onb.acceptButton.titleLabel.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:55];
        [onb.acceptButton setTitle:@"I did that!" forState:UIControlStateNormal];
        __weak typeof(self) weakSelf = self;
        [onb setAcceptButtonBlock:^(UIButton *actionButton){
            NSLog(@"Accept Pressed");
            Mixpanel *mixpanel = [Mixpanel sharedInstance];
            
            [mixpanel track:@"Accepted Location Access"];
            
                [self findLocation];
        }];
        
        [onb.denyButton setTitle:@"Nah" forState:UIControlStateNormal];
        __weak typeof(onb) weakOnb = onb;
        [onb setDenyButtonBlock:^(UIButton *actionButton){
            NSLog(@"Deny Pressed");
            Mixpanel *mixpanel = [Mixpanel sharedInstance];
            
            [mixpanel track:@"Denied Location Access"];
            
            weakOnb.subtitleLabel.text = @"really needs your location so we can give you the most accurate time to put on pants...Thank you!!";
        }];
        
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"Showing Location Error"];
    }];
    
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"Location Error: %@",error);
    
    [self.activityIndicator stopAnimating];
    [self.backgroundImageView setUserInteractionEnabled:YES];
    [self showLocationError];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    NSLog(@"%@",[locations lastObject]);
    currentLocation = [locations lastObject];
    
    [self.self.locationManager stopUpdatingLocation];
    [self getWeatherForLat:currentLocation.coordinate.latitude andLon:currentLocation.coordinate.longitude];
    
    if(!self.isFirstResponder){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)getWeatherForLat:(float)lat andLon:(float)lon{
    NSString *path = [NSString stringWithFormat:@"https://api.forecast.io/forecast/%@/%f,%f",WEATHER_API_KEY,lat,lon];
    // Create url connection and fire request
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:path]] delegate:self];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Fetched Weather" properties:@{@"lat": [NSNumber numberWithFloat:lat],@"lng":[NSNumber numberWithFloat:lon]}];
    
     
}



-(void)findPantsAndNoPantsStrings
{
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
    
    NSNumber *dailyMaxEpoch = weather[@"daily"][@"data"][0][@"apparentTemperatureMaxTime"];
    
    // (Step 1) Create NSDate object
    NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:dailyMaxEpoch.intValue];
    NSLog (@"Epoch time %d equates to UTC %@", dailyMaxEpoch.intValue, epochNSDate);
    
    // (Step 2) Use NSDateFormatter to display epochNSDate in local time zone
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    NSLog (@"Epoch time %d equates to %@", dailyMaxEpoch.intValue, [dateFormatter stringFromDate:epochNSDate]);
    
    todaysMaxTempDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:epochNSDate]];
    
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
        
        if([hourDate compare:outUntilDate]==NSOrderedAscending && [hourDate compare:todaysMaxTempDate]==NSOrderedDescending){
            //Add to average Temp
            NSLog(@"%@ is between %@ and %@",hourDate,todaysMaxTempDate,outUntilDate);
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
    
    if(!foundFirstHourForPants){
        hourToPutOnPants = 23;
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
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Showing Pants Time" properties:@{@"time": time}];
    
   
    [self.pantsLabel setText:pantsString];
    [self.noPantsLabel setText:noPantsString];
    
    [self.activityIndicator setHidesWhenStopped:YES];
    [self.activityIndicator stopAnimating];
    [UIView animateWithDuration:.5 delay:0 usingSpringWithDamping:.6 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.pantsLabel setAlpha:1];
        [self.noPantsLabel setAlpha:1];
        [self.timerLabel setAlpha:1];
        //[self.pantsLabel setCenter:CGPointMake(self.pantsLabel.center.x, pantsCenter)];
        //[self.noPantsLabel setCenter:CGPointMake(self.noPantsLabel.center.x, noPantsCenter)];
        //[self.backgroundImageView setFrame:CGRectMake(self.backgroundImageView.frame.origin.x,distanceFromTop,self.backgroundImageView.frame.size.width,self.backgroundImageView.frame.size.height)];
        
        //[self.timerView setCenter:CGPointMake(self.timerView.center.x, distanceFromTop)];
        //[self.timerLabel setCenter:CGPointMake(self.timerLabel.center.x, distanceFromTop)];
        //[self.activityIndicator setCenter:CGPointMake(self.activityIndicator.center.x, distanceFromTop)];
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
