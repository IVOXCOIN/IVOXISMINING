//
//  ProposalModuleInput.h
//  MyEtherWallet-iOS
//
//  Created by Victor Lopez on 10/03/20.
//  Copyright © 2020 MyEtherWallet, Inc. All rights reserved.
//

@import Foundation;
@import ViperMcFlurryX;


@class AccountPlainObject;
@class MasterTokenPlainObject;

@protocol ProposalModuleInput <RamblerViperModuleInput>
- (void) configureModuleWithAccountAndMasterToken:(AccountPlainObject *)account masterToken:(MasterTokenPlainObject*)masterToken voteBatch:(int)voteBatch;
@end
