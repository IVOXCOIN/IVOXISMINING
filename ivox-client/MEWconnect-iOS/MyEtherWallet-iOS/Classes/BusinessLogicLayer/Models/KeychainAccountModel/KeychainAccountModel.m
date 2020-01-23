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
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *card;
@property (nonatomic, strong) NSString *balanceMethod;
@property (nonatomic, strong) NSString *currency;
@property (nonatomic, strong) NSArray <KeychainNetworkModel *> *networks;
@end

@implementation KeychainAccountModel

+ (instancetype) itemWithUID:(NSString *)uid backedUp:(BOOL)backedUp balanceMethod:(NSString*)balanceMethod currency:(NSString*)currency username:(NSString*)username email:(NSString*)email phone:(NSString*)phone address:(NSString*)address country:(NSString*)country card:(NSString*)card networks:(NSArray <KeychainNetworkModel *> *)networks {
  KeychainAccountModel *itemModel = [[[self class] alloc] init];
  itemModel.uid = uid;
  itemModel.backedUp = backedUp;
  itemModel.balanceMethod = balanceMethod;
  itemModel.currency = currency;
  itemModel.networks = networks;
    itemModel.username = username;
    itemModel.email = email;
    itemModel.phone = phone;
    itemModel.address = address;
    itemModel.country = country;
    itemModel.card = card;
    
  return itemModel;
}

@end
