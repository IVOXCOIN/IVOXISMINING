//
//  TransfersPresenter.m
//  MyEtherWallet-iOS
//
//  Created by Victor Lopez on 31/12/19.
//  Copyright © 2019 MyEtherWallet, Inc. All rights reserved.
//

#import "TransfersPresenter.h"

#import "TransfersViewInput.h"

#import "AccountModelObject.h"
#import "MasterTokenModelObject.h"


@interface TransfersPresenter ()
@end

@implementation TransfersPresenter

#pragma mark - TransfersModuleInput
- (void) configureModuleWithAccountAndMasterToken:(AccountPlainObject *)account masterToken:(MasterTokenPlainObject*)masterToken{
    
    self.view.account = account;
    self.view.masterToken = masterToken;
    
}

@end
