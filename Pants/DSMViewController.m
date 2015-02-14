//
//  DSMViewController.m
//  Pants
//
//  Created by Dylan Moore on 6/30/14.
//  Copyright (c) 2014 Dylan Moore. All rights reserved.
//

#import "DSMViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "DSMOnboardingViewController.h"
#import "DSMStore.h"
#import "Mixpanel.h"
#import "UIImage+animatedGIF.h"
#import <Parse/Parse.h>

@interface DSMViewController (){
    NSMutableData *_responseData;
    NSArray *hourlyWeather;
    NSString *pantsString;
    NSString *noPantsString;
    NSURL *pantsURL;
    NSURL *noPantsURL;
    CLLocation *currentLocation;
    NSURLConnection *currentConnection;
    NSDate *todaysMaxTempDate;
    BOOL pantsOn;
    BOOL viewAppeared;
    int pantsOnHour;
    float tempThreshold;
    NSTimer *loadingTimer;
}

@property (strong, nonatomic)  UILabel *pantsLabel;
@property (strong, nonatomic)  UILabel *noPantsLabel;
@property (strong, nonatomic)  UIImageView *pantsImageView;
@property (strong, nonatomic)  UIImageView *noPantsImageView;
@property (strong, nonatomic)  UILabel *timerLabel;
@property (strong, nonatomic)  UIImageView *timerView;
@property (strong, nonatomic)  UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic)  DSMInsetLabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;

@end



@implementation DSMViewController

NSString *WEATHER_API_KEY = @"fb98ed1c58fd01aca10a0ede95cc4758";

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    pantsString = @"#PANTS";
    noPantsString = @"#NOPANTS";
    
    self.timerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 54)];
    [self.timerView setImage:[UIImage imageNamed:@"separator.png"]];
    [self.timerView setCenter:self.view.center];
    [self.view addSubview:self.timerView];
    
    self.timerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 54, 54)];
    [self.timerLabel setText:@""];
    [self.timerLabel setTextAlignment:NSTextAlignmentCenter];
    [self.timerLabel setCenter:self.view.center];
    [self.view addSubview:self.timerLabel];
    [self.timerLabel setTextColor:[UIColor blackColor]];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicator setCenter:self.view.center];
    [self.view addSubview:self.activityIndicator];
    
    self.loadingLabel = [[DSMInsetLabel alloc] initWithFrame:CGRectMake(0, 0, self.timerView.bounds.size.width, self.timerView.bounds.size.height)];
    self.loadingLabel.text = @"calculating the time to put on pants...";
    self.loadingLabel.textAlignment = NSTextAlignmentLeft;
    [self.loadingLabel setBackgroundColor:[UIColor whiteColor]];
    [self.loadingLabel setCenter:self.view.center];
    [self.loadingLabel setTextColor:[UIColor blackColor]];
    [self.view addSubview:self.loadingLabel];
    
    //Setup Location manager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    self.pantsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    [self.pantsImageView setBackgroundColor:DEFAULT_BLUE_COLOR];
    [self.pantsImageView setTop:self.timerLabel.centerY];
    [self.pantsImageView setHeight:(self.view.height - self.timerLabel.centerY)];

    [self.pantsImageView setAutoresizesSubviews:YES];
    
    [self.view insertSubview:self.pantsImageView belowSubview:self.timerView];
    
    self.noPantsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    [self.noPantsImageView setBackgroundColor:DEFAULT_YELLOW_COLOR];
    [self.noPantsImageView setTop:self.view.top];
    [self.noPantsImageView setHeight:self.timerLabel.centerY];
    
    [self.noPantsImageView setAutoresizesSubviews:YES];
    
    [self.view insertSubview:self.noPantsImageView belowSubview:self.timerView];
    
    self.pantsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.pantsImageView.width, self.pantsImageView.height)];
    [self.pantsLabel setText:pantsString];
    [self.pantsLabel setNumberOfLines:0];
    [self.pantsLabel setTextColor:DEFAULT_LIGHT_BLUE_COLOR];
    [self.pantsLabel setTextAlignment:NSTextAlignmentCenter];
    [self.pantsLabel setCenterY:(self.pantsImageView.height/2)];
    [self.pantsLabel setCenterX:self.view.centerX];
    [self.pantsImageView addSubview:self.pantsLabel];
    
    
    self.noPantsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.noPantsImageView.width, self.noPantsImageView.height)];
    [self.noPantsLabel setText:noPantsString];
    [self.noPantsLabel setNumberOfLines:0];
    [self.noPantsLabel setTextColor:DEFAULT_RED_COLOR];
    [self.noPantsLabel setTextAlignment:NSTextAlignmentCenter];
    [self.noPantsLabel setCenterY:(self.noPantsImageView.height/2)];
    [self.noPantsLabel setCenterX:self.view.centerX];
    [self.noPantsImageView addSubview:self.noPantsLabel];
    
    
    
    //[self.view setBackgroundColor:DEFAULT_YELLOW_COLOR];
    
    [self.noPantsLabel setFont:[UIFont fontWithName:@"SignPainter-HouseScript" size:35]];
    [self.pantsLabel setFont:[UIFont fontWithName:@"SignPainter-HouseScript" size:35]];
    [self.timerLabel setFont:[UIFont fontWithName:@"SignPainter-HouseScript" size:16]];
    [self.loadingLabel setFont:[UIFont fontWithName:@"SignPainter-HouseScript" size:20]];
    
    tempThreshold = 73.0f;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self.view setUserInteractionEnabled:YES];
    [self.pantsImageView setUserInteractionEnabled:YES];
    [self.noPantsImageView setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleExplanation:)];
    [self.timerView addGestureRecognizer:tap];
    [self.timerView setUserInteractionEnabled:YES];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    
    [self.view addGestureRecognizer:panGesture];
    
    viewAppeared = false;
    
    [self.view bringSubviewToFront:self.infoButton];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
}

-(void)showLoading
{
    loadingTimer = [NSTimer scheduledTimerWithTimeInterval:.15 target:self selector:@selector(changeLoadingText:) userInfo:nil repeats:YES];
}

-(void)changeLoadingText:(NSTimer*)timer{
    NSString *text = self.loadingLabel.text;
    if([text containsString:@"..."]){
        self.loadingLabel.text = @"calculating the time to put on pants";
    }else if([text containsString:@".."]){
        self.loadingLabel.text = @"calculating the time to put on pants...";
    }else if([text containsString:@"."]){
        self.loadingLabel.text = @"calculating the time to put on pants..";
    }else{
        self.loadingLabel.text = @"calculating the time to put on pants.";
    }
}

- (void)stopLoading{
    [loadingTimer invalidate];
}

- (void)toggleExplanation:(UITapGestureRecognizer*)recognizer
{
    if(self.loadingLabel.alpha != 1){
        
        [UIView animateWithDuration:.3 delay:0 usingSpringWithDamping:.7 initialSpringVelocity:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            [self.loadingLabel setAlpha:1];
            self.loadingLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
        } completion:^(BOOL finished) {
            [self findLocation];
            [self findPantsAndNoPantsStrings];
        }];
    }
}

- (void)awakeFromNib{
    [self.timerLabel setCenterY:self.view.centerY];
    [self.timerView setCenterY:self.view.centerY];
    [self.activityIndicator setCenterY:self.view.centerY];
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
    if([recognizer.view isEqual:self.pantsImageView]){
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
    [self showLoading];
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


    
    CGPoint translation = [recognizer translationInView:self.view];
    
    [self.loadingLabel setCenterY:self.loadingLabel.centerY + translation.y];
    [self.pantsImageView setTop:self.pantsImageView.top + translation.y];
    [self.pantsImageView setHeight:self.pantsImageView.height - translation.y];
    [self.noPantsImageView setHeight:self.noPantsImageView.height + translation.y];
    [self.timerLabel setCenterY:self.timerLabel.center.y + translation.y];
    [self.noPantsLabel setCenterY:self.noPantsImageView.height/2];
    [self.pantsLabel setCenterY:self.pantsImageView.height/2];
    [self.timerView setCenterY:self.timerView.center.y + translation.y];
    [self.activityIndicator setCenterY:self.activityIndicator.center.y + translation.y];
    //[self.gifImageView setHeight:self.timerLabel.center.y];
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        NSLog(@"LIFT");
        [self showPantsAtHour:pantsOnHour];
       // [self findLocation];
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
    [self.pantsImageView setUserInteractionEnabled:YES];
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
    
    int hoursLater = hour;
    int hoursLeft = 24;
    float spacing = 200;
    
    float distanceFromTop = (hoursLater*((self.view.bounds.size.height-(2*spacing))/hoursLeft))+spacing;
    
    //distanceFromTop = self.view.height/2;
    
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
    
    [self stopLoading];
    
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:.7 initialSpringVelocity:0 options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction) animations:^{
        [self.pantsLabel setAlpha:1];
        [self.noPantsLabel setAlpha:1];
        [self.timerLabel setAlpha:1];
        
        [self.pantsImageView setTop:distanceFromTop];
        [self.pantsImageView setHeight:heightOfBGView];
        [self.noPantsImageView setHeight:distanceFromTop];
        [self.noPantsImageView setTop:0];
        
        
        [self.pantsLabel setCenter:CGPointMake(self.pantsLabel.center.x, self.pantsImageView.height/2)];
        [self.noPantsLabel setCenter:CGPointMake(self.noPantsLabel.center.x, self.noPantsImageView.height/2)];
        
        [self.noPantsGifImageView setHeight:self.noPantsImageView.height];
        
        [self.pantsGifImageView setHeight:self.pantsImageView.height];
        
        
        [self.timerView setCenter:CGPointMake(self.timerView.center.x, distanceFromTop)];
        [self.timerLabel setCenter:CGPointMake(self.timerLabel.center.x, distanceFromTop)];
        [self.activityIndicator setCenter:CGPointMake(self.activityIndicator.center.x, distanceFromTop)];
        [self.loadingLabel setCenterY:distanceFromTop];
        [self.loadingLabel setAlpha:0];
        self.loadingLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, .1);
    } completion:^(BOOL finished) {
        //[self.pantsImageView setUserInteractionEnabled:YES];
    }];
    
    
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //[self.pantsImageView setAlpha:1];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    [self.timerLabel setText:@"Failed,\nTry again"];
     [self.pantsImageView setUserInteractionEnabled:YES];
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

- (void)showNotificationAlertOptions
{
    [[[UIAlertView alloc] initWithTitle:@"Auto Pants Settings" message:@"What time would you like to receive your notification in the morning?" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"While I'm asleep", @"Before noon", @"Never", nil] show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0){
        //Cancel Pressed
        
    }else{
        UIApplication *application = [UIApplication sharedApplication];
        // Register for Push Notitications, if running iOS 8
        if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                            UIUserNotificationTypeBadge |
                                                            UIUserNotificationTypeSound);
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                     categories:nil];
            [application registerUserNotificationSettings:settings];
            [application registerForRemoteNotifications];
        } else {
            // Register for Push Notifications before iOS 8
            [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                             UIRemoteNotificationTypeAlert |
                                                             UIRemoteNotificationTypeSound)];
        }
    }
}

- (IBAction)infoPressed:(id)sender {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if(!currentInstallation.deviceToken){
        [self showNotificationAlert];
    }else{
        [self showNotificationAlertOptions];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
