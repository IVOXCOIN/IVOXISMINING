//
//  TransfersModuleInput.h
//  MyEtherWallet-iOS
//
//  Created by Victor Lopez on 31/12/19.
//  Copyright © 2019 MyEtherWallet, Inc. All rights reserved.
//

@import Foundation;
@import ViperMcFlurryX;


@class AccountPlainObject;
@class MasterTokenPlainObject;

@protocol TransfersModuleInput <RamblerViperModuleInput>
- (void) configureModuleWithAccountAndMasterToken:(AccountPlainObject *)account masterToken:(MasterTokenPlainObject*)masterToken;
@end
