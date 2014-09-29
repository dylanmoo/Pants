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
#import "UIImage+animatedGIF.h"

@interface DSMViewController (){
    NSMutableData *_responseData;
    NSArray *hourlyWeather;
    NSString *pantsString;
    NSString *noPantsString;
    NSURL *urlForGif;
    CLLocation *currentLocation;
    NSURLConnection *currentConnection;
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
@property (weak, nonatomic) IBOutlet UIImageView *gifImageView;

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
    
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    [self.backgroundImageView setBackgroundColor:DEFAULT_BLUE_COLOR];
    [self.backgroundImageView setTop:self.timerLabel.centerY];
    [self.view insertSubview:self.backgroundImageView belowSubview:self.timerView];
    
    self.pantsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 102)];
    [self.pantsLabel setText:@"#PANTS"];
    [self.pantsLabel setTextColor:DEFAULT_LIGHT_BLUE_COLOR];
    [self.pantsLabel setTextAlignment:NSTextAlignmentCenter];
    [self.pantsLabel setCenterY:(self.view.height*3/4)-self.backgroundImageView.top];
    [self.pantsLabel setCenterX:self.view.centerX];
    [self.backgroundImageView addSubview:self.pantsLabel];
    
    [self.noPantsLabel setTextColor:DEFAULT_RED_COLOR];
    [self.noPantsLabel setCenterY:self.view.centerY/2];
    
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
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    [self.view addGestureRecognizer:panGesture];
    
    viewAppeared = false;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
}

-(void)didBecomeActive:(NSNotification*)notification
{
    if(viewAppeared){
        [self findLocation];
        [self findPantsAndNoPantsStrings];
    }
}

-(void)share:(UITapGestureRecognizer*)recognizer
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];

        NSMutableArray *sharingItems = [NSMutableArray new];
    if([recognizer.view isEqual:self.backgroundImageView]){
        [sharingItems addObject:@"I'm wearing #PANTS today! @SomeDumbApp told me to."];
        
        [mixpanel track:@"Sharing #PANTS"];
    }else{
        [sharingItems addObject:@"I'm wearing #NOPANTS today! @SomeDumbApp told me to."];
        
        [mixpanel track:@"Sharing #NOPANTS"];
    }
    
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
        [self presentViewController:activityController animated:YES completion:nil];
}

-(void)findLocation{
    if(IS_IOS8 && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined){
        [self.locationManager requestWhenInUseAuthorization];
        return;
    }
    
    [self.locationManager startUpdatingLocation];
    [self.activityIndicator startAnimating];
    [self.timerLabel setAlpha:0];
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if(status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedAlways){
        [self findLocation];
    }else if(status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted){
        [self showLocationError];
    }
}

-(void)panned:(UIPanGestureRecognizer*)recognizer
{
    
    if(recognizer.state == UIGestureRecognizerStateBegan)
    {
        [currentConnection cancel];
        NSLog(@"BEGAN");
        /*
        CGPoint location = [recognizer locationInView:self.view];
        
        [UIView animateWithDuration:.1 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            [self.pantsLabel setAlpha:0];
            [self.noPantsLabel setAlpha:0];
            [self.backgroundImageView setTop:location.y];
            [self.activityIndicator setCenterY:location.y];
            [self.timerLabel setAlpha:0];
            [self.activityIndicator setAlpha:1];
            [self.activityIndicator startAnimating];
            [self.backgroundImageView setHeight:self.view.height-location.y];
            [self.timerLabel setCenter:CGPointMake(self.timerLabel.center.x, location.y)];
            [self.timerView setCenter:CGPointMake(self.timerView.center.x, location.y)];
        } completion:^(BOOL finished) {
            //Nothing
        }];
         */
        
    }
    
    CGPoint translation = [recognizer translationInView:self.view];
    
    [self.backgroundImageView setTop:self.backgroundImageView.top + translation.y];
    [self.backgroundImageView setHeight:self.backgroundImageView.height - translation.y];
    [self.timerLabel setCenterY:self.timerLabel.center.y + translation.y];
     [self.timerView setCenterY:self.timerView.center.y + translation.y];
    [self.activityIndicator setCenterY:self.activityIndicator.center.y + translation.y];
    //[self.gifImageView setHeight:self.timerLabel.center.y];
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
        onb.subtitleLabel.text = @"does a bunch of complicated math and analyzes when the weather is just right for pants. We need your location, okay?";
        
        [onb.acceptButton setTitle:@"Okay!" forState:UIControlStateNormal];
        
        [onb setAcceptButtonBlock:^(UIButton *actionButton){
            NSLog(@"Accept Pressed");
            Mixpanel *mixpanel = [Mixpanel sharedInstance];
            
            [mixpanel track:@"Accepted Location Access"];
            

            [self dismissViewControllerAnimated:YES completion:^{
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
        [onb.acceptButton setTitleFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:55]];
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
    
    
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"opened"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if(!self.isFirstResponder){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)getWeatherForLat:(float)lat andLon:(float)lon{
    NSString *path = [NSString stringWithFormat:@"https://api.forecast.io/forecast/%@/%f,%f",WEATHER_API_KEY,lat,lon];
    // Create url connection and fire request
    currentConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:path]] delegate:self];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Fetched Weather" properties:@{@"lat": [NSNumber numberWithFloat:lat],@"lng":[NSNumber numberWithFloat:lon]}];
    
     
}



-(void)findPantsAndNoPantsStrings
{
    Firebase *firebaseForPants = [[Firebase alloc] initWithUrl:@"https://pantson.firebaseio.com/"];
    
    __weak typeof(self) weakSelf = self;
    
    [firebaseForPants observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if(snapshot.value){
            noPantsString = snapshot.value[@"no_pants_string"];
            pantsString = snapshot.value[@"pants_string"];
            urlForGif = [NSURL URLWithString:snapshot.value[@"gif_url"]];
            [weakSelf refreshFromFirebase];
        }
    }];
    
}

- (void)refreshFromFirebase
{
    NSLog(@"Firebase:\n%@\n%@\n%@",pantsString,noPantsString, urlForGif);
    
    if(pantsOn){
        [self.pantsLabel setText:pantsString];
    }else{
        [self.pantsLabel setText:noPantsString];
    }
    [self.gifImageView setImage:[UIImage animatedImageWithAnimatedGIFURL:urlForGif]];
    
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
    
    float distanceFromTop = 200;
    
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
    
    float heightOfBGView = self.view.height-distanceFromTop;
    
    [UIView animateWithDuration:.5 delay:0 usingSpringWithDamping:.7 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.pantsLabel setAlpha:1];
        [self.noPantsLabel setAlpha:1];
        [self.timerLabel setAlpha:1];
        [self.pantsLabel setCenter:CGPointMake(self.pantsLabel.center.x, pantsCenter-distanceFromTop)];
        [self.noPantsLabel setCenter:CGPointMake(self.noPantsLabel.center.x, noPantsCenter)];
        [self.backgroundImageView setTop:distanceFromTop];
        [self.timerView setCenter:CGPointMake(self.timerView.center.x, distanceFromTop)];
        [self.timerLabel setCenter:CGPointMake(self.timerLabel.center.x, distanceFromTop)];
        [self.activityIndicator setCenter:CGPointMake(self.activityIndicator.center.x, distanceFromTop)];
        [self.backgroundImageView setHeight:heightOfBGView];
    } completion:^(BOOL finished) {
        //[self.backgroundImageView setUserInteractionEnabled:YES];
    }];
    
    
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //[self.backgroundImageView setAlpha:1];
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

- (void)showNotificationAlert
{
    [[[UIAlertView alloc] initWithTitle:@"Turn on Auto Pants?" message:@"The following alert will ask for permission to send you notifications in the morning so you don't even have to open up the app. Please press \"Okay\"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Okay", nil] show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0){
        //Cancel Pressed
        
    }else{
        [self.locationManager requestAlwaysAuthorization];
        
        //Okay Pressed
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
         UIRemoteNotificationTypeAlert|
         UIRemoteNotificationTypeSound];
    }
}

- (IBAction)infoPressed:(id)sender {
    [self showNotificationAlert];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
