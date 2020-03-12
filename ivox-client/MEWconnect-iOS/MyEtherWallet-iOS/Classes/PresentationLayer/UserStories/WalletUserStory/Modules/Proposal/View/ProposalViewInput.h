//
//  ProposalViewInput.h
//  MyEtherWallet-iOS
//
//  Created by Victor Lopez on 10/03/20.
//  Copyright © 2020 MyEtherWallet, Inc. All rights reserved.
//

@import Foundation;

#import "AccountPlainObject.h"
#import "MasterTokenPlainObject.h"

@protocol AccountsService;

@protocol ProposalViewInput <NSObject>

@property (nonatomic, strong) NSNumber *voteBatch;

@property (nonatomic, strong) AccountPlainObject *account;
@property (nonatomic, strong) MasterTokenPlainObject *masterToken;

@property (nonatomic, strong) id <AccountsService> accountsService;

@end
