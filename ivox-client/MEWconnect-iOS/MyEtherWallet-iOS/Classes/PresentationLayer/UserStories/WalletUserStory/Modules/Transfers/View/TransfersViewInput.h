//
//  TransfersViewInput.h
//  MyEtherWallet-iOS
//
//  Created by Victor Lopez on 31/12/19.
//  Copyright © 2019 MyEtherWallet, Inc. All rights reserved.
//

@import Foundation;

#import "AccountPlainObject.h"
#import "MasterTokenPlainObject.h"


@protocol TransfersViewInput <NSObject>

@property (nonatomic, strong) AccountPlainObject *account;
@property (nonatomic, strong) MasterTokenPlainObject *masterToken;

@end
