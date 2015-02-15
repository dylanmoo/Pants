//
//  CoreDataStore.h
//  LetsAt
//
//  Created by Dylan Moore on 1/24/14.
//  Copyright (c) 2014 Dylan Moore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataStore : NSObject {
    //@public NSManagedObjectContext *context;
    //    NSManagedObjectModel *model;
@public NSDate *sessionStart;
@public NSString *baseURL;
@public NSString *version;
@public NSString *source;
@public NSString *baseURLVersion;
@public NSString *baseURLWithVersion;
    
}

+ (CoreDataStore *)sharedStore;

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectContext *backgroundWritingContext;
@property (readonly, strong, nonatomic) NSManagedObjectContext *backgroundOpContext;
@property (readonly, strong, nonatomic) NSManagedObjectContext *mainContext;
@property (strong, nonatomic) NSOperationQueue *opQueue;

- (void)saveContext:(BOOL)wait;

@end