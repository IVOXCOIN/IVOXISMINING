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

NSString *const kKeychainServicePurchaseUserIdField         = @"userId";
NSString *const kKeychainServicePurchaseDateField           = @"date";

//Current version
NSString *const kKeychainServiceCurrentKeychainVersionField = @"version";
NSInteger const kKeychainServiceCurrentKeychainVersionValue = 2;

NSString *const kKeychainServiceBruteForceLockDateField     = @"com.myetherwallet.bruteforce.lockdate";
NSString *const kKeychainServiceBruteForceNumberOfAttempts  = @"com.myetherwallet.bruteforce.attempts";

NSString *const kKeychainServiceWhatsNewVersionField        = @"com.myetherwallet.mewconnect.whatsnew.version";
