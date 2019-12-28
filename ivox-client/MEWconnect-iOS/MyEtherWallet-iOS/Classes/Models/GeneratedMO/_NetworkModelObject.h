// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to NetworkModelObject.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class BalanceModelObject;
@class EtherTokenModelObject;
@class AccountModelObject;
@class IvoxTokenModelObject;
@class MasterTokenModelObject;
@class TokenModelObject;

@interface NetworkModelObjectID : NSManagedObjectID {}
@end

@interface _NetworkModelObject : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) NetworkModelObjectID *objectID;

@property (nonatomic, strong, nullable) NSNumber* active;

@property (atomic) BOOL activeValue;
- (BOOL)activeValue;
- (void)setActiveValue:(BOOL)value_;

@property (nonatomic, strong, nullable) NSNumber* chainID;

@property (atomic) int64_t chainIDValue;
- (int64_t)chainIDValue;
- (void)setChainIDValue:(int64_t)value_;

@property (nonatomic, strong, nullable) NSSet<BalanceModelObject*> *balances;
- (nullable NSMutableSet<BalanceModelObject*>*)balancesSet;

@property (nonatomic, strong, nullable) NSSet<EtherTokenModelObject*> *etherTokens;
- (nullable NSMutableSet<EtherTokenModelObject*>*)etherTokensSet;

@property (nonatomic, strong, nullable) AccountModelObject *fromAccount;

@property (nonatomic, strong, nullable) NSSet<IvoxTokenModelObject*> *ivoxTokens;
- (nullable NSMutableSet<IvoxTokenModelObject*>*)ivoxTokensSet;

@property (nonatomic, strong) MasterTokenModelObject *master;

@property (nonatomic, strong, nullable) NSSet<TokenModelObject*> *tokens;
- (nullable NSMutableSet<TokenModelObject*>*)tokensSet;

@end

@interface _NetworkModelObject (BalancesCoreDataGeneratedAccessors)
- (void)addBalances:(NSSet<BalanceModelObject*>*)value_;
- (void)removeBalances:(NSSet<BalanceModelObject*>*)value_;
- (void)addBalancesObject:(BalanceModelObject*)value_;
- (void)removeBalancesObject:(BalanceModelObject*)value_;

@end

@interface _NetworkModelObject (EtherTokensCoreDataGeneratedAccessors)
- (void)addEtherTokens:(NSSet<EtherTokenModelObject*>*)value_;
- (void)removeEtherTokens:(NSSet<EtherTokenModelObject*>*)value_;
- (void)addEtherTokensObject:(EtherTokenModelObject*)value_;
- (void)removeEtherTokensObject:(EtherTokenModelObject*)value_;

@end

@interface _NetworkModelObject (IvoxTokensCoreDataGeneratedAccessors)
- (void)addIvoxTokens:(NSSet<IvoxTokenModelObject*>*)value_;
- (void)removeIvoxTokens:(NSSet<IvoxTokenModelObject*>*)value_;
- (void)addIvoxTokensObject:(IvoxTokenModelObject*)value_;
- (void)removeIvoxTokensObject:(IvoxTokenModelObject*)value_;

@end

@interface _NetworkModelObject (TokensCoreDataGeneratedAccessors)
- (void)addTokens:(NSSet<TokenModelObject*>*)value_;
- (void)removeTokens:(NSSet<TokenModelObject*>*)value_;
- (void)addTokensObject:(TokenModelObject*)value_;
- (void)removeTokensObject:(TokenModelObject*)value_;

@end

@interface _NetworkModelObject (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSNumber*)primitiveActive;
- (void)setPrimitiveActive:(nullable NSNumber*)value;

- (BOOL)primitiveActiveValue;
- (void)setPrimitiveActiveValue:(BOOL)value_;

- (nullable NSNumber*)primitiveChainID;
- (void)setPrimitiveChainID:(nullable NSNumber*)value;

- (int64_t)primitiveChainIDValue;
- (void)setPrimitiveChainIDValue:(int64_t)value_;

- (NSMutableSet<BalanceModelObject*>*)primitiveBalances;
- (void)setPrimitiveBalances:(NSMutableSet<BalanceModelObject*>*)value;

- (NSMutableSet<EtherTokenModelObject*>*)primitiveEtherTokens;
- (void)setPrimitiveEtherTokens:(NSMutableSet<EtherTokenModelObject*>*)value;

- (nullable AccountModelObject*)primitiveFromAccount;
- (void)setPrimitiveFromAccount:(nullable AccountModelObject*)value;

- (NSMutableSet<IvoxTokenModelObject*>*)primitiveIvoxTokens;
- (void)setPrimitiveIvoxTokens:(NSMutableSet<IvoxTokenModelObject*>*)value;

- (MasterTokenModelObject*)primitiveMaster;
- (void)setPrimitiveMaster:(MasterTokenModelObject*)value;

- (NSMutableSet<TokenModelObject*>*)primitiveTokens;
- (void)setPrimitiveTokens:(NSMutableSet<TokenModelObject*>*)value;

@end

@interface NetworkModelObjectAttributes: NSObject 
+ (NSString *)active;
+ (NSString *)chainID;
@end

@interface NetworkModelObjectRelationships: NSObject
+ (NSString *)balances;
+ (NSString *)etherTokens;
+ (NSString *)fromAccount;
+ (NSString *)ivoxTokens;
+ (NSString *)master;
+ (NSString *)tokens;
@end

NS_ASSUME_NONNULL_END
