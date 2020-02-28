//
//  ProfileRouter.h
//  MyEtherWallet-iOS
//
//  Created by Victor Lopez on 17/01/20.
//  Copyright © 2020 MyEtherWallet, Inc. All rights reserved.
//

#import "ProposalsRouterInput.h"

@protocol RamblerViperModuleTransitionHandlerProtocol;

@interface ProposalsRouter : NSObject <ProposalsRouterInput>

@property (nonatomic, weak) id<RamblerViperModuleTransitionHandlerProtocol> transitionHandler;

@end
