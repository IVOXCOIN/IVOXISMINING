//
//  InfoAssembly.h
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 24/06/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

#import "ModuleAssemblyBase.h"
@import RamblerTyphoonUtils.AssemblyCollector;

@class PonsomizerAssembly;

@interface InfoAssembly : ModuleAssemblyBase <RamblerInitialAssembly>
@property (nonatomic, strong, readonly) PonsomizerAssembly *ponsomizerAssembly;
@end
