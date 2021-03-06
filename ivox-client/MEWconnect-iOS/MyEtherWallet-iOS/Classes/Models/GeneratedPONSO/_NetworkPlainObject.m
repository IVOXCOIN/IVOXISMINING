//
//  _NetworkPlainObject.m
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
//

#import "_NetworkPlainObject.h"
#import "NetworkPlainObject.h"

@implementation _NetworkPlainObject

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {

    [aCoder encodeObject:self.active forKey:@"active"];
    [aCoder encodeObject:self.chainID forKey:@"chainID"];
    [aCoder encodeObject:self.balances forKey:@"balances"];
    [aCoder encodeObject:self.etherTokens forKey:@"etherTokens"];
    [aCoder encodeObject:self.fromAccount forKey:@"fromAccount"];
    [aCoder encodeObject:self.ivoxTokens forKey:@"ivoxTokens"];
    [aCoder encodeObject:self.master forKey:@"master"];
    [aCoder encodeObject:self.tokens forKey:@"tokens"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self != nil) {

        _active = [[aDecoder decodeObjectForKey:@"active"] copy];
        _chainID = [[aDecoder decodeObjectForKey:@"chainID"] copy];
        _balances = [[aDecoder decodeObjectForKey:@"balances"] copy];
        _etherTokens = [[aDecoder decodeObjectForKey:@"etherTokens"] copy];
        _fromAccount = [[aDecoder decodeObjectForKey:@"fromAccount"] copy];
        _ivoxTokens = [[aDecoder decodeObjectForKey:@"ivoxTokens"] copy];
        _master = [[aDecoder decodeObjectForKey:@"master"] copy];
        _tokens = [[aDecoder decodeObjectForKey:@"tokens"] copy];
    }

    return self;
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
    NetworkPlainObject *replica = [[[self class] allocWithZone:zone] init];

    replica.active = self.active;
    replica.chainID = self.chainID;

    replica.balances = self.balances;
    replica.etherTokens = self.etherTokens;
    replica.fromAccount = self.fromAccount;
    replica.ivoxTokens = self.ivoxTokens;
    replica.master = self.master;
    replica.tokens = self.tokens;

    return replica;
}

@end
