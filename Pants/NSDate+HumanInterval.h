//
//  NSDate+HumanInterval.h
//  Buzzalot
//
//  Created by David E. Wheeler on 2/18/10.
//  Copyright 2010-2011 Lunar/Theory. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSDate (HumanInterval)
- (NSString *)humanIntervalSinceNow;
- (NSString *)humanIntervalAgoSinceNow;
- (NSString *)humanDaysAgoSinceNow;
@end

@interface NSDate (Util)
-(NSDate *) toLocalTime;
-(NSDate *) toGlobalTime;
@end

