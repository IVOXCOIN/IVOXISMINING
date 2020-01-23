//
//  ProfileRouter.h
//  MyEtherWallet-iOS
//
//  Created by Victor Lopez on 17/01/20.
//  Copyright © 2020 MyEtherWallet, Inc. All rights reserved.
//

#import "ProfileRouterInput.h"

@protocol RamblerViperModuleTransitionHandlerProtocol;

@interface ProfileRouter : NSObject <ProfileRouterInput>

@property (nonatomic, weak) id<RamblerViperModuleTransitionHandlerProtocol> transitionHandler;

@end
