//
//  DSMStore.h
//  Pants
//
//  Created by Dylan Moore on 9/2/14.
//  Copyright (c) 2014 Dylan Moore. All rights reserved.
//

@interface DSMStore : NSObject

/**
 * gets singleton object.
 * @return singleton
 */
+ (DSMStore*)sharedInstance;

- (BOOL)isFirstTimeUser;

@end
