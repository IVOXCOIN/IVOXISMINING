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

#import "ProfileAssembly.h"

#import "ProfileRouter.h"
#import "ProfilePresenter.h"

#import "ApplicationConstants.h"
#import "KeychainServiceImplementation.h"
#import "UICKeyChainStore.h"

#import "MEWcryptoImplementation.h"


#import "MyEtherWallet_iOS-Swift.h"

@implementation ProfileAssembly

- (ProfileViewController *)viewProfile {
  return [TyphoonDefinition withClass:[ProfileViewController class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(moduleInput)
                                                with:[self presenterProfile]];

                          [definition injectProperty:@selector(router)
                                                with:[self routerProfile]];
                          [definition injectProperty:@selector(wrapper)
                            with:[self profileWeb3Wrapper]];

                          [definition injectProperty:@selector(customTransitioningDelegate)
                                                with:[self.transitioningDelegateFactory transitioningDelegateWithType:@(TransitioningDelegateBottomBackgroundedModal) cornerRadius:@16.0]];
                          [definition injectProperty:@selector(modalPresentationStyle)
                                                with:@(UIModalPresentationCustom)];
      
      
                          [definition injectProperty:@selector(accountsService)
                                                with:[self.serviceComponents accountsService]];
                        }];


}

- (ProfilePresenter *)presenterProfile{
  return [TyphoonDefinition withClass:[ProfilePresenter class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(view)
                                                with:[self viewProfile]];
                          [definition injectProperty:@selector(router)
                                                with:[self routerProfile]];
                        }];
}


- (ProfileRouter *)routerProfile{
  return [TyphoonDefinition withClass:[ProfileRouter class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(transitionHandler)
                                                with:[self viewProfile]];
                        }];
}

- (Web3Wrapper *) profileWeb3Wrapper {
  return [TyphoonDefinition withClass:[Web3Wrapper class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(MEWcrypto)
                                                with:[self profileMEWcrypto]];
                          [definition injectProperty:@selector(keychainService)
                                                with:[self profileKeychainService]];
                        }];
}

- (id <MEWcrypto>) profileMEWcrypto {
  return [TyphoonDefinition withClass:[MEWcryptoImplementation class]];
}

- (id <KeychainService>)profileKeychainService {
  return [TyphoonDefinition withClass:[KeychainServiceImplementation class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(keychainStore) with:[self profileKeychainStore]];
                          [definition injectProperty:@selector(dateFormatter) with:[self profileDateFormatter]];
                        }];
}



- (UICKeyChainStore *) profileKeychainStore {
  return [TyphoonDefinition withClass:[UICKeyChainStore class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition useInitializer:@selector(keyChainStoreWithService:)
                                          parameters:^(TyphoonMethod *initializer) {
                                            [initializer injectParameterWith:kKeychainService];
                                          }];
                        }];
}

- (NSDateFormatter *) profileDateFormatter {
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
