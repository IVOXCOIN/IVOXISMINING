//
//  ProfileRouter.m
//  MyEtherWallet-iOS
//
//  Created by Victor Lopez on 17/01/20.
//  Copyright © 2020 MyEtherWallet, Inc. All rights reserved.
//


@import ViperMcFlurryX;

#import "ProposalsRouter.h"

#import "VoteModuleInput.h"
#import "ProposalModuleInput.h"

#import "ApplicationConstants.h"

static NSString *const kProposalsToVoteSegueIdentifier          = @"ProposalsToVoteSegueIdentifier";

static NSString *const kProposalsToProposalSegueIdentifier          = @"ProposalsToProposalSegueIdentifier";


@implementation ProposalsRouter

#pragma mark - ProposalsRouterInput

- (void) close {
  [self.transitionHandler closeCurrentModule:YES];
}

- (void)openVoteWithAccountAndMasterToken:(AccountPlainObject *)account masterToken:(MasterTokenPlainObject *)masterToken voteBatch:(int)voteBatch { 
    [[self.transitionHandler openModuleUsingSegue:kProposalsToVoteSegueIdentifier] thenChainUsingBlock:^id<RamblerViperModuleOutput>(id<VoteModuleInput> moduleInput) {
        [moduleInput configureModuleWithAccountAndMasterToken:account masterToken:masterToken voteBatch:voteBatch];
      return nil;
    }];

}

- (void) openProposalWithAccountAndMasterToken:(AccountPlainObject *)account masterToken:(MasterTokenPlainObject*)masterToken voteBatch:(int)voteBatch{
  [[self.transitionHandler openModuleUsingSegue:kProposalsToProposalSegueIdentifier] thenChainUsingBlock:^id<RamblerViperModuleOutput>(id<ProposalModuleInput> moduleInput) {
      [moduleInput configureModuleWithAccountAndMasterToken:account masterToken:masterToken voteBatch:voteBatch];
    return nil;
  }];
}



@end
