//
//  PantsWeather.h
//  Pants
//
//  Created by Dylan Moore on 2/16/15.
//  Copyright (c) 2015 Dylan Moore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PantsWeather : NSObject

- (id)initWithDictionary:(NSDictionary*)dictionary;

@property (nonatomic, strong) NSNumber *pantsAtTime;
@property (nonatomic, strong) NSString *noPantsFlavorText;
@property (nonatomic, strong) NSString *pantsFlavorText;

@end
