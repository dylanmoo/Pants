//
//  APIClient.m
//  Raft
//
//  Created by Dylan Moore on 6/9/13.
//  Copyright (c) 2013 Raft. All rights reserved.
//

#import "APIClient.h"
#import "AFHTTPRequestOperation.h"
#import "CoreDataStore.h"
#import "Mixpanel.h"

@interface APIClient ()

@end

@implementation APIClient

+ (APIClient *)sharedClient
{
    static APIClient *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kPantsBaseURL]];
    });
    return _sharedClient;
}

-(id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    NSLog(@"Build Number: %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]);
    
    
    return self;
}

-(void)updateDeviceToken:(NSData *)token{
    if(token){
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        // Make sure identify has been called before sending
        // a device token.
        // This sends the deviceToken to Mixpanel
        [mixpanel.people addPushDeviceToken:token];
        
        [mixpanel track:@"SIGNUP-Updating Device Token" properties:nil];
        
        NSString *path = [NSString stringWithFormat:@"users/%@/sns_endpoints",[[PantsStore sharedStore] userID]];
        
        
        const unsigned *tokenBytes = [token bytes];
        NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                              ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                              ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                              ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
        NSLog(@"Updating Device Token: %@",hexToken);
        
        NSDictionary *userDic = [[NSDictionary alloc] initWithObjectsAndKeys:hexToken,@"device_token",[[PantsStore sharedStore] userID],@"user_id", nil];
        
        
        NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:userDic,@"sns_endpoint", nil];
        
        
        [self POST:path parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
            // NSLog(@"JSON from Blocking user: %@",JSON);
            // Load Information on to the Main User
            NSLog(@"Confirming user has updated device token");
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Not updating device token for user: %@", error.description);
        }];
        
    }
}

@end
