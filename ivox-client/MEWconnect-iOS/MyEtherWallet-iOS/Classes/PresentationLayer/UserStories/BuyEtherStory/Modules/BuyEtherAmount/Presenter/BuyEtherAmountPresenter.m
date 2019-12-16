//
//  BuyEtherAmountPresenter.m
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 02/07/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

#import "BuyEtherAmountPresenter.h"

#import "BuyEtherAmountViewInput.h"
#import "BuyEtherAmountInteractorInput.h"
#import "BuyEtherAmountRouterInput.h"

@implementation BuyEtherAmountPresenter

#pragma mark - BuyEtherAmountModuleInput

- (void) configureModuleWithMasterToken:(MasterTokenPlainObject *)masterToken {
  [self.interactor configurateWithMasterToken:masterToken];
}

#pragma mark - BuyEtherAmountViewOutput

- (void) didTriggerViewReadyEvent {
  SimplexServiceCurrencyType currency = [self.interactor obtainCurrencyType];
  NSDecimalNumber *minimumAmount = [self.interactor obtainMinimumAmount];
    NSString *localeCurrency = [self.interactor getCurrency];

    [self.view setupInitialStateWithCurrency:currency minimumAmount:minimumAmount localeCurrency:localeCurrency];
    
  NSString *enteredAmount = [self.interactor obtainEnteredAmount];
  NSDecimalNumber *convertedAmount = [self.interactor obtainInputAmount];
  NSString *balanceMethod = [self.interactor getBalanceMethod];
    [self.view updateWithEnteredAmount:enteredAmount convertedAmount:convertedAmount balanceMethod: balanceMethod];
}

- (void) didTriggerViewDidAppearEvent {
  [self.interactor updateEthPriceIfNeeded];
}

- (void) didEnterSymbolAction:(NSString *)symbol {
  [self.interactor appendSymbol:symbol];
}

- (void) eraseSymbolAction {
  [self.interactor eraseSymbol];
}

- (void) closeAction {
  [self.router close];
}

- (void) historyAction {
  MasterTokenPlainObject *masterToken = [self.interactor obtainMasterToken];
  [self.router openBuyEtherHistoryForMasterToken:masterToken];
}

- (void) buyAction {
  [self.interactor prepareQuote];
}

#pragma mark - BuyEtherAmountInteractorOutput

- (void) updateInputPriceWithEnteredAmount:(NSString *)enteredAmount convertedAmount:(NSDecimalNumber *)convertedAmount {
    
    NSString *balanceMethod = [self.interactor getBalanceMethod];
      [self.view updateWithEnteredAmount:enteredAmount convertedAmount:convertedAmount balanceMethod: balanceMethod];
}

- (void)orderDidCreated:(SimplexOrder *)order forMasterToken:(MasterTokenPlainObject *)masterToken {
  [self.router openBuyEtherWebWithOrder:order masterToken:masterToken];
}

- (void) minimumAmountDidReached:(BOOL)minimumAmountReached {
  if (minimumAmountReached) {
    [self.view enableContinue];
  } else {
    [self.view disableContinue];
  }
}

- (void) loadingDidStart {
  [self.view showLoading];
}

- (void) loadingDidEnd {
  [self.view hideLoading];
}

- (void)priceDidUpdated {
  [self.view hidePriceActivity];
}

@end
