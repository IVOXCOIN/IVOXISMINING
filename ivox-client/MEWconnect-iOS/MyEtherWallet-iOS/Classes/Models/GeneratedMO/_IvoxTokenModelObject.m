// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to IvoxTokenModelObject.m instead.

#import "_IvoxTokenModelObject.h"

@implementation IvoxTokenModelObjectID
@end

@implementation _IvoxTokenModelObject

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"IvoxToken" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"IvoxToken";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"IvoxToken" inManagedObjectContext:moc_];
}

- (IvoxTokenModelObjectID*)objectID {
	return (IvoxTokenModelObjectID*)[super objectID];
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

@dynamic value;

@dynamic wallet;

@end

@implementation IvoxTokenModelObjectAttributes 
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
+ (NSString *)value {
	return @"value";
}
+ (NSString *)wallet {
	return @"wallet";
}
@end

