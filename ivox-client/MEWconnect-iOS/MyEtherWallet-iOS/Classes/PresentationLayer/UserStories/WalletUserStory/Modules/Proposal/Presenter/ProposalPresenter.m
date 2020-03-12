//
//  ProposalPresenter.m
//  Ivoxis
//
//  Created by Victor Lopez on 10/03/20.
//  Copyright © 2020 MyEtherWallet, Inc. All rights reserved.
//

#import "ProposalPresenter.h"

#import "ProposalViewInput.h"

#import "AccountModelObject.h"
#import "MasterTokenModelObject.h"


@interface ProposalPresenter ()
@end

@implementation ProposalPresenter

#pragma mark - ProposalModuleInput
- (void) configureModuleWithAccountAndMasterToken:(AccountPlainObject *)account masterToken:(MasterTokenPlainObject*)masterToken voteBatch:(int)voteBatch{
    
    self.view.account = account;
    self.view.masterToken = masterToken;
    self.view.voteBatch = [NSNumber numberWithInt:voteBatch];
}

@end
