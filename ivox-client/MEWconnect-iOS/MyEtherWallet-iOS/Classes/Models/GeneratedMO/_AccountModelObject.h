// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to AccountModelObject.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class NetworkModelObject;

@interface AccountModelObjectID : NSManagedObjectID {}
@end

@interface _AccountModelObject : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) AccountModelObjectID *objectID;

@property (nonatomic, strong, nullable) NSNumber* active;

@property (atomic) BOOL activeValue;
- (BOOL)activeValue;
- (void)setActiveValue:(BOOL)value_;

@property (nonatomic, strong, nullable) NSString* address;

@property (nonatomic, strong, nullable) NSNumber* backedUp;

@property (atomic) BOOL backedUpValue;
- (BOOL)backedUpValue;
- (void)setBackedUpValue:(BOOL)value_;

@property (nonatomic, strong, nullable) NSString* balanceMethod;

@property (nonatomic, strong, nullable) NSString* card;

@property (nonatomic, strong, nullable) NSString* country;

@property (nonatomic, strong, nullable) NSString* currency;

@property (nonatomic, strong, nullable) NSString* email;

@property (nonatomic, strong, nullable) NSString* name;

@property (nonatomic, strong, nullable) NSString* phone;

@property (nonatomic, strong, nullable) NSString* uid;

@property (nonatomic, strong, nullable) NSString* username;

@property (nonatomic, strong, nullable) NSSet<NetworkModelObject*> *networks;
- (nullable NSMutableSet<NetworkModelObject*>*)networksSet;

@end

@interface _AccountModelObject (NetworksCoreDataGeneratedAccessors)
- (void)addNetworks:(NSSet<NetworkModelObject*>*)value_;
- (void)removeNetworks:(NSSet<NetworkModelObject*>*)value_;
- (void)addNetworksObject:(NetworkModelObject*)value_;
- (void)removeNetworksObject:(NetworkModelObject*)value_;

@end

@interface _AccountModelObject (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSNumber*)primitiveActive;
- (void)setPrimitiveActive:(nullable NSNumber*)value;

- (BOOL)primitiveActiveValue;
- (void)setPrimitiveActiveValue:(BOOL)value_;

- (nullable NSString*)primitiveAddress;
- (void)setPrimitiveAddress:(nullable NSString*)value;

- (nullable NSNumber*)primitiveBackedUp;
- (void)setPrimitiveBackedUp:(nullable NSNumber*)value;

- (BOOL)primitiveBackedUpValue;
- (void)setPrimitiveBackedUpValue:(BOOL)value_;

- (nullable NSString*)primitiveBalanceMethod;
- (void)setPrimitiveBalanceMethod:(nullable NSString*)value;

- (nullable NSString*)primitiveCard;
- (void)setPrimitiveCard:(nullable NSString*)value;

- (nullable NSString*)primitiveCountry;
- (void)setPrimitiveCountry:(nullable NSString*)value;

- (nullable NSString*)primitiveCurrency;
- (void)setPrimitiveCurrency:(nullable NSString*)value;

- (nullable NSString*)primitiveEmail;
- (void)setPrimitiveEmail:(nullable NSString*)value;

- (nullable NSString*)primitiveName;
- (void)setPrimitiveName:(nullable NSString*)value;

- (nullable NSString*)primitivePhone;
- (void)setPrimitivePhone:(nullable NSString*)value;

- (nullable NSString*)primitiveUid;
- (void)setPrimitiveUid:(nullable NSString*)value;

- (nullable NSString*)primitiveUsername;
- (void)setPrimitiveUsername:(nullable NSString*)value;

- (NSMutableSet<NetworkModelObject*>*)primitiveNetworks;
- (void)setPrimitiveNetworks:(NSMutableSet<NetworkModelObject*>*)value;

@end

@interface AccountModelObjectAttributes: NSObject 
+ (NSString *)active;
+ (NSString *)address;
+ (NSString *)backedUp;
+ (NSString *)balanceMethod;
+ (NSString *)card;
+ (NSString *)country;
+ (NSString *)currency;
+ (NSString *)email;
+ (NSString *)name;
+ (NSString *)phone;
+ (NSString *)uid;
+ (NSString *)username;
@end

@interface AccountModelObjectRelationships: NSObject
+ (NSString *)networks;
@end

NS_ASSUME_NONNULL_END
