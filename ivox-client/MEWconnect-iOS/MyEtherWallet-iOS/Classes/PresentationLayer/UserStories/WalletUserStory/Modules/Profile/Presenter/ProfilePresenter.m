//
//  ProfilePresenter.m
//  MyEtherWallet-iOS
//
//  Created by Victor Lopez on 17/01/20.
//  Copyright © 2020 MyEtherWallet, Inc. All rights reserved.
//


#import "ProfilePresenter.h"

#import "ProfileViewInput.h"

#import "AccountModelObject.h"
#import "MasterTokenModelObject.h"


@interface ProfilePresenter ()
@end

@implementation ProfilePresenter

#pragma mark - ProfileModuleInput
- (void) configureModuleWithAccountAndMasterToken:(AccountPlainObject *)account masterToken:(MasterTokenPlainObject*)masterToken{
    
    self.view.account = account;
    self.view.masterToken = masterToken;
    
}

@end
