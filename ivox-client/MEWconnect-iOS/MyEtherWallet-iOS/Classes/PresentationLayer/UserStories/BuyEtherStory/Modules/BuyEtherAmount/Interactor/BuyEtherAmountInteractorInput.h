//
//  BuyEtherAmountInteractorInput.h
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 02/07/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

@import Foundation;

#import "BlockchainNetworkTypes.h"
#import "SimplexServiceCurrencyTypes.h"

@class MasterTokenPlainObject;

@protocol BuyEtherAmountInteractorInput <NSObject>
- (void) configurateWithMasterToken:(MasterTokenPlainObject *)masterToken;
- (void) updateEthPriceIfNeeded;
- (void) appendSymbol:(NSString *)symbol;
- (void) eraseSymbol;
- (SimplexServiceCurrencyType) obtainCurrencyType;
- (NSString *) getCurrency;
- (NSString *) getBalanceMethod;
- (NSString *) obtainEnteredAmount;
- (NSDecimalNumber *) obtainInputAmount;
- (void) prepareQuote;
- (MasterTokenPlainObject *) obtainMasterToken;
- (NSDecimalNumber *) obtainMinimumAmount;
@end
