//
//  _BalancePlainObject.m
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
//

#import "_BalancePlainObject.h"
#import "BalancePlainObject.h"

@implementation _BalancePlainObject

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {

    [aCoder encodeObject:self.total forKey:@"total"];
    [aCoder encodeObject:self.fromNetwork forKey:@"fromNetwork"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self != nil) {

        _total = [[aDecoder decodeObjectForKey:@"total"] copy];
        _fromNetwork = [[aDecoder decodeObjectForKey:@"fromNetwork"] copy];
    }

    return self;
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
    BalancePlainObject *replica = [[[self class] allocWithZone:zone] init];

    replica.total = self.total;

    replica.fromNetwork = self.fromNetwork;

    return replica;
}

@end
