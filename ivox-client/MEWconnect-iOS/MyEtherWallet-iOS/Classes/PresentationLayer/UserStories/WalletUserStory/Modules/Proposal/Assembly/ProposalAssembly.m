//
//  ProposalAssembly.m
//  Ivoxis
//
//  Created by Victor Lopez on 10/03/20.
//  Copyright © 2020 MyEtherWallet, Inc. All rights reserved.
//

@import ViperMcFlurryX;

#import "TransitioningDelegateFactory.h"
#import "ServiceComponents.h"
#import "PonsomizerAssembly.h"

#import "ProposalAssembly.h"

#import "ProposalRouter.h"
#import "ProposalPresenter.h"

#import "ApplicationConstants.h"
#import "KeychainServiceImplementation.h"
#import "UICKeyChainStore.h"

#import "MEWcryptoImplementation.h"


#import "MyEtherWallet_iOS-Swift.h"

@implementation ProposalAssembly

- (ProposalViewController *)viewProposal {
  return [TyphoonDefinition withClass:[ProposalViewController class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(moduleInput)
                                                with:[self presenterProposal]];

                          [definition injectProperty:@selector(router)
                                                with:[self routerProposal]];
                          [definition injectProperty:@selector(wrapper)
                            with:[self proposalWeb3Wrapper]];

                          [definition injectProperty:@selector(customTransitioningDelegate)
                                                with:[self.transitioningDelegateFactory transitioningDelegateWithType:@(TransitioningDelegateBottomBackgroundedModal) cornerRadius:@16.0]];
                          [definition injectProperty:@selector(modalPresentationStyle)
                                                with:@(UIModalPresentationCustom)];
      
      
                          [definition injectProperty:@selector(accountsService)
                                                with:[self.serviceComponents accountsService]];
                        }];


}

- (ProposalPresenter *)presenterProposal{
  return [TyphoonDefinition withClass:[ProposalPresenter class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(view)
                                                with:[self viewProposal]];
                          [definition injectProperty:@selector(router)
                                                with:[self routerProposal]];
                        }];
}


- (ProposalRouter *)routerProposal{
  return [TyphoonDefinition withClass:[ProposalRouter class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(transitionHandler)
                                                with:[self viewProposal]];
                        }];
}

- (Web3Wrapper *) proposalWeb3Wrapper {
  return [TyphoonDefinition withClass:[Web3Wrapper class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(MEWcrypto)
                                                with:[self proposalMEWcrypto]];
                          [definition injectProperty:@selector(keychainService)
                                                with:[self proposalKeychainService]];
                        }];
}

- (id <MEWcrypto>) proposalMEWcrypto {
  return [TyphoonDefinition withClass:[MEWcryptoImplementation class]];
}

- (id <KeychainService>)proposalKeychainService {
  return [TyphoonDefinition withClass:[KeychainServiceImplementation class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(keychainStore) with:[self proposalKeychainStore]];
                          [definition injectProperty:@selector(dateFormatter) with:[self proposalDateFormatter]];
                        }];
}



- (UICKeyChainStore *) proposalKeychainStore {
  return [TyphoonDefinition withClass:[UICKeyChainStore class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition useInitializer:@selector(keyChainStoreWithService:)
                                          parameters:^(TyphoonMethod *initializer) {
                                            [initializer injectParameterWith:kKeychainService];
                                          }];
                        }];
}

- (NSDateFormatter *) proposalDateFormatter {
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
