//
//  ProfileModuleInput.h
//  MyEtherWallet-iOS
//
//  Created by Victor Lopez on 17/01/20.
//  Copyright © 2020 MyEtherWallet, Inc. All rights reserved.
//

@import Foundation;
@import ViperMcFlurryX;


@class AccountPlainObject;
@class MasterTokenPlainObject;

@protocol ProposalsModuleInput <RamblerViperModuleInput>
- (void) configureModuleWithAccountAndMasterToken:(AccountPlainObject *)account masterToken:(MasterTokenPlainObject*)masterToken;
@end
