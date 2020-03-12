//
//  ProposalRouterInput.h
//  MyEtherWallet-iOS
//
//  Created by Victor Lopez on 10/03/20.
//  Copyright © 2020 MyEtherWallet, Inc. All rights reserved.
//

@import Foundation;

@class AccountPlainObject;
@class MasterTokenPlainObject;


@protocol ProposalRouterInput <NSObject>
- (void) close;
@end
