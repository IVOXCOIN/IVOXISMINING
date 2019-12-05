//
//  SplashPasswordRouter.m
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 26/05/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

@import ViperMcFlurryX;

#import "SplashPasswordRouter.h"
#import "ForgotPasswordModuleInput.h"
#import "HomeModuleInput.h"

static NSString *const kSplashPasswordToForgotPasswordSegueIdentifier = @"SplashPasswordToForgotPasswordSegueIdentifier";
static NSString *const kSplashPasswordToHomeUnwindSegueIdentifier     = @"SplashPasswordToHomeSegueIdentifier";

@implementation SplashPasswordRouter

#pragma mark - SplashPasswordRouterInput

- (void) close {
  [self.transitionHandler closeCurrentModule:YES];
}

- (void) unwindToHome {
  [[self.transitionHandler openModuleUsingSegue:kSplashPasswordToHomeUnwindSegueIdentifier] thenChainUsingBlock:^id<RamblerViperModuleOutput>(id<HomeModuleInput> moduleInput) {
    [moduleInput takeControlAfterLaunch];
    return nil;
  }];
}

- (void) openForgotPasswordWithAccount:(AccountPlainObject *)account {
  [[self.transitionHandler openModuleUsingSegue:kSplashPasswordToForgotPasswordSegueIdentifier] thenChainUsingBlock:^id<RamblerViperModuleOutput>(id<ForgotPasswordModuleInput> moduleInput) {
    [moduleInput configureModuleWithAccount:account];
    return nil;
  }];
}

@end
