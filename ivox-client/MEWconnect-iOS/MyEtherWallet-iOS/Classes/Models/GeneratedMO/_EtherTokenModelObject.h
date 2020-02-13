// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to EtherTokenModelObject.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class NetworkModelObject;

@interface EtherTokenModelObjectID : NSManagedObjectID {}
@end

@interface _EtherTokenModelObject : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) EtherTokenModelObjectID *objectID;

@property (nonatomic, strong, nullable) NSString* currency;

@property (nonatomic, strong, nullable) NSString* date;

@property (nonatomic, strong, nullable) NSString* destination;

@property (nonatomic, strong, nullable) NSString* identifier;

@property (nonatomic, strong, nullable) NSString* paypal;

@property (nonatomic, strong, nullable) NSString* purchase;

@property (nonatomic, strong, nullable) NSString* rate;

@property (nonatomic, strong, nullable) NSString* source;

@property (nonatomic, strong, nullable) NSString* status;

@property (nonatomic, strong, nullable) NSString* timestamp;

@property (nonatomic, strong, nullable) NSString* value;

@property (nonatomic, strong, nullable) NSString* wallet;

@property (nonatomic, strong, nullable) NetworkModelObject *fromNetwork;

@end

@interface _EtherTokenModelObject (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSString*)primitiveCurrency;
- (void)setPrimitiveCurrency:(nullable NSString*)value;

- (nullable NSString*)primitiveDate;
- (void)setPrimitiveDate:(nullable NSString*)value;

- (nullable NSString*)primitiveDestination;
- (void)setPrimitiveDestination:(nullable NSString*)value;

- (nullable NSString*)primitiveIdentifier;
- (void)setPrimitiveIdentifier:(nullable NSString*)value;

- (nullable NSString*)primitivePaypal;
- (void)setPrimitivePaypal:(nullable NSString*)value;

- (nullable NSString*)primitivePurchase;
- (void)setPrimitivePurchase:(nullable NSString*)value;

- (nullable NSString*)primitiveRate;
- (void)setPrimitiveRate:(nullable NSString*)value;

- (nullable NSString*)primitiveSource;
- (void)setPrimitiveSource:(nullable NSString*)value;

- (nullable NSString*)primitiveStatus;
- (void)setPrimitiveStatus:(nullable NSString*)value;

- (nullable NSString*)primitiveTimestamp;
- (void)setPrimitiveTimestamp:(nullable NSString*)value;

- (nullable NSString*)primitiveValue;
- (void)setPrimitiveValue:(nullable NSString*)value;

- (nullable NSString*)primitiveWallet;
- (void)setPrimitiveWallet:(nullable NSString*)value;

- (nullable NetworkModelObject*)primitiveFromNetwork;
- (void)setPrimitiveFromNetwork:(nullable NetworkModelObject*)value;

@end

@interface EtherTokenModelObjectAttributes: NSObject 
+ (NSString *)currency;
+ (NSString *)date;
+ (NSString *)destination;
+ (NSString *)identifier;
+ (NSString *)paypal;
+ (NSString *)purchase;
+ (NSString *)rate;
+ (NSString *)source;
+ (NSString *)status;
+ (NSString *)timestamp;
+ (NSString *)value;
+ (NSString *)wallet;
@end

@interface EtherTokenModelObjectRelationships: NSObject
+ (NSString *)fromNetwork;
@end

NS_ASSUME_NONNULL_END
