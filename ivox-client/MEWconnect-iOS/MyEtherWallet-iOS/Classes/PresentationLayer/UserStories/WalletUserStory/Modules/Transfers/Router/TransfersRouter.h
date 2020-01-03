//
//  TransfersRouter.h
//  MyEtherWallet-iOS
//
//  Created by Victor Lopez on 31/12/19.
//  Copyright © 2019 MyEtherWallet, Inc. All rights reserved.
//

#import "TransfersRouterInput.h"

@protocol RamblerViperModuleTransitionHandlerProtocol;

@interface TransfersRouter : NSObject <TransfersRouterInput>

@property (nonatomic, weak) id<RamblerViperModuleTransitionHandlerProtocol> transitionHandler;

@end
