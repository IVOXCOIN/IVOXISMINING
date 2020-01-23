//
//  _Account.h
//
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
//

@import Foundation;

@class NetworkPlainObject;

@interface _AccountPlainObject : NSObject <NSCoding, NSCopying>

@property (nonatomic, copy, readwrite) NSNumber *active;
@property (nonatomic, copy, readwrite) NSString *address;
@property (nonatomic, copy, readwrite) NSNumber *backedUp;
@property (nonatomic, copy, readwrite) NSString *balanceMethod;
@property (nonatomic, copy, readwrite) NSString *card;
@property (nonatomic, copy, readwrite) NSString *country;
@property (nonatomic, copy, readwrite) NSString *currency;
@property (nonatomic, copy, readwrite) NSString *email;
@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, copy, readwrite) NSString *phone;
@property (nonatomic, copy, readwrite) NSString *uid;
@property (nonatomic, copy, readwrite) NSString *username;

@property (nonatomic, copy, readwrite) NSSet<NetworkPlainObject *> *networks;

@end