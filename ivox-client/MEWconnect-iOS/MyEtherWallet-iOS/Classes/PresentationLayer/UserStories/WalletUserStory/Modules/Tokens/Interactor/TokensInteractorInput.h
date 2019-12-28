//
//  InfoInteractorInput.h
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 24/06/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

@import Foundation;

@class AccountPlainObject;
@class MasterTokenPlainObject;

@protocol TokensInteractorInput <NSObject>
- (void) configureWithAccountAndMasterToken:(AccountPlainObject *)account masterToken:(MasterTokenPlainObject*)masterToken isEther:(BOOL)isEther;

-(MasterTokenPlainObject*) obtainMasterToken;

-(BOOL) isEther;

@end
