//
//  _AccountPlainObject.m
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
//

#import "_AccountPlainObject.h"
#import "AccountPlainObject.h"

@implementation _AccountPlainObject

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {

    [aCoder encodeObject:self.active forKey:@"active"];
    [aCoder encodeObject:self.address forKey:@"address"];
    [aCoder encodeObject:self.backedUp forKey:@"backedUp"];
    [aCoder encodeObject:self.balanceMethod forKey:@"balanceMethod"];
    [aCoder encodeObject:self.card forKey:@"card"];
    [aCoder encodeObject:self.country forKey:@"country"];
    [aCoder encodeObject:self.currency forKey:@"currency"];
    [aCoder encodeObject:self.email forKey:@"email"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.phone forKey:@"phone"];
    [aCoder encodeObject:self.uid forKey:@"uid"];
    [aCoder encodeObject:self.username forKey:@"username"];
    [aCoder encodeObject:self.networks forKey:@"networks"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self != nil) {

        _active = [[aDecoder decodeObjectForKey:@"active"] copy];
        _address = [[aDecoder decodeObjectForKey:@"address"] copy];
        _backedUp = [[aDecoder decodeObjectForKey:@"backedUp"] copy];
        _balanceMethod = [[aDecoder decodeObjectForKey:@"balanceMethod"] copy];
        _card = [[aDecoder decodeObjectForKey:@"card"] copy];
        _country = [[aDecoder decodeObjectForKey:@"country"] copy];
        _currency = [[aDecoder decodeObjectForKey:@"currency"] copy];
        _email = [[aDecoder decodeObjectForKey:@"email"] copy];
        _name = [[aDecoder decodeObjectForKey:@"name"] copy];
        _phone = [[aDecoder decodeObjectForKey:@"phone"] copy];
        _uid = [[aDecoder decodeObjectForKey:@"uid"] copy];
        _username = [[aDecoder decodeObjectForKey:@"username"] copy];
        _networks = [[aDecoder decodeObjectForKey:@"networks"] copy];
    }

    return self;
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
    AccountPlainObject *replica = [[[self class] allocWithZone:zone] init];

    replica.active = self.active;
    replica.address = self.address;
    replica.backedUp = self.backedUp;
    replica.balanceMethod = self.balanceMethod;
    replica.card = self.card;
    replica.country = self.country;
    replica.currency = self.currency;
    replica.email = self.email;
    replica.name = self.name;
    replica.phone = self.phone;
    replica.uid = self.uid;
    replica.username = self.username;

    replica.networks = self.networks;

    return replica;
}

@end
