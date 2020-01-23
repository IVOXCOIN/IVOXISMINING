//
//  AccountsService.h
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 27/06/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

@import Foundation;

@class AccountModelObject;
@class AccountPlainObject;
@class NetworkPlainObject;

typedef void(^AccountsServiceCompletionBlock)(NSError *error);
typedef void(^AccountsServiceCreateCompletionBlock)(AccountModelObject *accountModelObject);

@protocol AccountsService <NSObject>
- (AccountModelObject *) obtainAccountWithAccount:(AccountPlainObject *)account;
- (AccountModelObject *) obtainActiveAccount;
- (AccountModelObject *) obtainOrCreateActiveAccount;
- (void) resetAccounts;
- (NSString *) getCurrency:(AccountPlainObject *)account;
- (void) setCurrency:(AccountPlainObject *)account currency:(NSString *)currencyString;
- (NSString *) getBalanceMethod:(AccountPlainObject *)account;
- (void) setBalanceMethod:(AccountPlainObject *)account balanceMethod:(NSString *)method;

- (NSString *) getUsername:(AccountPlainObject *)account;
- (void) setUsername:(AccountPlainObject *)account username:(NSString *)username;

- (NSString *) getEmail:(AccountPlainObject *)account;
- (void) setEmail:(AccountPlainObject *)account email:(NSString *)email;

- (NSString *) getPhone:(AccountPlainObject *)account;
- (void) setPhone:(AccountPlainObject *)account phone:(NSString *)phone;

- (NSString *) getAddress:(AccountPlainObject *)account;
- (void) setAddress:(AccountPlainObject *)account address:(NSString *)address;

- (NSString *) getCountry:(AccountPlainObject *)account;
- (void) setCountry:(AccountPlainObject *)account country:(NSString *)country;

- (NSString *) getCard:(AccountPlainObject *)account;
- (void) setCard:(AccountPlainObject *)account card:(NSString *)card;


- (void) accountBackedUp:(AccountPlainObject *)account;
- (void) deleteAccount:(AccountPlainObject *)account;
@end
