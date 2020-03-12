//
//  ProfileRouter.h
//  MyEtherWallet-iOS
//
//  Created by Victor Lopez on 17/01/20.
//  Copyright © 2020 MyEtherWallet, Inc. All rights reserved.
//

#import "VoteRouterInput.h"

@protocol RamblerViperModuleTransitionHandlerProtocol;

@interface VoteRouter : NSObject <VoteRouterInput>

@property (nonatomic, weak) id<RamblerViperModuleTransitionHandlerProtocol> transitionHandler;

@end
