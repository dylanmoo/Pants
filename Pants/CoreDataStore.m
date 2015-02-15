//
//  CoreDataStore.m
//  LetsAt
//
//  Created by Dylan Moore on 1/24/14.
//  Copyright (c) 2014 Dylan Moore. All rights reserved.
//

#import "PantsAppDelegate.h"
#import "CoreDataStore.h"
#import <CoreData/CoreData.h>

@implementation CoreDataStore

@synthesize backgroundWritingContext = _backgroundWritingContext;
@synthesize backgroundOpContext = _backgroundOpContext;
@synthesize mainContext = _mainContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize opQueue = _opQueue;

NSString *dataModelName = @"PantsDataModel";

#pragma mark Initialization
+ (CoreDataStore *)sharedStore
{
    static CoreDataStore *store = nil;
    
    if (!store) {
        store = [[super allocWithZone:nil] init];
        
    }
    
    return store;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

- (id)init
{
    self = [super init];
    
    if (self) {
        [self initCoreDataStack];
        self.opQueue = [[NSOperationQueue alloc] init];
    }
    
    return self;
}

-(void)initCoreDataStack{
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        
        _mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_mainContext setPersistentStoreCoordinator:coordinator];
        
        _backgroundOpContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _backgroundOpContext.parentContext = _mainContext;
        
    }
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:dataModelName withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}


- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSString *dataModelURL = [NSString stringWithFormat:@"%@.sqlite",dataModelName];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:dataModelURL];
    
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES
                              };
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil
                                                             URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (void)saveContext:(BOOL)wait{
    NSManagedObjectContext *moc = self.mainContext;
    //NSManagedObjectContext *private = self.backgroundWritingContext;
    
    if(!moc)return;
    if([moc hasChanges]){
        [moc performBlockAndWait:^{
            NSError *error = nil;
            if(![moc save:&error]){
                NSLog(@"unresolved error saving moc %@",error.userInfo);
            }
        }];
    }
    /*
    void (^savePrivate) (void) = ^{
        NSError *error = nil;
        if(![private save:&error]){
            NSLog(@"unresolved error saving private oc %@",error.userInfo);
        }
    };
    
    if ([private hasChanges]) {
        if (wait) {
            [private performBlockAndWait:savePrivate];
        }else{
            [private performBlock:savePrivate];
        }
    }
     */
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end

