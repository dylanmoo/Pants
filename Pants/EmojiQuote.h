//
//  EmojiQuote.h
//  Pants
//
//  Created by Dylan Moore on 2/23/15.
//  Copyright (c) 2015 Dylan Moore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmojiQuote : NSObject

- (id)initWithDictionary:(NSDictionary*)dictionary;

@property (strong, nonatomic) NSString *quote;
@property (strong, nonatomic) UIImage *emoji;

- (void)setEmojiWithString:(NSString*)imageName;
- (NSString*)stringForQuote;

@end
