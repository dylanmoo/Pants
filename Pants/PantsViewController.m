//
//  PantsViewController.m
//  Pants
//
//  Created by Dylan Moore on 6/30/14.
//  Copyright (c) 2014 Dylan Moore. All rights reserved.
//

#import "PantsViewController.h"
#import "PantsOnboardingViewController.h"
#import "Mixpanel.h"
#import "UIImage+animatedGIF.h"
#import "PantsStore.h"
#import "LocationClient.h"
#import "APIClient.h"
#import "PantsInsetLabel.h"
#import "PantsSettingsViewController.h"
#import "EmojiQuote.h"

@interface PantsViewController (){
    NSMutableData *_responseData;
    NSArray *hourlyWeather;
    NSString *pantsString;
    NSString *noPantsString;
    NSURL *pantsURL;
    NSURL *noPantsURL;
    NSURLConnection *currentConnection;
    NSDate *todaysMaxTempDate;
    BOOL pantsOn;
    BOOL viewAppeared;
    int pantsOnHour;
    float tempThreshold;
    NSTimer *loadingTimer;
    BOOL animating;
    BOOL showingOnboarding;
}

@property (strong, nonatomic)  UILabel *pantsLabel;

@property (strong, nonatomic)  UIImageView *pantsImageView;
@property (strong, nonatomic) UILabel *topTimerLabel;
@property (strong, nonatomic) UILabel *middleTimerLabel;
@property (strong, nonatomic)  UILabel *bottomTimerLabel;
@property (strong, nonatomic) UILabel *topDotsTimerLabel;
@property (strong, nonatomic) UILabel *bottomDotsTimerLabel;
@property (strong, nonatomic)  UIImageView *beltView;
@property (strong, nonatomic)  PantsWeather *currentWeather;
@property (strong, nonatomic) EmojiQuote *currentEmojiQuote;
@property (weak, nonatomic)  IBOutlet UILabel *noPantsLabel;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UIImageView *emojiImageView;
@property (weak, nonatomic) IBOutlet UILabel *emojiQuote;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *quoteDistanceFromTop;
@property (strong, nonatomic) UIImageView *beltBuckleView;

@end



@implementation PantsViewController

NSString *WEATHER_API_KEY = @"fb98ed1c58fd01aca10a0ede95cc4758";

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    pantsString = @"#PANTS";
    noPantsString = @"NO PANTS";
    
    [self.pantsImageView setTop:120];
    [self.pantsImageView setLeft:-5];

    [self.view addSubview:self.pantsImageView];
    
    [self.beltView setBackgroundColor:[UIColor clearColor]];
    self.beltView.centerY = self.pantsImageView.top;
    
    //UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.beltView.height/2-height/2, self.beltView.width, height)];
    //[lineView setBackgroundColor:[UIColor whiteColor]];
    
    //[self.beltView addSubview:lineView];
    
    [self.view addSubview:self.beltView];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(findLocation)];
    [self.beltView addGestureRecognizer:tap];
    [self.beltView setUserInteractionEnabled:NO];
    
    self.view.backgroundColor = DEFAULT_YELLOW_COLOR;
    //[self.view insertSubview:self.noPantsImageView belowSubview:self.beltView];
    
    
    
    [self.noPantsLabel setText:noPantsString];
    [self.noPantsLabel setNumberOfLines:0];
    [self.noPantsLabel setTextColor:DEFAULT_RED_COLOR];
    [self.noPantsLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self.noPantsLabel setFont:[UIFont fontWithName:CABIN_FONT_REGULAR size:35]];
    [self.pantsLabel setFont:[UIFont fontWithName:@"SignPainter-HouseScript" size:35]];
    [self.emojiQuote setFont:[UIFont fontWithName:CABIN_FONT_REGULAR size:15]];
    
    tempThreshold = 73.0f;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationAccessDenied:) name:kNotificationLocationServicesDisabled object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdated:) name:kNotificationLocationUpdated object:nil];
    
    [self.view setUserInteractionEnabled:YES];
    [self.pantsImageView setUserInteractionEnabled:YES];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    
    [self.view addGestureRecognizer:panGesture];
    
    [tap requireGestureRecognizerToFail:panGesture];
    
    viewAppeared = false;
    
    [self.infoButton setImage:[UIImage imageNamed:@"smiley_blue"] forState:UIControlStateNormal];
    [self.view bringSubviewToFront:self.infoButton];
    
}

- (void)showFakeEmojiQuote{
    EmojiQuote *quote = [[EmojiQuote alloc] init];
    quote.emoji = [UIImage imageNamed:@"373"];
    quote.quote = @"What EVER with this weather. Anyway, 8PM. Pants. You’ll need them. That means it’s warm during the day. And then cold at night. Duh. Also? It’s gonna snow.";
    
    [self showEmojiQuote:quote];
}

- (void)showEmojiQuote:(EmojiQuote*)quote{
    self.emojiQuote.text = [quote stringForQuote];
    self.emojiImageView.image = quote.emoji;
}

-(void)showLoading
{
    [self.beltView setUserInteractionEnabled:NO];
    [self.pantsImageView setTop:120];
    [self.beltView setCenterY:self.pantsImageView.top];
    [self setBeltBuckleTextWithTop:@"" middle:@"LOADING" andBottom:@""];
    [self startSpin];
}

- (void)stopLoading{
    [self stopSpin];
}

- (void) spinWithOptions: (UIViewAnimationOptions) options {
    // this spin completes 360 degrees every 2 seconds
    [UIView animateWithDuration: 0.2f
                          delay: 0.0f
                        options: options
                     animations: ^{
                         if(animating){
                             self.beltBuckleView.transform = CGAffineTransformRotate(self.beltBuckleView.transform, M_PI);
                         }else{
                             self.beltBuckleView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, 2*M_PI);
                         }
                     }
                     completion: ^(BOOL finished) {
                         if (finished) {
                             if (animating) {
                                 // if flag still set, keep spinning with constant speed
                                 [self spinWithOptions: UIViewAnimationOptionCurveLinear];
                             } else if (options != UIViewAnimationOptionCurveEaseOut) {
                                 // one last spin, with deceleration
                                 [self spinWithOptions: UIViewAnimationOptionCurveEaseOut];
                             }
                         }
                     }];
}

- (void) startSpin {
    if (!animating) {
        animating = YES;
        [self spinWithOptions: UIViewAnimationOptionCurveEaseIn];
    }
}

- (void) stopSpin {
    // set the flag to stop spinning after one last 90 degree increment
    animating = NO;
}

-(void)didBecomeActive:(NSNotification*)notification
{
    if([[LocationClient sharedClient] currentLocation])
    {
        if(!self.isFirstResponder){
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
        [self findLocation];
        
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
    [[LocationClient sharedClient] updateUsersLocation];
    [self showLoading];
    [self.beltView setAlpha:1];
    [self.noPantsLabel setAlpha:0];
    [self.infoButton setAlpha:0];
    [self.emojiImageView setAlpha:0];
    [self.emojiQuote setAlpha:0];
}

-(void)locationAccessDenied:(NSNotification*)notification{
    [self showLocationError];
}

-(void)panned:(UIPanGestureRecognizer*)recognizer
{

    if(recognizer.state == UIGestureRecognizerStateBegan)
    {
        NSLog(@"LIFT");
        [UIView animateWithDuration:.2 delay:0 usingSpringWithDamping:.7 initialSpringVelocity:0 options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction) animations:^{
            self.infoButton.alpha = 0;
        } completion:nil];
        
        // [self findLocation];
    }
    
    CGPoint translation = [recognizer translationInView:self.view];
    
    [self.pantsImageView setTop:self.pantsImageView.top + translation.y];
    [self.pantsLabel setCenterY:self.pantsImageView.height/2];
    self.beltView.centerY = self.pantsImageView.top;
    
    NSLog(@"Pants: %f",self.beltView.top);
    //[self.gifImageView setHeight:self.timerLabel.center.y];
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    float distanceAway = self.beltView.top - self.emojiImageView.bottom;
    self.emojiImageView.alpha = distanceAway/100;
    self.emojiQuote.alpha = distanceAway/100;
    
    if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        NSLog(@"LIFT");
        if(self.currentWeather){
            [self displayWeather:self.currentWeather];
        }
    
       // [self findLocation];
    }
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSString *statusBarString = [NSString stringWithFormat:@"_s%@at%@sBar",@"t",@"u"];
    NSString *colorKey = @"foregroundColor";
    id statusBar = [[UIApplication sharedApplication] valueForKey:statusBarString];
    if (statusBar && [statusBar respondsToSelector:NSSelectorFromString(colorKey)])
    {
        [statusBar setValue:[UIColor blackColor] forKey:colorKey];
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(!viewAppeared)
    {
        if([[LocationClient sharedClient] currentLocation])
        {
            [self findLocation];
            
        }
        else{
            [self showOnboarding];
            
        }
    }
    
    viewAppeared = true;
}

-(void)showOnboarding
{
    showingOnboarding = true;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    
    PantsOnboardingViewController *onb = (PantsOnboardingViewController*)[storyboard instantiateViewControllerWithIdentifier:@"pantsOnboardingView"];
    onb.delegate = self;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:onb];
    [nav setNavigationBarHidden:YES];
    
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)finishedOnboarding{
    showingOnboarding = false;
    [self dismissViewControllerAnimated:YES completion:^{
        [self findLocation];
    }];
}


-(void)showLocationError
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    PantsOnboardingViewController *onb = (PantsOnboardingViewController*)[storyboard instantiateViewControllerWithIdentifier:@"pantsOnboardingView"];
    
    [self presentViewController:onb animated:YES completion:^{
        onb.titleLabel.text = @"#PANTS";
        onb.subtitleLabel.text = @"really needs your location. Can you go to:\n\n->Settings\n->Privacy\n->Location\n->Pants and turn it on?";
        
        [onb.acceptButton setTitleFont:[UIFont fontWithName:DEFAULT_FONT_REGULAR size:55]];
        [onb.acceptButton setTitle:@"I did that!" forState:UIControlStateNormal];
        
        __weak typeof(self) weakSelf = self;
        [onb setAcceptButtonBlock:^(UIButton *actionButton){
            NSLog(@"Accept Pressed");
            Mixpanel *mixpanel = [Mixpanel sharedInstance];
            
            [mixpanel track:@"Accepted Location Access"];
            
            [weakSelf findLocation];
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

-(void)locationUpdated:(NSNotification*)notification{
    
    if(showingOnboarding) return;
    
    NSDictionary *currentLocation = [[LocationClient sharedClient] currentLocation];
    
    if(!currentLocation){
        return;
    }
    
   [[APIClient sharedClient] getWeatherWithCompletion:^(PantsWeather *weather, EmojiQuote *emojiQuote) {
       
       dispatch_async(dispatch_get_main_queue(), ^{
           if(weather && emojiQuote){
               self.currentWeather = weather;
               self.currentEmojiQuote = emojiQuote;
               [self displayWeather:self.currentWeather];
           }else{
               [self showFailedToGetWeather];
               //[self showPantsAtHour:8];
           }
       });
       
       
   }];
    
    
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"opened"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)showFailedToGetWeather{
    [self setBeltBuckleTextWithTop:@"sorry" middle:@"TAP TO RETRY" andBottom:@"please"];
    [self stopLoading];
    [self.pantsImageView setUserInteractionEnabled:YES];
}

- (void)displayWeather:(PantsWeather*)weather{
    
//    [self showNoPantsAllDay:weather.noPantsFlavorText];
//    return;
    if(!weather) return;
    
    if(weather.pantsAtTime.intValue == 0)
    {
        //pants all day
        [self showPantsAllDay:weather.pantsFlavorText];
        
    }
    else if(weather.pantsAtTime.intValue == 24)
    {
        //no pants all day
        [self showNoPantsAllDay:weather.noPantsFlavorText];
        
    }
    else
    {
        [self showPantsAtHour:weather.pantsAtTime.intValue];
    
    }
    
}

- (void)showPantsAllDay:(NSString*)flavorText{
    if(!flavorText) flavorText = @"all day";
    
    [self showPantsAtHour:0];

}

- (void)showNoPantsAllDay:(NSString*)flavorText{
    if(!flavorText) flavorText = @"ALL DAY!";
    
    [self.noPantsLabel setText:[NSString stringWithFormat:@"%@ %@",noPantsString,flavorText]];
    //[self.pantsLabel setText:@"What?\nYou don't trust me?"];
    
    [self setBeltBuckleTextWithTop:@"I said" middle:@"NO PANTS" andBottom:@"silly!"];
    
    [self stopLoading];
    
    [self showEmojiQuote:self.currentEmojiQuote];
    self.quoteDistanceFromTop.constant = self.view.height/2-self.emojiQuote.height/2;
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:.7 initialSpringVelocity:0 options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction) animations:^{
        [self.noPantsLabel setAlpha:1];
        [self.infoButton setAlpha:1];
        [self.emojiImageView setAlpha:1];
        [self.emojiQuote setAlpha:1];
        
        [self.view bringSubviewToFront:self.pantsImageView];
        [self.view bringSubviewToFront:self.beltView];
        [self.view bringSubviewToFront:self.infoButton];
        [self.infoButton setImage:[UIImage imageNamed:@"smiley_red"] forState:UIControlStateNormal];
        [self.pantsImageView setTop:self.view.height+100];
        self.beltView.centerY = self.pantsImageView.top;
        
    } completion:^(BOOL finished) {
        //[self.pantsImageView setUserInteractionEnabled:YES];
    }];
}

-(void)showPantsAtHour:(int)hour{
    pantsOnHour = hour;
    
    //Find placement of bar
    self.quoteDistanceFromTop.constant = 80;
    [self.view layoutIfNeeded];
    float distanceFromTop = (246.0/568.0)*self.view.height;
    
    if(hour==0){
        [self setBeltBuckleTextWithTop:@"put on" middle:@"PANTS" andBottom:@"now!"];
        
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"Showing Pants All Day" properties:nil];
    }else{
        NSString *time = [NSString stringWithFormat:@"at %d%@",(hour>12?hour-12:hour),(hour>12 ? @"pm":@"am") ];
        [self setBeltBuckleTextWithTop:@"put on" middle:@"PANTS" andBottom:time];
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"Showing Pants Time" properties:@{@"time": time}];
    }
   
    [self.pantsLabel setText:pantsString];
    [self.noPantsLabel setText:noPantsString];
    
    [self stopLoading];
    
   [self showEmojiQuote:self.currentEmojiQuote];
    
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:.7 initialSpringVelocity:0 options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction) animations:^{
        [self.pantsLabel setAlpha:1];
        [self.noPantsLabel setAlpha:0];
        [self.beltView setAlpha:1];
        [self.infoButton setAlpha:1];
        
        [self.pantsImageView setTop:distanceFromTop];
        [self.infoButton setImage:[UIImage imageNamed:@"smiley_blue"] forState:UIControlStateNormal];
        [self.view bringSubviewToFront:self.infoButton];
        [self.view bringSubviewToFront:self.beltView];
        self.beltView.centerY = self.pantsImageView.top;
        [self.emojiImageView setAlpha:1];
        [self.emojiQuote setAlpha:1];
        
        [self.pantsLabel setCenter:CGPointMake(self.pantsLabel.center.x, self.pantsImageView.height/2)];
        
        [self.beltView setCenter:CGPointMake(self.beltView.center.x, distanceFromTop)];
    } completion:^(BOOL finished) {
        
    }];
    
    
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //[self.pantsImageView setAlpha:1];
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
        
    }
}

- (IBAction)infoPressed:(id)sender {
    
        //[self showNotificationAlert];
    
    PantsSettingsViewController *settingsVc = (PantsSettingsViewController*)[[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"pantsSettingsView"];
    
    settingsVc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:settingsVc animated:YES completion:nil];
    
}











#pragma mark NSURLConnection Delegate Methods


-(void)getWeatherForLat:(NSString*)lat andLon:(NSString*)lon{
    NSString *path = [NSString stringWithFormat:@"https://api.forecast.io/forecast/%@/%@,%@",WEATHER_API_KEY,lat,lon];
    // Create url connection and fire request
    currentConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:path]] delegate:self];
    
}


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

- (void)setBeltBuckleTextWithTop:(NSString*)topString middle:(NSString*)middle andBottom:(NSString*)bottom{
    self.topTimerLabel.text = topString;
    self.middleTimerLabel.text = middle;
    self.bottomTimerLabel.text = bottom;
    self.topDotsTimerLabel.text = @"•••••";
    self.bottomDotsTimerLabel.text = @"•••••";
    
}

- (UIImageView*)beltView{
    if(_beltView) return _beltView;
    
    self.beltBuckleView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [self widthFromRatio:.4828125], [self heightFromRatio:.144366197])];
    [self.beltBuckleView setBackgroundColor:DEFAULT_BROWN_COLOR];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:self.beltBuckleView.bounds];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = path.CGPath;
    self.beltBuckleView.layer.mask = maskLayer;
    
    UIImageView *innerCircleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.beltBuckleView.width-12, self.beltBuckleView.height-12)];
    [innerCircleImageView setBackgroundColor:DEFAULT_OFFWHITE_COLOR];
    innerCircleImageView.layer.cornerRadius = innerCircleImageView.height/2;

    UIBezierPath *path2 = [UIBezierPath bezierPathWithOvalInRect:innerCircleImageView.bounds];
    CAShapeLayer *maskLayer2 = [CAShapeLayer layer];
    maskLayer2.path = path2.CGPath;
    innerCircleImageView.layer.mask = maskLayer2;
    
//    CGContextSaveGState(theCGContext);
//    CGPoint center = CGPointMake(circleImageView.width / 2.0, y + height / 2.0);
//    UIBezierPath* clip = [UIBezierPath bezierPathWithArcCenter:center
//                                                        radius:max(width, height)
//                                                    startAngle:startAngle
//                                                      endAngle:endAngle
//                                                     clockwise:YES];
//    [clip addLineToPoint:center];
//    [clip closePath];
//    [clip addClip];
//    
//    UIBezierPath *arc = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x, y, width, height)];
//    [[UIColor blackColor] setStroke];
//    [arc stroke];
//    
//    CGContextRestoreGState(theCGContext);

    [self.beltBuckleView addSubview:innerCircleImageView];
    
    UIImageView *beltLine = [[UIImageView alloc] initWithFrame:CGRectMake([self widthFromRatio:0.0671875], 0, [self widthFromRatio:0.9546875-0.0671875], [self heightFromRatio:0.02728873239])];
    beltLine.backgroundColor = DEFAULT_COPPER_COLOR;
    _beltView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.beltBuckleView.height)];
    self.beltBuckleView.center = CGPointMake(_beltView.centerX, _beltView.height/2);
    innerCircleImageView.center = CGPointMake(self.beltBuckleView.width/2, self.beltBuckleView.height/2);
    beltLine.center = CGPointMake(_beltView.centerX, _beltView.height/2);
    [_beltView addSubview:beltLine];
    [_beltView addSubview:self.beltBuckleView];
    
    
    self.middleTimerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.beltBuckleView.width, 32)];
    [self.middleTimerLabel setNumberOfLines:1];
    [self.middleTimerLabel setTextAlignment:NSTextAlignmentCenter];
    self.middleTimerLabel.center = CGPointMake(self.beltBuckleView.width/2, self.beltBuckleView.height/2);
    [self.middleTimerLabel setTextColor:DEFAULT_BLUE_COLOR];
    [self.middleTimerLabel setFont:[UIFont fontWithName:CABIN_FONT_BOLD size:32]];
    [self.beltBuckleView addSubview:self.middleTimerLabel];
    
    self.topDotsTimerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.beltBuckleView.width, 18)];
    [self.topDotsTimerLabel setNumberOfLines:1];
    [self.topDotsTimerLabel setTextAlignment:NSTextAlignmentCenter];
    self.topDotsTimerLabel.centerX = self.middleTimerLabel.centerX;
    self.topDotsTimerLabel.bottom = self.middleTimerLabel.top+5;
    [self.topDotsTimerLabel setTextColor:DEFAULT_BROWN_COLOR];
    [self.topDotsTimerLabel setFont:[UIFont fontWithName:CABIN_FONT_BOLD size:18]];
    [self.beltBuckleView addSubview:self.topDotsTimerLabel];
    
    self.topTimerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.beltBuckleView.width, 14)];
    [self.topTimerLabel setNumberOfLines:1];
    [self.topTimerLabel setTextAlignment:NSTextAlignmentCenter];
    self.topTimerLabel.centerX = self.middleTimerLabel.centerX;
    self.topTimerLabel.bottom = self.topDotsTimerLabel.top+3;
    [self.topTimerLabel setTextColor:DEFAULT_BROWN_COLOR];
    [self.topTimerLabel setFont:[UIFont fontWithName:CABIN_FONT_REGULAR size:12]];
    [self.beltBuckleView addSubview:self.topTimerLabel];
    
    self.bottomDotsTimerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.beltBuckleView.width, 18)];
    [self.bottomDotsTimerLabel setNumberOfLines:1];
    [self.bottomDotsTimerLabel setTextAlignment:NSTextAlignmentCenter];
    self.bottomDotsTimerLabel.centerX = self.middleTimerLabel.centerX;
    self.bottomDotsTimerLabel.top = self.middleTimerLabel.bottom-5;
    [self.bottomDotsTimerLabel setTextColor:DEFAULT_BROWN_COLOR];
    [self.bottomDotsTimerLabel setFont:[UIFont fontWithName:CABIN_FONT_BOLD size:18]];
    [self.beltBuckleView addSubview:self.bottomDotsTimerLabel];
    
    self.bottomTimerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.beltBuckleView.width, 14)];
    [self.bottomTimerLabel setNumberOfLines:1];
    [self.bottomTimerLabel setTextAlignment:NSTextAlignmentCenter];
    self.bottomTimerLabel.centerX = self.middleTimerLabel.centerX;
    self.bottomTimerLabel.top = self.bottomDotsTimerLabel.bottom-3;
    [self.bottomTimerLabel setTextColor:DEFAULT_BROWN_COLOR];
    [self.bottomTimerLabel setFont:[UIFont fontWithName:CABIN_FONT_REGULAR size:12]];
    [self.beltBuckleView addSubview:self.bottomTimerLabel];
    
    
    if(self.view.height>568){
        self.topDotsTimerLabel.bottom = self.middleTimerLabel.top+8;
        self.topTimerLabel.bottom = self.topDotsTimerLabel.top+5;
        self.bottomDotsTimerLabel.top = self.middleTimerLabel.bottom-8;
        self.bottomTimerLabel.top = self.bottomDotsTimerLabel.bottom-5;
    }
    
    self.pantsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.pantsImageView.width, self.pantsImageView.height)];
    [self.pantsLabel setText:pantsString];
    [self.pantsLabel setNumberOfLines:0];
    [self.pantsLabel setTextColor:DEFAULT_LIGHT_BLUE_COLOR];
    [self.pantsLabel setTextAlignment:NSTextAlignmentCenter];
    [self.pantsLabel setCenterY:(self.pantsImageView.height/2)];
    [self.pantsLabel setCenterX:self.view.centerX];
    //[_beltView addSubview:self.pantsLabel];

    
    return _beltView;
}

- (UIImageView*)pantsImageView{
    if(_pantsImageView) return _pantsImageView;
    
    _pantsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width+5, self.view.height)];
    _pantsImageView.backgroundColor = DEFAULT_BLUE_COLOR;
    
    UIBezierPath *maskPath;
    
    maskPath = [UIBezierPath bezierPath];
    
    [maskPath moveToPoint:[self pointWithCoordinateRatioX:0.0859375 andY:0]];
    [maskPath addLineToPoint:[self pointWithCoordinateRatioX:0.9453125 andY:0]];
    [maskPath addLineToPoint:[self pointWithCoordinateRatioX:1.2484375 andY:0.9718309859]];
    [maskPath addLineToPoint:[self pointWithCoordinateRatioX:0.909375 andY:1.036091549]];
    [maskPath addLineToPoint:[self pointWithCoordinateRatioX:0.521875 andY:0.301056338]];
    [maskPath addLineToPoint:[self pointWithCoordinateRatioX:0.128125 andY:1.036091549]];
    [maskPath addLineToPoint:[self pointWithCoordinateRatioX:-0.23125 andY:0.9718309859]];
    [maskPath closePath];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = _pantsImageView.bounds;
    maskLayer.path = maskPath.CGPath;
    _pantsImageView.layer.mask = maskLayer;
    
    return _pantsImageView;
}

- (float)widthFromRatio:(float)ratio{
    return ratio*self.view.width;
}

- (float)heightFromRatio:(float)ratio{
    return ratio*self.view.height;
}

- (CGPoint)pointWithCoordinateRatioX:(float)x andY:(float)y{
    return CGPointMake(x*self.view.width, y*self.view.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
