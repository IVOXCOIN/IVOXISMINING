//
//  InfoModuleInput.h
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 24/06/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

@import Foundation;
@import ViperMcFlurryX;

@class AccountPlainObject;
@class MasterTokenPlainObject;

@protocol TokensModuleInput <RamblerViperModuleInput>
- (void) configureModuleWithAccountAndMasterToken:(AccountPlainObject *)account masterToken:(MasterTokenPlainObject*)masterToken isEther:(BOOL)isEther;
@end
