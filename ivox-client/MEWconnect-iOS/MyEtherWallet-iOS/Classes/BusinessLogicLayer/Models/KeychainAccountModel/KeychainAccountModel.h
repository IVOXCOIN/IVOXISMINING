//
//  KeychainAccountModel.h
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 30/10/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

@import Foundation;

@class KeychainNetworkModel;

@interface KeychainAccountModel : NSObject
@property (nonatomic, strong, readonly) NSString *uid;
@property (nonatomic, readonly) BOOL backedUp;
@property (nonatomic, strong, readonly) NSString *balanceMethod;
@property (nonatomic, strong, readonly) NSString *currency;
@property (nonatomic, strong, readonly) NSArray <KeychainNetworkModel *> *networks;
+ (instancetype) itemWithUID:(NSString *)uid backedUp:(BOOL)backedUp balanceMethod:(NSString*)balanceMethod currency:(NSString*)currency networks:(NSArray <KeychainNetworkModel *> *)networks;
@end

