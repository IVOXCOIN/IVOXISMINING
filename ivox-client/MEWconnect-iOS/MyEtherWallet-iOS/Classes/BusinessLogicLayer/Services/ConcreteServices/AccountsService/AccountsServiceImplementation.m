//
//  AccountsServiceImplementation.m
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 27/06/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

@import MagicalRecord;

#import "OperationScheduler.h"
#import "CompoundOperationBase.h"

#import "MEWwallet.h"
#import "KeychainService.h"

#import "AccountsServiceImplementation.h"

#import "NetworkModelObject.h"
#import "NetworkPlainObject.h"
#import "AccountModelObject.h"
#import "AccountPlainObject.h"

@implementation AccountsServiceImplementation

- (AccountModelObject *) obtainAccountWithAccount:(AccountPlainObject *)account {
  NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
  return [AccountModelObject MR_findFirstByAttribute:NSStringFromSelector(@selector(uid)) withValue:account.uid inContext:context];
}

- (AccountModelObject *) obtainActiveAccount {
  NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
  //TODO: multi-account support
  return [AccountModelObject MR_findFirstByAttribute:NSStringFromSelector(@selector(active)) withValue:@YES inContext:context];
}

- (AccountModelObject *) obtainOrCreateActiveAccount {
  NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
  //TODO: multi-account support
  AccountModelObject *account = [AccountModelObject MR_findFirstByAttribute:NSStringFromSelector(@selector(active)) withValue:@YES inContext:context];
  if (!account) {
    account = [self _createNewAccountInContext:context];
  }
  return account;
}

- (NSArray<NSString *> *) bip32MnemonicsWords {
  return [self.MEWwallet obtainBIP32Words];
}

- (NSString *) getCurrency:(AccountPlainObject *)account{
    AccountModelObject *accountModelObject = [self obtainAccountWithAccount:account];
    return accountModelObject.currency;
}

- (void) setCurrency:(AccountPlainObject *)account currency:(NSString *)currencyString{
  [self.keychainService saveCurrency:currencyString forAccount:account];
  NSManagedObjectContext *rootSavingContext = [NSManagedObjectContext MR_rootSavingContext];
  [rootSavingContext performBlockAndWait:^{
    AccountModelObject *accountModelObject = [AccountModelObject MR_findFirstByAttribute:NSStringFromSelector(@selector(uid)) withValue:account.uid inContext:rootSavingContext];
    accountModelObject.currency = currencyString;
    [rootSavingContext MR_saveToPersistentStoreAndWait];
  }];
}

- (NSString *) getBalanceMethod:(AccountPlainObject *)account{
    AccountModelObject *accountModelObject = [self obtainAccountWithAccount:account];
    return accountModelObject.balanceMethod;
}

- (void) setBalanceMethod:(AccountPlainObject *)account balanceMethod:(NSString *)method{
  [self.keychainService saveBalanceMethod:method forAccount:account];
  NSManagedObjectContext *rootSavingContext = [NSManagedObjectContext MR_rootSavingContext];
  [rootSavingContext performBlockAndWait:^{
    AccountModelObject *accountModelObject = [AccountModelObject MR_findFirstByAttribute:NSStringFromSelector(@selector(uid)) withValue:account.uid inContext:rootSavingContext];
    accountModelObject.balanceMethod = method;
    [rootSavingContext MR_saveToPersistentStoreAndWait];
  }];
}


- (NSString *) getUsername:(AccountPlainObject *)account{
    AccountModelObject *accountModelObject = [self obtainAccountWithAccount:account];
    return accountModelObject.username;
}

- (void) setUsername:(AccountPlainObject *)account username:(NSString *)username{
  [self.keychainService saveUsername:username forAccount:account];
  NSManagedObjectContext *rootSavingContext = [NSManagedObjectContext MR_rootSavingContext];
  [rootSavingContext performBlockAndWait:^{
    AccountModelObject *accountModelObject = [AccountModelObject MR_findFirstByAttribute:NSStringFromSelector(@selector(uid)) withValue:account.uid inContext:rootSavingContext];
    accountModelObject.username = username;
    [rootSavingContext MR_saveToPersistentStoreAndWait];
  }];
}

- (NSString *) getEmail:(AccountPlainObject *)account{
    AccountModelObject *accountModelObject = [self obtainAccountWithAccount:account];
    return accountModelObject.email;
}

- (void) setEmail:(AccountPlainObject *)account email:(NSString *)email{
  [self.keychainService saveEmail:email forAccount:account];
  NSManagedObjectContext *rootSavingContext = [NSManagedObjectContext MR_rootSavingContext];
  [rootSavingContext performBlockAndWait:^{
    AccountModelObject *accountModelObject = [AccountModelObject MR_findFirstByAttribute:NSStringFromSelector(@selector(uid)) withValue:account.uid inContext:rootSavingContext];
    accountModelObject.email = email;
    [rootSavingContext MR_saveToPersistentStoreAndWait];
  }];
}

- (NSString *) getPhone:(AccountPlainObject *)account{
    AccountModelObject *accountModelObject = [self obtainAccountWithAccount:account];
    return accountModelObject.phone;
}


- (void) setPhone:(AccountPlainObject *)account phone:(NSString *)phone{
  [self.keychainService savePhone:phone forAccount:account];
  NSManagedObjectContext *rootSavingContext = [NSManagedObjectContext MR_rootSavingContext];
  [rootSavingContext performBlockAndWait:^{
    AccountModelObject *accountModelObject = [AccountModelObject MR_findFirstByAttribute:NSStringFromSelector(@selector(uid)) withValue:account.uid inContext:rootSavingContext];
    accountModelObject.phone = phone;
    [rootSavingContext MR_saveToPersistentStoreAndWait];
  }];
}

- (NSString *) getAddress:(AccountPlainObject *)account{
    AccountModelObject *accountModelObject = [self obtainAccountWithAccount:account];
    return accountModelObject.address;
}

- (void) setAddress:(AccountPlainObject *)account address:(NSString *)address{
  [self.keychainService saveAddress:address forAccount:account];
  NSManagedObjectContext *rootSavingContext = [NSManagedObjectContext MR_rootSavingContext];
  [rootSavingContext performBlockAndWait:^{
    AccountModelObject *accountModelObject = [AccountModelObject MR_findFirstByAttribute:NSStringFromSelector(@selector(uid)) withValue:account.uid inContext:rootSavingContext];
    accountModelObject.address = address;
    [rootSavingContext MR_saveToPersistentStoreAndWait];
  }];
}

- (NSString *) getCountry:(AccountPlainObject *)account{
    AccountModelObject *accountModelObject = [self obtainAccountWithAccount:account];
    return accountModelObject.address;
}

- (void) setCountry:(AccountPlainObject *)account country:(NSString *)country{
  [self.keychainService saveCountry:country forAccount:account];
  NSManagedObjectContext *rootSavingContext = [NSManagedObjectContext MR_rootSavingContext];
  [rootSavingContext performBlockAndWait:^{
    AccountModelObject *accountModelObject = [AccountModelObject MR_findFirstByAttribute:NSStringFromSelector(@selector(uid)) withValue:account.uid inContext:rootSavingContext];
    accountModelObject.country = country;
    [rootSavingContext MR_saveToPersistentStoreAndWait];
  }];
}

- (NSString *) getCard:(AccountPlainObject *)account{
    AccountModelObject *accountModelObject = [self obtainAccountWithAccount:account];
    return accountModelObject.address;
}

- (void) setCard:(AccountPlainObject *)account card:(NSString *)card{
  [self.keychainService saveCard:card forAccount:account];
  NSManagedObjectContext *rootSavingContext = [NSManagedObjectContext MR_rootSavingContext];
  [rootSavingContext performBlockAndWait:^{
    AccountModelObject *accountModelObject = [AccountModelObject MR_findFirstByAttribute:NSStringFromSelector(@selector(uid)) withValue:account.uid inContext:rootSavingContext];
    accountModelObject.card = card;
    [rootSavingContext MR_saveToPersistentStoreAndWait];
  }];
}

- (void) accountBackedUp:(AccountPlainObject *)account {
  [self.keychainService saveBackupStatus:YES forAccount:account];
  NSManagedObjectContext *rootSavingContext = [NSManagedObjectContext MR_rootSavingContext];
  [rootSavingContext performBlockAndWait:^{
    AccountModelObject *accountModelObject = [AccountModelObject MR_findFirstByAttribute:NSStringFromSelector(@selector(uid)) withValue:account.uid inContext:rootSavingContext];
    accountModelObject.backedUp = @YES;
    [rootSavingContext MR_saveToPersistentStoreAndWait];
  }];
}

- (void) deleteAccount:(AccountPlainObject *)account {
  [self.keychainService removeDataOfAccount:account];
  
  NSManagedObjectContext *rootSavingContext = [NSManagedObjectContext MR_rootSavingContext];
  [rootSavingContext performBlockAndWait:^{
    AccountModelObject *accountModelObject = [AccountModelObject MR_findFirstByAttribute:NSStringFromSelector(@selector(uid)) withValue:account.uid inContext:rootSavingContext];
    [accountModelObject MR_deleteEntity];
    [rootSavingContext MR_saveToPersistentStoreAndWait];
  }];
}

- (void) resetAccounts {
  NSManagedObjectContext *rootSavingContext = [NSManagedObjectContext MR_rootSavingContext];
  [rootSavingContext performBlockAndWait:^{
    NSArray <AccountModelObject *> *accounts = [AccountModelObject MR_findAllInContext:rootSavingContext];
    [rootSavingContext MR_deleteObjects:accounts];
    [rootSavingContext MR_saveToPersistentStoreAndWait];
  }];
}

#pragma mark - Private

- (AccountModelObject *) _createNewAccountInContext:(NSManagedObjectContext *)context {
  __block AccountModelObject *createdAccount = nil;
  NSManagedObjectContext *rootSavingContext = [NSManagedObjectContext MR_rootSavingContext];
  [rootSavingContext performBlockAndWait:^{
    AccountModelObject *accountModelObject = [AccountModelObject MR_createEntityInContext:rootSavingContext];
    accountModelObject.name = @"Account";
    accountModelObject.uid = [[NSUUID UUID] UUIDString];
    accountModelObject.active = @YES;
    accountModelObject.balanceMethod = @"IVOX";
    accountModelObject.currency = @"USD";
    [rootSavingContext MR_saveToPersistentStoreAndWait];
    
    createdAccount = [context objectWithID:accountModelObject.objectID];
  }];
  return createdAccount;
}

@end
