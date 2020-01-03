//
//  TransfersRouter.m
//  MyEtherWallet-iOS
//
//  Created by Victor Lopez on 31/12/19.
//  Copyright © 2019 MyEtherWallet, Inc. All rights reserved.
//

@import ViperMcFlurryX;

#import "TransfersRouter.h"

#import "ApplicationConstants.h"

@implementation TransfersRouter

#pragma mark - TransfersRouterInput

- (void) close {
  [self.transitionHandler closeCurrentModule:YES];
}

@end
