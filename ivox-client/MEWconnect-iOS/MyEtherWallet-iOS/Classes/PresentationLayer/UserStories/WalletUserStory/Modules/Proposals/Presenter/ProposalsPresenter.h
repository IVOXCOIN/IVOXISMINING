//
//  ProfilePresenter.h
//  MyEtherWallet-iOS
//
//  Created by Victor Lopez on 17/01/20.
//  Copyright © 2020 MyEtherWallet, Inc. All rights reserved.
//

#import "ProposalsModuleInput.h"

@protocol ProposalsViewInput;
@protocol ProposalsRouterInput;

@interface ProposalsPresenter : NSObject <ProposalsModuleInput>

@property (nonatomic, weak) id<ProposalsViewInput> view;
@property (nonatomic, strong) id<ProposalsRouterInput> router;

@end
