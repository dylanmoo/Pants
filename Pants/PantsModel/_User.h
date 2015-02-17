// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.h instead.

#import <CoreData/CoreData.h>

extern const struct UserAttributes {
	__unsafe_unretained NSString *user_id;
	__unsafe_unretained NSString *weather_notification_date;
} UserAttributes;

@interface UserID : NSManagedObjectID {}
@end

@interface _User : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) UserID* objectID;

@property (nonatomic, strong) NSString* user_id;

//- (BOOL)validateUser_id:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* weather_notification_date;

//- (BOOL)validateWeather_notification_date:(id*)value_ error:(NSError**)error_;

@end

@interface _User (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveUser_id;
- (void)setPrimitiveUser_id:(NSString*)value;

- (NSDate*)primitiveWeather_notification_date;
- (void)setPrimitiveWeather_notification_date:(NSDate*)value;

@end
