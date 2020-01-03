//
//  TransfersPresenter.h
//  MyEtherWallet-iOS
//
//  Created by Victor Lopez on 31/12/19.
//  Copyright © 2019 MyEtherWallet, Inc. All rights reserved.
//

#import "TransfersModuleInput.h"

@protocol TransfersViewInput;
@protocol TransfersRouterInput;

@interface TransfersPresenter : NSObject <TransfersModuleInput>

@property (nonatomic, weak) id<TransfersViewInput> view;
@property (nonatomic, strong) id<TransfersRouterInput> router;

@end
