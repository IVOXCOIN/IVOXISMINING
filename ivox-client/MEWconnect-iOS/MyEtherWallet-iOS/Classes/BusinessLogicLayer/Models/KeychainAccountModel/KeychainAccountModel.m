//
//  KeychainAccountModel.m
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 30/10/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

#import "KeychainAccountModel.h"

@interface KeychainAccountModel ()
@property (nonatomic, strong) NSString *uid;
@property (nonatomic) BOOL backedUp;
@property (nonatomic, strong) NSString *balanceMethod;
@property (nonatomic, strong) NSString *currency;
@property (nonatomic, strong) NSArray <KeychainNetworkModel *> *networks;
@end

@implementation KeychainAccountModel

+ (instancetype) itemWithUID:(NSString *)uid backedUp:(BOOL)backedUp balanceMethod:(NSString*)balanceMethod currency:(NSString*)currency networks:(NSArray <KeychainNetworkModel *> *)networks {
  KeychainAccountModel *itemModel = [[[self class] alloc] init];
  itemModel.uid = uid;
  itemModel.backedUp = backedUp;
  itemModel.balanceMethod = balanceMethod;
  itemModel.currency = currency;
  itemModel.networks = networks;
  return itemModel;
}

@end
