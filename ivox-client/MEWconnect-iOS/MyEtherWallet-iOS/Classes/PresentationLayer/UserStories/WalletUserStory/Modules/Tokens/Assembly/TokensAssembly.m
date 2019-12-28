//
//  InfoAssembly.m
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 24/06/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

@import ViperMcFlurryX;

#import "TransitioningDelegateFactory.h"
#import "ServiceComponents.h"
#import "PonsomizerAssembly.h"

#import "TokensAssembly.h"

#import "TokensViewController.h"
#import "TokensInteractor.h"
#import "TokensPresenter.h"
#import "TokensRouter.h"

@implementation TokensAssembly

- (TokensViewController *)viewTokens {
  return [TyphoonDefinition withClass:[TokensViewController class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(output)
                                                with:[self presenterTokens]];
                          [definition injectProperty:@selector(moduleInput)
                                                with:[self presenterTokens]];
                          [definition injectProperty:@selector(customTransitioningDelegate)
                                                with:[self.transitioningDelegateFactory transitioningDelegateWithType:@(TransitioningDelegateBottomBackgroundedModal) cornerRadius:@16.0]];
                          [definition injectProperty:@selector(modalPresentationStyle)
                                                with:@(UIModalPresentationCustom)];
                        }];
}

- (TokensInteractor *)interactorTokens {
  return [TyphoonDefinition withClass:[TokensInteractor class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(output)
                                                with:[self presenterTokens]];
                          [definition injectProperty:@selector(accountsService)
                                                with:[self.serviceComponents accountsService]];
                          [definition injectProperty:@selector(keychainService)
                                                with:[self.serviceComponents keychainService]];
                          [definition injectProperty:@selector(tokensService)
                                                with:[self.serviceComponents tokensService]];
                          [definition injectProperty:@selector(walletService)
                                                with:[self.serviceComponents MEWwallet]];
                          [definition injectProperty:@selector(ponsomizer)
                                                with:[self.ponsomizerAssembly ponsomizer]];
                        }];
}

- (TokensPresenter *)presenterTokens{
  return [TyphoonDefinition withClass:[TokensPresenter class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(view)
                                                with:[self viewTokens]];
                          [definition injectProperty:@selector(interactor)
                                                with:[self interactorTokens]];
                          [definition injectProperty:@selector(router)
                                                with:[self routerTokens]];
                        }];
}

- (TokensRouter *)routerTokens{
  return [TyphoonDefinition withClass:[TokensRouter class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(transitionHandler)
                                                with:[self viewTokens]];
                        }];
}

@end
