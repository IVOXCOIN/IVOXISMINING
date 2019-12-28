//
//  _Network.h
//
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
//

@import Foundation;

@class BalancePlainObject;
@class EtherTokenPlainObject;
@class AccountPlainObject;
@class IvoxTokenPlainObject;
@class MasterTokenPlainObject;
@class TokenPlainObject;

@interface _NetworkPlainObject : NSObject <NSCoding, NSCopying>

@property (nonatomic, copy, readwrite) NSNumber *active;
@property (nonatomic, copy, readwrite) NSNumber *chainID;

@property (nonatomic, copy, readwrite) NSSet<BalancePlainObject *> *balances;

@property (nonatomic, copy, readwrite) NSSet<EtherTokenPlainObject *> *etherTokens;

@property (nonatomic, copy, readwrite) AccountPlainObject *fromAccount;

@property (nonatomic, copy, readwrite) NSSet<IvoxTokenPlainObject *> *ivoxTokens;

@property (nonatomic, copy, readwrite) MasterTokenPlainObject *master;

@property (nonatomic, copy, readwrite) NSSet<TokenPlainObject *> *tokens;

@end