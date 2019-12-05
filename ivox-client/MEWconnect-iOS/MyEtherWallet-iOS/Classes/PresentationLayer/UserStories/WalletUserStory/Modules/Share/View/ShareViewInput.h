//
//  ShareViewInput.h
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 11/10/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

@import Foundation;

#import "BlockchainNetworkTypes.h"

@protocol ShareViewInput <NSObject>
- (void) setupInitialStateWithAddress:(NSString *)address qrCode:(UIImage *)qrCode network:(BlockchainNetworkType)network;
- (void) presentShareWithItems:(NSArray *)items;
- (void) showToastAddressCopied;
@end
