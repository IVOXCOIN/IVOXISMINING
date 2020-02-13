// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to EtherTokenModelObject.m instead.

#import "_EtherTokenModelObject.h"

@implementation EtherTokenModelObjectID
@end

@implementation _EtherTokenModelObject

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"EtherToken" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"EtherToken";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"EtherToken" inManagedObjectContext:moc_];
}

- (EtherTokenModelObjectID*)objectID {
	return (EtherTokenModelObjectID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic currency;

@dynamic date;

@dynamic destination;

@dynamic identifier;

@dynamic paypal;

@dynamic purchase;

@dynamic rate;

@dynamic source;

@dynamic status;

@dynamic timestamp;

@dynamic value;

@dynamic wallet;

@dynamic fromNetwork;

@end

@implementation EtherTokenModelObjectAttributes 
+ (NSString *)currency {
	return @"currency";
}
+ (NSString *)date {
	return @"date";
}
+ (NSString *)destination {
	return @"destination";
}
+ (NSString *)identifier {
	return @"identifier";
}
+ (NSString *)paypal {
	return @"paypal";
}
+ (NSString *)purchase {
	return @"purchase";
}
+ (NSString *)rate {
	return @"rate";
}
+ (NSString *)source {
	return @"source";
}
+ (NSString *)status {
	return @"status";
}
+ (NSString *)timestamp {
	return @"timestamp";
}
+ (NSString *)value {
	return @"value";
}
+ (NSString *)wallet {
	return @"wallet";
}
@end

@implementation EtherTokenModelObjectRelationships 
+ (NSString *)fromNetwork {
	return @"fromNetwork";
}
@end

