//
//  KeychainServiceSharedConstants.m
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 29/10/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

#import "KeychainServiceSharedConstants.h"

NSString *const kKeychainServiceFirstLaunchField            = @"firstLaunch";

NSString *const kKeychainServiceVersionField                = @"com.myetherwallet.keychain.version";

NSString *const kKeychainServiceEntropyField                = @"entropy";
NSString *const kKeychainServiceBackupField                 = @"backup";

NSString *const kKeychainServiceUsernameField = @"username";

NSString *const kKeychainServiceEmailField = @"email";

NSString *const kKeychainServicePhoneField = @"phone";

NSString *const kKeychainServiceAddressField = @"address";

NSString *const kKeychainServiceCountryField = @"country";

NSString *const kKeychainServiceCardField = @"card";

NSString *const kKeychainServiceCurrencyField               = @"currency";
NSString *const kKeychainServiceBalanceMethodField          = @"balanceMethod";

NSString *const kKeychainServicePurchaseUserIdField         = @"userId";
NSString *const kKeychainServicePurchaseDateField           = @"date";

//Current version
NSString *const kKeychainServiceCurrentKeychainVersionField = @"version";
NSInteger const kKeychainServiceCurrentKeychainVersionValue = 2;

NSString *const kKeychainServiceBruteForceLockDateField     = @"com.myetherwallet.bruteforce.lockdate";
NSString *const kKeychainServiceBruteForceNumberOfAttempts  = @"com.myetherwallet.bruteforce.attempts";

NSString *const kKeychainServiceWhatsNewVersionField        = @"com.myetherwallet.mewconnect.whatsnew.version";
