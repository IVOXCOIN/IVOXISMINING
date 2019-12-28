//
//  InfoRouter.m
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 24/06/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

@import ViperMcFlurryX;

#import "TokensRouter.h"

#import "StartModuleInput.h"

#import "ApplicationConstants.h"

static NSString *const kInfoToStartUnwindSegueIdentifier      = @"TokensToStartUnwindSegueIdentifier";

@implementation TokensRouter

#pragma mark - InfoRouterInput

- (void) close {
  [self.transitionHandler closeCurrentModule:YES];
}

- (void) unwindToStart {
  [[self.transitionHandler openModuleUsingSegue:kInfoToStartUnwindSegueIdentifier] thenChainUsingBlock:^id<RamblerViperModuleOutput>(id<StartModuleInput> moduleInput) {
    [moduleInput configureModule];
    return nil;
  }];
}


- (void) openUserGuide {
  NSURL *url = [NSURL URLWithString:kUserGuideURL];
  if (url) {
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
  }
}


@end
