//
//  ProfilePresenter.m
//  MyEtherWallet-iOS
//
//  Created by Victor Lopez on 17/01/20.
//  Copyright © 2020 MyEtherWallet, Inc. All rights reserved.
//


#import "VotePresenter.h"

#import "VoteViewInput.h"

#import "AccountModelObject.h"
#import "MasterTokenModelObject.h"


@interface VotePresenter ()
@end

@implementation VotePresenter

#pragma mark - VoteModuleInput
- (void) configureModuleWithAccountAndMasterToken:(AccountPlainObject *)account masterToken:(MasterTokenPlainObject*)masterToken voteBatch:(int)voteBatch{
    
    self.view.account = account;
    self.view.masterToken = masterToken;
    self.view.voteBatch = [NSNumber numberWithInt:voteBatch];
}

@end
