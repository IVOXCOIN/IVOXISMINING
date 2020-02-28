//
//  ProfileRouter.m
//  MyEtherWallet-iOS
//
//  Created by Victor Lopez on 17/01/20.
//  Copyright © 2020 MyEtherWallet, Inc. All rights reserved.
//


@import ViperMcFlurryX;

#import "ProposalsRouter.h"

#import "ApplicationConstants.h"

@implementation ProposalsRouter

#pragma mark - ProposalsRouterInput

- (void) close {
  [self.transitionHandler closeCurrentModule:YES];
}

@end
