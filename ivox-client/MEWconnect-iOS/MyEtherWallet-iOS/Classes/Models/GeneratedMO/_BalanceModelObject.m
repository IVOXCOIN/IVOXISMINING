// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BalanceModelObject.m instead.

#import "_BalanceModelObject.h"

@implementation BalanceModelObjectID
@end

@implementation _BalanceModelObject

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Balance" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Balance";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Balance" inManagedObjectContext:moc_];
}

- (BalanceModelObjectID*)objectID {
	return (BalanceModelObjectID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic total;

@dynamic fromNetwork;

@end

@implementation BalanceModelObjectAttributes 
+ (NSString *)total {
	return @"total";
}
@end

@implementation BalanceModelObjectRelationships 
+ (NSString *)fromNetwork {
	return @"fromNetwork";
}
@end

