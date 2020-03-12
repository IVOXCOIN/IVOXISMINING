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

#import "VoteAssembly.h"

#import "VoteRouter.h"
#import "VotePresenter.h"

#import "ApplicationConstants.h"
#import "KeychainServiceImplementation.h"
#import "UICKeyChainStore.h"

#import "MEWcryptoImplementation.h"


#import "MyEtherWallet_iOS-Swift.h"

@implementation VoteAssembly

- (VoteViewController *)viewVote {
  return [TyphoonDefinition withClass:[VoteViewController class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(moduleInput)
                                                with:[self presenterVote]];

                          [definition injectProperty:@selector(router)
                                                with:[self routerVote]];
                          [definition injectProperty:@selector(wrapper)
                            with:[self voteWeb3Wrapper]];

                          [definition injectProperty:@selector(customTransitioningDelegate)
                                                with:[self.transitioningDelegateFactory transitioningDelegateWithType:@(TransitioningDelegateBottomBackgroundedModal) cornerRadius:@16.0]];
                          [definition injectProperty:@selector(modalPresentationStyle)
                                                with:@(UIModalPresentationCustom)];
      
      
                          [definition injectProperty:@selector(accountsService)
                                                with:[self.serviceComponents accountsService]];
                        }];


}

- (VotePresenter *)presenterVote{
  return [TyphoonDefinition withClass:[VotePresenter class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(view)
                                                with:[self viewVote]];
                          [definition injectProperty:@selector(router)
                                                with:[self routerVote]];
                        }];
}


- (VoteRouter *)routerVote{
  return [TyphoonDefinition withClass:[VoteRouter class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(transitionHandler)
                                                with:[self viewVote]];
                        }];
}

- (Web3Wrapper *) voteWeb3Wrapper {
  return [TyphoonDefinition withClass:[Web3Wrapper class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(MEWcrypto)
                                                with:[self voteMEWcrypto]];
                          [definition injectProperty:@selector(keychainService)
                                                with:[self voteKeychainService]];
                        }];
}

- (id <MEWcrypto>) voteMEWcrypto {
  return [TyphoonDefinition withClass:[MEWcryptoImplementation class]];
}

- (id <KeychainService>)voteKeychainService {
  return [TyphoonDefinition withClass:[KeychainServiceImplementation class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(keychainStore) with:[self voteKeychainStore]];
                          [definition injectProperty:@selector(dateFormatter) with:[self voteDateFormatter]];
                        }];
}



- (UICKeyChainStore *) voteKeychainStore {
  return [TyphoonDefinition withClass:[UICKeyChainStore class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition useInitializer:@selector(keyChainStoreWithService:)
                                          parameters:^(TyphoonMethod *initializer) {
                                            [initializer injectParameterWith:kKeychainService];
                                          }];
                        }];
}

- (NSDateFormatter *) voteDateFormatter {
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
