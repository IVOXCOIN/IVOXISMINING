//
//  ProfileAssembly.m
//  MyEtherWallet-iOS
//
//  Created by Victor Lopez on 17/01/20.
//  Copyright © 2020 MyEtherWallet, Inc. All rights reserved.
//


@import ViperMcFlurryX;

#import "TransitioningDelegateFactory.h"
#import "ServiceComponents.h"
#import "PonsomizerAssembly.h"

#import "ProposalsAssembly.h"

#import "ProposalsRouter.h"
#import "ProposalsPresenter.h"

#import "ApplicationConstants.h"
#import "KeychainServiceImplementation.h"
#import "UICKeyChainStore.h"

#import "MEWcryptoImplementation.h"


#import "MyEtherWallet_iOS-Swift.h"

@implementation ProposalsAssembly

- (ProposalsViewController *)viewProposals {
  return [TyphoonDefinition withClass:[ProposalsViewController class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(moduleInput)
                                                with:[self presenterProposals]];

                          [definition injectProperty:@selector(router)
                                                with:[self routerProposals]];
                          [definition injectProperty:@selector(wrapper)
                            with:[self proposalsWeb3Wrapper]];

                          [definition injectProperty:@selector(customTransitioningDelegate)
                                                with:[self.transitioningDelegateFactory transitioningDelegateWithType:@(TransitioningDelegateBottomBackgroundedModal) cornerRadius:@16.0]];
                          [definition injectProperty:@selector(modalPresentationStyle)
                                                with:@(UIModalPresentationCustom)];
      
      
                          [definition injectProperty:@selector(accountsService)
                                                with:[self.serviceComponents accountsService]];
                        }];


}

- (ProposalsPresenter *)presenterProposals{
  return [TyphoonDefinition withClass:[ProposalsPresenter class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(view)
                                                with:[self viewProposals]];
                          [definition injectProperty:@selector(router)
                                                with:[self routerProposals]];
                        }];
}


- (ProposalsRouter *)routerProposals{
  return [TyphoonDefinition withClass:[ProposalsRouter class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(transitionHandler)
                                                with:[self viewProposals]];
                        }];
}

- (Web3Wrapper *) proposalsWeb3Wrapper {
  return [TyphoonDefinition withClass:[Web3Wrapper class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(MEWcrypto)
                                                with:[self proposalsMEWcrypto]];
                          [definition injectProperty:@selector(keychainService)
                                                with:[self proposalsKeychainService]];
                        }];
}

- (id <MEWcrypto>) proposalsMEWcrypto {
  return [TyphoonDefinition withClass:[MEWcryptoImplementation class]];
}

- (id <KeychainService>)proposalsKeychainService {
  return [TyphoonDefinition withClass:[KeychainServiceImplementation class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(keychainStore) with:[self proposalsKeychainStore]];
                          [definition injectProperty:@selector(dateFormatter) with:[self proposalsDateFormatter]];
                        }];
}



- (UICKeyChainStore *) proposalsKeychainStore {
  return [TyphoonDefinition withClass:[UICKeyChainStore class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition useInitializer:@selector(keyChainStoreWithService:)
                                          parameters:^(TyphoonMethod *initializer) {
                                            [initializer injectParameterWith:kKeychainService];
                                          }];
                        }];
}

- (NSDateFormatter *) proposalsDateFormatter {
  return [TyphoonDefinition withClass:[NSDateFormatter class]
                        configuration:^(TyphoonDefinition *definition) {
                          definition.scope = TyphoonScopeSingleton;
                          [definition injectMethod:@selector(setDateFormat:)
                                        parameters:^(TyphoonMethod *method) {
                                          [method injectParameterWith:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
                                        }];
                          [definition injectMethod:@selector(setTimeZone:)
                                        parameters:^(TyphoonMethod *method) {
                                          [method injectParameterWith:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                                        }];
                        }];
}


@end
