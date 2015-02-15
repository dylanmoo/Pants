//
//  PantsStore.m
//  Pants
//
//  Created by Dylan Moore on 2/14/15.
//  Copyright (c) 2015 Dylan Moore. All rights reserved.
//

#import "PantsStore.h"
#import "User.h"

@interface PantsStore(){
    User *user;
}

@end

@implementation PantsStore

#pragma mark Initialization
+ (PantsStore *)sharedStore
{
    
    static PantsStore *store = nil;
    
    if (!store) {
        
        store = (PantsStore*)[super sharedStore];
        
    }
    
    return store;
}

-(id)init{
    self = [super init];
    
    if (self) {
        user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:self.mainContext];
        
        user = [self fetchUser];
        
        [self saveContext:NO];
    }
    return self;
    
}

- (User*)fetchUser{
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"User" inManagedObjectContext:self.mainContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setReturnsObjectsAsFaults:NO];
    
    NSError *Fetcherror;
    NSMutableArray *array = [[self.mainContext executeFetchRequest:request error:&Fetcherror] mutableCopy];
    
    if (array.count == 1) {
        // Update User with data from JSON
        return array[0];
    }else{
        return nil;
    }

}

- (NSString*)userID{
    return user.user_id;
}

@end
