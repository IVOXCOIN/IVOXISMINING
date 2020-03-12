//
//  ProfilePresenter.h
//  MyEtherWallet-iOS
//
//  Created by Victor Lopez on 17/01/20.
//  Copyright © 2020 MyEtherWallet, Inc. All rights reserved.
//

#import "VoteModuleInput.h"

@protocol VoteViewInput;
@protocol VoteRouterInput;

@interface VotePresenter : NSObject <VoteModuleInput>

@property (nonatomic, weak) id<VoteViewInput> view;
@property (nonatomic, strong) id<VoteRouterInput> router;

@end
