//
//  ProfileRouter.m
//  MyEtherWallet-iOS
//
//  Created by Victor Lopez on 17/01/20.
//  Copyright © 2020 MyEtherWallet, Inc. All rights reserved.
//


@import ViperMcFlurryX;

#import "VoteRouter.h"

#import "ApplicationConstants.h"
#import "ProposalModuleInput.h"

static NSString *const kVotingToProposalSegueIdentifier          = @"VotingToProposalSegueIdentifier";


@implementation VoteRouter

#pragma mark - ProposalsRouterInput

- (void) close {
  [self.transitionHandler closeCurrentModule:YES];
}

- (void) openProposalWithAccountAndMasterToken:(AccountPlainObject *)account masterToken:(MasterTokenPlainObject*)masterToken voteBatch:(int)voteBatch{
  [[self.transitionHandler openModuleUsingSegue:kVotingToProposalSegueIdentifier] thenChainUsingBlock:^id<RamblerViperModuleOutput>(id<ProposalModuleInput> moduleInput) {
      [moduleInput configureModuleWithAccountAndMasterToken:account masterToken:masterToken voteBatch:voteBatch];
    return nil;
  }];
}


@end
