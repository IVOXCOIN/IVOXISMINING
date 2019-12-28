//
//  InfoInteractorInput.h
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 24/06/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

@import Foundation;

@class AccountPlainObject;

@protocol InfoInteractorInput <NSObject>
- (void) configureWithAccount:(AccountPlainObject *)account;
- (AccountPlainObject *) obtainAccount;
- (void) resetWallet;
- (void) passwordDidEntered:(NSString *)password;
- (BOOL) isBackupAvailable;
- (BOOL) isBackedUp;
- (void) accountBackedUp;
@end
