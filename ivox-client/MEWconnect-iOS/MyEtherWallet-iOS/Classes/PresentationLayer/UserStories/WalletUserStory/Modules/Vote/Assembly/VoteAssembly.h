//
//  ProposalsAssembly.h
//  MyEtherWallet-iOS
//
//  Created by Victor Lopez on 27/02/20.
//  Copyright © 2020 MyEtherWallet, Inc. All rights reserved.
//

#import "ModuleAssemblyBase.h"
@import RamblerTyphoonUtils.AssemblyCollector;

@class PonsomizerAssembly;

@interface VoteAssembly : ModuleAssemblyBase <RamblerInitialAssembly>
@property (nonatomic, strong, readonly) PonsomizerAssembly *ponsomizerAssembly;

@end
