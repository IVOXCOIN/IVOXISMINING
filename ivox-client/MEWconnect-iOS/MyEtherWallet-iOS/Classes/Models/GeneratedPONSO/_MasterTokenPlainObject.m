//
//  _MasterTokenPlainObject.m
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
//

#import "_MasterTokenPlainObject.h"
#import "MasterTokenPlainObject.h"

@implementation _MasterTokenPlainObject

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {

    [aCoder encodeObject:self.fromNetworkMaster forKey:@"fromNetworkMaster"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self != nil) {

        _fromNetworkMaster = [[aDecoder decodeObjectForKey:@"fromNetworkMaster"] copy];
    }

    return self;
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
    MasterTokenPlainObject *replica = [[[self class] allocWithZone:zone] init];

    replica.fromNetworkMaster = self.fromNetworkMaster;

    return replica;
}

@end
