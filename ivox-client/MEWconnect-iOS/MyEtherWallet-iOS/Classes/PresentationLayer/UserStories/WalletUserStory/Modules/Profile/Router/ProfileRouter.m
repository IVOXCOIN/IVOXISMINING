//
//  ProfileRouter.m
//  MyEtherWallet-iOS
//
//  Created by Victor Lopez on 17/01/20.
//  Copyright © 2020 MyEtherWallet, Inc. All rights reserved.
//


@import ViperMcFlurryX;

#import "ProfileRouter.h"

#import "ApplicationConstants.h"

@implementation ProfileRouter

#pragma mark - ProfileRouterInput

- (void) close {
  [self.transitionHandler closeCurrentModule:YES];
}

@end
