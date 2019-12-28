//
//  _EtherTokenPlainObject.m
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
//

#import "_EtherTokenPlainObject.h"
#import "EtherTokenPlainObject.h"

@implementation _EtherTokenPlainObject

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {

    [aCoder encodeObject:self.currency forKey:@"currency"];
    [aCoder encodeObject:self.date forKey:@"date"];
    [aCoder encodeObject:self.destination forKey:@"destination"];
    [aCoder encodeObject:self.identifier forKey:@"identifier"];
    [aCoder encodeObject:self.paypal forKey:@"paypal"];
    [aCoder encodeObject:self.purchase forKey:@"purchase"];
    [aCoder encodeObject:self.rate forKey:@"rate"];
    [aCoder encodeObject:self.source forKey:@"source"];
    [aCoder encodeObject:self.status forKey:@"status"];
    [aCoder encodeObject:self.value forKey:@"value"];
    [aCoder encodeObject:self.wallet forKey:@"wallet"];
    [aCoder encodeObject:self.fromNetwork forKey:@"fromNetwork"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self != nil) {

        _currency = [[aDecoder decodeObjectForKey:@"currency"] copy];
        _date = [[aDecoder decodeObjectForKey:@"date"] copy];
        _destination = [[aDecoder decodeObjectForKey:@"destination"] copy];
        _identifier = [[aDecoder decodeObjectForKey:@"identifier"] copy];
        _paypal = [[aDecoder decodeObjectForKey:@"paypal"] copy];
        _purchase = [[aDecoder decodeObjectForKey:@"purchase"] copy];
        _rate = [[aDecoder decodeObjectForKey:@"rate"] copy];
        _source = [[aDecoder decodeObjectForKey:@"source"] copy];
        _status = [[aDecoder decodeObjectForKey:@"status"] copy];
        _value = [[aDecoder decodeObjectForKey:@"value"] copy];
        _wallet = [[aDecoder decodeObjectForKey:@"wallet"] copy];
        _fromNetwork = [[aDecoder decodeObjectForKey:@"fromNetwork"] copy];
    }

    return self;
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
    EtherTokenPlainObject *replica = [[[self class] allocWithZone:zone] init];

    replica.currency = self.currency;
    replica.date = self.date;
    replica.destination = self.destination;
    replica.identifier = self.identifier;
    replica.paypal = self.paypal;
    replica.purchase = self.purchase;
    replica.rate = self.rate;
    replica.source = self.source;
    replica.status = self.status;
    replica.value = self.value;
    replica.wallet = self.wallet;

    replica.fromNetwork = self.fromNetwork;

    return replica;
}

@end
