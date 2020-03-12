//
//  ProposalRouter.h
//  MyEtherWallet-iOS
//
//  Created by Victor Lopez on 10/03/20.
//  Copyright © 2020 MyEtherWallet, Inc. All rights reserved.
//

#import "ProposalRouterInput.h"

@protocol RamblerViperModuleTransitionHandlerProtocol;

@interface ProposalRouter : NSObject <ProposalRouterInput>

@property (nonatomic, weak) id<RamblerViperModuleTransitionHandlerProtocol> transitionHandler;

@end
