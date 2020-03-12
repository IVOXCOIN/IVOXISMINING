//
//  ProfileRouterInput.h
//  MyEtherWallet-iOS
//
//  Created by Victor Lopez on 17/01/20.
//  Copyright © 2020 MyEtherWallet, Inc. All rights reserved.
//

@import Foundation;

@class AccountPlainObject;
@class MasterTokenPlainObject;


@protocol ProposalsRouterInput <NSObject>
- (void) close;

- (void) openVoteWithAccountAndMasterToken:(AccountPlainObject *)account masterToken:(MasterTokenPlainObject*)masterToken voteBatch:(int)voteBatch;

@end
