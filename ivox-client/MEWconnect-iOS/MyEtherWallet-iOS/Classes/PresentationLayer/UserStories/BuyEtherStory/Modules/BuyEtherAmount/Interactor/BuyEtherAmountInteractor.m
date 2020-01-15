//
//  BuyEtherAmountInteractor.m
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 02/07/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

@import libextobjc.EXTScope;

#import "BuyEtherAmountInteractor.h"

#import "BuyEtherAmountInteractorOutput.h"

#import "SimplexService.h"
#import "AccountsService.h"

#import "MasterTokenPlainObject.h"
#import "NetworkPlainObject.h"
#import "FiatPricePlainObject.h"

#import "SimplexQuote.h"

#import "AccountModelObject.h"
#import "NSManagedObjectContext+MagicalRecord.h"
#import "NSManagedObject+MagicalFinders.h"


static short const kBuyEtherAmountRoundingETHScale        = 8;
static short const kBuyEtherAmountRoundingUSDScale        = 2;

static NSDecimalNumber *kBuyEtherMinimumUSDAmount;
static NSDecimalNumber *kBuyEtherMaximumUSDAmount;
static NSDecimalNumber *kBuyEtherMidRangeFeeValue;
static NSDecimalNumber *kBuyEtherMidRangeFee;

static NSString *const kBuyEtherAmountDecimalSeparator    = @".";

@interface BuyEtherAmountInteractor ()
@property (nonatomic, strong) MasterTokenPlainObject *masterToken;
@property (nonatomic) SimplexServiceCurrencyType currency;
@property (nonatomic, strong) NSMutableString *amount;
@property (nonatomic, strong) NSDecimalNumber *simplexPrice;
@end

@implementation BuyEtherAmountInteractor {
  NSDecimalNumberHandler *_ethRoundHandler;
  NSDecimalNumberHandler *_usdRoundHandler;
}

+ (void)initialize {
  kBuyEtherMinimumUSDAmount = [NSDecimalNumber decimalNumberWithString:@"500"];
  kBuyEtherMaximumUSDAmount = [NSDecimalNumber decimalNumberWithString:@"20000"];
  kBuyEtherMidRangeFeeValue = [NSDecimalNumber decimalNumberWithString:@"210"];
  kBuyEtherMidRangeFee      = [NSDecimalNumber decimalNumberWithString:@"0.0566"];
}

#pragma mark - BuyEtherAmountInteractorInput

- (void) configurateWithMasterToken:(MasterTokenPlainObject *)masterToken {
  _masterToken = masterToken;
  _currency = SimplexServiceCurrencyTypeUSD;
    
    NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];

    AccountModelObject* accountModelObject = [AccountModelObject MR_findFirstByAttribute:NSStringFromSelector(@selector(active)) withValue:@YES inContext:defaultContext];

    NSString* balanceMethod = accountModelObject.balanceMethod;

    if([balanceMethod isEqualToString:@"IVOX"]){
        
        NSDecimalNumber* tokensInitialValue = [masterToken.price.usdPrice decimalNumberByMultiplyingBy:[[NSDecimalNumber alloc] initWithInt:500]];
        
        _amount = [[NSMutableString alloc] initWithString:[tokensInitialValue stringValue]];
    } else {
        _amount = [[NSMutableString alloc] initWithString:@"0"];
    }
  _ethRoundHandler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                            scale:kBuyEtherAmountRoundingETHScale
                                                                 raiseOnExactness:NO
                                                                  raiseOnOverflow:NO
                                                                 raiseOnUnderflow:NO
                                                              raiseOnDivideByZero:NO];
  _usdRoundHandler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                            scale:kBuyEtherAmountRoundingUSDScale
                                                                 raiseOnExactness:NO
                                                                  raiseOnOverflow:NO
                                                                 raiseOnUnderflow:NO
                                                              raiseOnDivideByZero:NO];
}

- (void) updateEthPriceIfNeeded {
  if (!self.simplexPrice) {
    @weakify(self);
    [self.simplexService quoteWithAmount:[NSDecimalNumber one]
                                currency:SimplexServiceCurrencyTypeETH
                                balanceMethod:[self getBalanceMethod]
                              completion:^(SimplexQuote *quote, __unused NSError *error) {
                                @strongify(self);
                                if (quote) {
                                  self.simplexPrice = quote.fiatBaseAmount;
                                  NSDecimalNumber *convertedAmount = [self obtainInputAmount];
                                  
                                    NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];

                                    AccountModelObject* accountModelObject = [AccountModelObject MR_findFirstByAttribute:NSStringFromSelector(@selector(active)) withValue:@YES inContext:defaultContext];

                                  NSString* balanceMethod = accountModelObject.balanceMethod;

                                    
                                  BOOL minimumAmountReached = NO;
                                  NSDecimalNumber *usd = [self obtainInputAmount];
                                  
                                    if([balanceMethod isEqualToString:@"IVOX"]){
                                        minimumAmountReached = [usd compare:kBuyEtherMinimumUSDAmount] != NSOrderedAscending;

                                    } else {
                                        if(![usd isEqual:@0]){
                                            minimumAmountReached = YES;
                                        }
                                    }
                                    
 
                                  [self.output updateInputPriceWithEnteredAmount:self.amount convertedAmount:convertedAmount];
                                  [self.output minimumAmountDidReached:minimumAmountReached];
                                }
                                [self.output priceDidUpdated];
                              }];
  } else {
    [self.output priceDidUpdated];
  }
}

- (void) appendSymbol:(NSString *)symbol {
  NSString *decimalSeparator = kBuyEtherAmountDecimalSeparator;
  NSRange separatorRange = [_amount rangeOfString:decimalSeparator];
  NSInteger maxDecimalLength = 0;
  switch (_currency) {
    case SimplexServiceCurrencyTypeUSD: {
      maxDecimalLength = kBuyEtherAmountRoundingUSDScale;
      break;
    }
    case SimplexServiceCurrencyTypeETH: {
      maxDecimalLength = kBuyEtherAmountRoundingETHScale;
      break;
    }
      
    default:
      break;
  }
  if (![symbol isEqualToString:decimalSeparator] || ([symbol isEqualToString:decimalSeparator] && separatorRange.location == NSNotFound)) {
    if (![symbol isEqualToString:decimalSeparator] && [_amount isEqualToString:@"0"]) {
      [_amount replaceCharactersInRange:NSMakeRange(0, [_amount length]) withString:symbol];
    } else if (separatorRange.location == NSNotFound ||
        [_amount length] - separatorRange.location <= maxDecimalLength) {
      [_amount appendString:symbol];
    }
  }
    
    
      NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];

      AccountModelObject* accountModelObject = [AccountModelObject MR_findFirstByAttribute:NSStringFromSelector(@selector(active)) withValue:@YES inContext:defaultContext];

    NSString* balanceMethod = accountModelObject.balanceMethod;

  
  BOOL minimumAmountReached = NO;
  NSDecimalNumber *convertedAmount = [self obtainInputAmount];
    
    if([balanceMethod isEqualToString:@"IVOX"]){
        minimumAmountReached = [convertedAmount compare:kBuyEtherMinimumUSDAmount] != NSOrderedAscending;
    } else {
        if(![convertedAmount isEqual:@0]){
            minimumAmountReached = YES;
        }
    }

  [self.output updateInputPriceWithEnteredAmount:_amount convertedAmount:convertedAmount];
  [self.output minimumAmountDidReached:minimumAmountReached];
}

- (void) eraseSymbol {
  if ([_amount length] > 0) {
    NSRange range = NSMakeRange([_amount length] - 1, 1);
    [_amount replaceCharactersInRange:range withString:@""];
  }

      NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];

      AccountModelObject* accountModelObject = [AccountModelObject MR_findFirstByAttribute:NSStringFromSelector(@selector(active)) withValue:@YES inContext:defaultContext];

    NSString* balanceMethod = accountModelObject.balanceMethod;

    
  NSDecimalNumber *convertedAmount = [self obtainInputAmount];
  BOOL minimumAmountReached = NO;

    NSDecimalNumber *usd = convertedAmount;
    
    if([balanceMethod isEqualToString:@"IVOX"]){
        minimumAmountReached = [usd compare:kBuyEtherMinimumUSDAmount] != NSOrderedAscending;

    } else {
        if(![usd isEqual:@0]){
            minimumAmountReached = YES;
        }
    }
    

  [self.output updateInputPriceWithEnteredAmount:_amount convertedAmount:convertedAmount];
  [self.output minimumAmountDidReached:minimumAmountReached];
}
- (NSString *) getCurrency {
    return [self.accountsService getCurrency:
            (AccountPlainObject *)[self.accountsService obtainActiveAccount]];
}

- (NSString *) getBalanceMethod {
    return [self.accountsService getBalanceMethod:
            (AccountPlainObject *)[self.accountsService obtainActiveAccount]];
}
- (NSString *) obtainEnteredAmount {
  return [_amount copy];
}

- (NSDecimalNumber *) obtainInputAmount {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setMaximumFractionDigits:4];

    NSDecimalNumber *convertedAmount = [[self _obtainEnteredAmountNumber] decimalNumberByDividingBy:self.masterToken.price.usdPrice ];
    
    NSString *stringNumber = [convertedAmount stringValue];
    return (NSDecimalNumber *)[formatter numberFromString:stringNumber];
}

- (SimplexServiceCurrencyType) obtainCurrencyType {
  return self.currency;
}

- (void) prepareQuote {
  NSDecimalNumber *amount = [self _obtainEnteredAmountNumber];
  [self.output loadingDidStart];
  if (![amount isEqualToNumber:[NSDecimalNumber zero]]) {
    @weakify(self);
    [self.simplexService quoteWithAmount:amount
                                currency:self.currency
                                balanceMethod:[self getBalanceMethod]                  completion:^(SimplexQuote *quote, __unused NSError *error) {
                                @strongify(self);
                                if (quote) {
                                    self.simplexPrice = quote.fiatBaseAmount;
                                    [self.output loadingDidEnd];
                                    
                                } else {
                                  [self.output loadingDidEnd];
                                }
                              }];
  }
}

- (MasterTokenPlainObject *) obtainMasterToken {
  return self.masterToken;
}

- (NSDecimalNumber *) obtainMinimumAmount {
  return kBuyEtherMinimumUSDAmount;
}

#pragma mark - Private

- (NSDecimalNumber *) _obtainEnteredAmountNumber {
  if ([_amount length] == 0) {
    [_amount appendString:@"0"];
  }
  return [NSDecimalNumber decimalNumberWithString:_amount];
}

- (NSDecimalNumber *) _obtainConvertedAmountWithCurrency:(SimplexServiceCurrencyType)currency enteredAmount:(NSDecimalNumber *)enteredAmount {
  NSDecimalNumber *usdPrice = self.simplexPrice ?: self.masterToken.price.usdPrice;
  NSDecimalNumber *convertedAmount = nil;
  if (usdPrice) {
    switch (currency) {
      case SimplexServiceCurrencyTypeETH: {
        convertedAmount = [enteredAmount decimalNumberByMultiplyingBy:usdPrice];
        convertedAmount = [convertedAmount decimalNumberByAdding:[self _calculateEstimatedFeeForAmount:convertedAmount]];
        convertedAmount = [convertedAmount decimalNumberByRoundingAccordingToBehavior:_usdRoundHandler];
        break;
      }
      case SimplexServiceCurrencyTypeUSD:
      default: {
        convertedAmount = [enteredAmount decimalNumberBySubtracting:[self _calculateEstimatedFeeForAmount:enteredAmount]];
        convertedAmount = [convertedAmount decimalNumberByDividingBy:usdPrice];
        convertedAmount = [convertedAmount decimalNumberByRoundingAccordingToBehavior:_ethRoundHandler];
        break;
      }
    }
  }
  if ([convertedAmount compare:[NSDecimalNumber zero]] == NSOrderedAscending) {
    convertedAmount = [NSDecimalNumber zero];
  }
  return convertedAmount;
}

- (NSDecimalNumber *) _calculateEstimatedFeeForAmount:(NSDecimalNumber *)amount {
  if ([amount compare:[NSDecimalNumber zero]] == NSOrderedSame) {
    return [NSDecimalNumber zero];
  }
  NSDecimalNumber *feePercent = nil;
  NSDecimalNumber *correction = [NSDecimalNumber decimalNumberWithString:@"-0.03"];
  BOOL applyCorrection = NO;
  if ([amount compare:kBuyEtherMidRangeFeeValue] == NSOrderedDescending) {
    feePercent = kBuyEtherMidRangeFee;
  } else {
    applyCorrection = YES;
    NSDecimalNumber *k1 = [NSDecimalNumber decimalNumberWithString:@"10"];
    NSDecimalNumber *k2 = [NSDecimalNumber decimalNumberWithString:@"-0.08"];
    NSDecimalNumber *k3 = [NSDecimalNumber decimalNumberWithString:@"0.01"];
    
    NSDecimalNumber *p1 = [k1 decimalNumberByDividingBy:amount];
    NSDecimalNumber *p2 = [k2 decimalNumberByDividingBy:amount];
    
    feePercent = [p1 decimalNumberByAdding:p2];
    feePercent = [feePercent decimalNumberByAdding:k3];
  }
  
  NSDecimalNumber *fee = [amount decimalNumberByMultiplyingBy:feePercent];
  if (applyCorrection) {
    fee = [fee decimalNumberByAdding:correction];
  }
  return fee;
}

@end
