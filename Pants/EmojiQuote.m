//
//  EmojiQuote.m
//  Pants
//
//  Created by Dylan Moore on 2/23/15.
//  Copyright (c) 2015 Dylan Moore. All rights reserved.
//

#import "EmojiQuote.h"

@implementation EmojiQuote

- (id)initWithDictionary:(NSDictionary*)dictionary{
    self = [super init];
    
    if(self){
        
        if([dictionary objectForKey:@"string"] && ([dictionary objectForKey:@"string"] != (id)[NSNull null])){
            self.quote = [dictionary objectForKey:@"string"];
        }
        
        if([dictionary objectForKey:@"animal_filename"] && ([dictionary objectForKey:@"animal_filename"] != (id)[NSNull null])){
            NSString *filename = [dictionary objectForKey:@"animal_filename"];
            [self setEmojiWithString:filename];
        }
        
    }
    
    return self;
}

- (void)setEmojiWithString:(NSString*)imageName{
    _emoji = [UIImage imageNamed:imageName];
}

- (NSString*)stringForQuote{
    return [NSString stringWithFormat:@"\"%@\"",self.quote];
}

@end
