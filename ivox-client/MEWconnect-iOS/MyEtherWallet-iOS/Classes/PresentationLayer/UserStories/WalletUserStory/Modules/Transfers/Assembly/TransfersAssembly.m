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

#import "TransfersAssembly.h"

#import "TransfersRouter.h"
#import "TransfersPresenter.h"

#import "ApplicationConstants.h"
#import "KeychainServiceImplementation.h"
#import "UICKeyChainStore.h"

#import "MEWcryptoImplementation.h"


#import "MyEtherWallet_iOS-Swift.h"

@implementation TransfersAssembly

- (TransfersViewController *)viewTransfers {
  return [TyphoonDefinition withClass:[TransfersViewController class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(moduleInput)
                                                with:[self presenterTransfers]];

                          [definition injectProperty:@selector(router)
                                                with:[self routerTransfers]];
                          [definition injectProperty:@selector(wrapper)
                            with:[self transfersWeb3Wrapper]];

                          [definition injectProperty:@selector(customTransitioningDelegate)
                                                with:[self.transitioningDelegateFactory transitioningDelegateWithType:@(TransitioningDelegateBottomBackgroundedModal) cornerRadius:@16.0]];
                          [definition injectProperty:@selector(modalPresentationStyle)
                                                with:@(UIModalPresentationCustom)];
                        }];
}

- (TransfersPresenter *)presenterTransfers{
  return [TyphoonDefinition withClass:[TransfersPresenter class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(view)
                                                with:[self viewTransfers]];
                          [definition injectProperty:@selector(router)
                                                with:[self routerTransfers]];
                        }];
}


- (TransfersRouter *)routerTransfers{
  return [TyphoonDefinition withClass:[TransfersRouter class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(transitionHandler)
                                                with:[self viewTransfers]];
                        }];
}


- (Web3Wrapper *) transfersWeb3Wrapper {
  return [TyphoonDefinition withClass:[Web3Wrapper class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(MEWcrypto)
                                                with:[self transfersMEWcrypto]];
                          [definition injectProperty:@selector(keychainService)
                                                with:[self transfersKeychainService]];
                        }];
}

- (id <MEWcrypto>) transfersMEWcrypto {
  return [TyphoonDefinition withClass:[MEWcryptoImplementation class]];
}

- (id <KeychainService>)transfersKeychainService {
  return [TyphoonDefinition withClass:[KeychainServiceImplementation class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition injectProperty:@selector(keychainStore) with:[self transfersKeychainStore]];
                          [definition injectProperty:@selector(dateFormatter) with:[self transfersDateFormatter]];
                        }];
}



- (UICKeyChainStore *) transfersKeychainStore {
  return [TyphoonDefinition withClass:[UICKeyChainStore class]
                        configuration:^(TyphoonDefinition *definition) {
                          [definition useInitializer:@selector(keyChainStoreWithService:)
                                          parameters:^(TyphoonMethod *initializer) {
                                            [initializer injectParameterWith:kKeychainService];
                                          }];
                        }];
}

- (NSDateFormatter *) transfersDateFormatter {
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
