//
//  APIClient.h
//  Raft
//
//  Created by Dylan Moore on 6/9/13.
//  Copyright (c) 2013 Raft. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"
#import "PantsStore.h"

@interface APIClient : AFHTTPRequestOperationManager

+ (APIClient *)sharedClient;

//USING

- (void)loginUser:(NSString*)token WithCompletion:(void (^)(NSError *error))block;

- (void)updateDeviceToken:(NSData*)token;

@end
