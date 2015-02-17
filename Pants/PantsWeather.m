//
//  PantsWeather.m
//  Pants
//
//  Created by Dylan Moore on 2/16/15.
//  Copyright (c) 2015 Dylan Moore. All rights reserved.
//

#import "PantsWeather.h"

@implementation PantsWeather

- (id)initWithDictionary:(NSDictionary*)dictionary{
    self = [super init];
    
    if(self){
        
        if([dictionary objectForKey:@"no_pants_flavor_text"] && ([dictionary objectForKey:@"no_pants_flavor_text"] != (id)[NSNull null])){
            self.noPantsFlavorText = [dictionary objectForKey:@"no_pants_flavor_text"];
        }
        
        if([dictionary objectForKey:@"pants_flavor_text"] && ([dictionary objectForKey:@"pants_flavor_text"] != (id)[NSNull null])){
            self.pantsFlavorText = [dictionary objectForKey:@"pants_flavor_text"];
        }
        
        if([dictionary objectForKey:@"pants_at"] && ([dictionary objectForKey:@"pants_at"] != (id)[NSNull null])){
            self.pantsAtTime = [dictionary objectForKey:@"pants_at"];
        }
        
    }
    
    return self;
}



@end
