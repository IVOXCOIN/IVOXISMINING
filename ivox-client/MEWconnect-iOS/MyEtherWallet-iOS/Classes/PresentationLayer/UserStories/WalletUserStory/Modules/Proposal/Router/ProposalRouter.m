//
//  ProposalRouter.m
//  Ivoxis
//
//  Created by Victor Lopez on 10/03/20.
//  Copyright © 2020 MyEtherWallet, Inc. All rights reserved.
//

@import ViperMcFlurryX;

#import "ProposalRouter.h"

#import "ApplicationConstants.h"

@implementation ProposalRouter

#pragma mark - ProposalRouterInput

- (void) close {
  [self.transitionHandler closeCurrentModule:YES];
}

@end
