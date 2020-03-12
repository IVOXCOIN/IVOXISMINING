//
//  ProposalPresenter.h
//  MyEtherWallet-iOS
//
//  Created by Victor Lopez on 10/03/20.
//  Copyright © 2020 MyEtherWallet, Inc. All rights reserved.
//

#import "ProposalModuleInput.h"

@protocol ProposalViewInput;
@protocol ProposalRouterInput;

@interface ProposalPresenter : NSObject <ProposalModuleInput>

@property (nonatomic, weak) id<ProposalViewInput> view;
@property (nonatomic, strong) id<ProposalRouterInput> router;

@end
