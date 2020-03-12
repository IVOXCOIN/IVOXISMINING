//
//  ProposalAssembly.h
//  MyEtherWallet-iOS
//
//  Created by Victor Lopez on 10/03/20.
//  Copyright © 2020 MyEtherWallet, Inc. All rights reserved.
//


#import "ModuleAssemblyBase.h"
@import RamblerTyphoonUtils.AssemblyCollector;

@class PonsomizerAssembly;

@interface ProposalAssembly : ModuleAssemblyBase <RamblerInitialAssembly>
@property (nonatomic, strong, readonly) PonsomizerAssembly *ponsomizerAssembly;

@end
