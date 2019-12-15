// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BalanceModelObject.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class NetworkModelObject;

@interface BalanceModelObjectID : NSManagedObjectID {}
@end

@interface _BalanceModelObject : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) BalanceModelObjectID *objectID;

@property (nonatomic, strong, nullable) NSDecimalNumber* total;

@property (nonatomic, strong, nullable) NetworkModelObject *fromNetwork;

@end

@interface _BalanceModelObject (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSDecimalNumber*)primitiveTotal;
- (void)setPrimitiveTotal:(nullable NSDecimalNumber*)value;

- (nullable NetworkModelObject*)primitiveFromNetwork;
- (void)setPrimitiveFromNetwork:(nullable NetworkModelObject*)value;

@end

@interface BalanceModelObjectAttributes: NSObject 
+ (NSString *)total;
@end

@interface BalanceModelObjectRelationships: NSObject
+ (NSString *)fromNetwork;
@end

NS_ASSUME_NONNULL_END
