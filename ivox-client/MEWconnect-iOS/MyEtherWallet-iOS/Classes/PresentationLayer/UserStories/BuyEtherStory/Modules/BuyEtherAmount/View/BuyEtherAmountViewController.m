//
//  BuyEtherAmountViewController.m
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 02/07/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

//@import DZNWebViewController;

#import "BuyEtherAmountViewController.h"

#import "BuyEtherAmountViewOutput.h"

#import "FlatButton.h"

#import "UIColor+Application.h"
#import "UIImage+Color.h"
#import "NSNumberFormatter+USD.h"
#import "NSNumberFormatter+Ethereum.h"
#import "UIScreen+ScreenSizeType.h"

#import "PayPalMobile.h"

#import "MasterTokenModelObject.h"
#import "MasterTokenPlainObject.h"
#import "AccountModelObject.h"
#import "BalanceModelObject.h"
#import "IvoxTokenModelObject.h"
#import "EtherTokenModelObject.h"
#import "TokenModelObject.h"
#import "TokenPlainObject.h"
#import "FiatPriceModelObject.h"
#import "NetworkModelObject.h"
#import "NetworkPlainObject.h"


#import "NSManagedObjectContext+MagicalRecord.h"
#import "NSManagedObject+MagicalFinders.h"


#define kPayPalEnvironment PayPalEnvironmentSandbox


@interface BuyEtherAmountViewController ()
@property (nonatomic, weak) IBOutlet UILabel *amountLabel;
@property (nonatomic, weak) IBOutlet UILabel *amountCurrencyLabel;
@property (nonatomic, weak) IBOutlet UILabel *resultLabel;
@property (nonatomic, weak) IBOutlet UIButton *switchCurrencyButton;
@property (nonatomic, weak) IBOutlet UIButton *separatorButton;
@property (nonatomic, weak) IBOutlet FlatButton *buyButton;
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray <UIButton *> *keypadButtons;
@property (nonatomic, weak) IBOutlet UILabel *approximateFeeLabel;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *priceActivityIndicator;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *amountTopOffsetConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *keypadToContainerTopOffsetConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *buttonBottomOffsetConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *approximateFeeTopConstraint;
@end

@implementation BuyEtherAmountViewController {
  SimplexServiceCurrencyType _currency;
}

#pragma mark - LifeCycle

- (void) viewDidLoad {
  [super viewDidLoad];
    
    self.buyButton.enabled = false;
    
    // Set up payPalConfig
    _payPalConfig = [[PayPalConfiguration alloc] init];
    _payPalConfig.acceptCreditCards = YES;
    _payPalConfig.merchantName = @"IVOX";
    _payPalConfig.merchantPrivacyPolicyURL = [NSURL URLWithString:@"http://ivoxis.net/POLITICA_DE_PRIVACIDAD.pdf"];
    _payPalConfig.merchantUserAgreementURL = [NSURL URLWithString:@"http://ivoxis.net/TERMINOS_Y_CONDICIONES_DE_IVOX.pdf"];
    
    // Setting the languageOrLocale property is optional.
    //
    // If you do not set languageOrLocale, then the PayPalPaymentViewController will present
    // its user interface according to the device's current language setting.
    //
    // Setting languageOrLocale to a particular language (e.g., @"es" for Spanish) or
    // locale (e.g., @"es_MX" for Mexican Spanish) forces the PayPalPaymentViewController
    // to use that language/locale.
    //
    // For full details, including a list of available languages and locales, see PayPalPaymentViewController.h.
    
    _payPalConfig.languageOrLocale = [NSLocale preferredLanguages][0];
    
    
    // Setting the payPalShippingAddressOption property is optional.
    //
    // See PayPalConfiguration.h for details.
    
    _payPalConfig.payPalShippingAddressOption = PayPalShippingAddressOptionNone;
    
    // use default environment, should be Production in real life
    self.environment = kPayPalEnvironment;

    NSLog(@"PayPal iOS SDK version: %@", [PayPalMobile libraryVersion]);
    
  [self.output didTriggerViewReadyEvent];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
    
    [self setPayPalEnvironment:self.environment];

}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self.output didTriggerViewDidAppearEvent];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}


- (void)setPayPalEnvironment:(NSString *)environment {
  self.environment = environment;
  [PayPalMobile preconnectWithEnvironment:environment];
}

#pragma mark - Receive Single Payment

- (void) pay {
  
  // Note: For purposes of illustration, this example shows a payment that includes
  //       both payment details (subtotal, shipping, tax) and multiple items.
  //       You would only specify these if appropriate to your situation.
  //       Otherwise, you can leave payment.items and/or payment.paymentDetails nil,
  //       and simply set payment.amount to your total charge.
      
    NSString *description = [self._purchaseUnits stringValue];
    description = [description stringByAppendingString:@" "];
    description = [description stringByAppendingString:NSLocalizedString(@"units of:", @"Ether or IVOX units buy description")];
    description = [description stringByAppendingString:@" "];
    description = [description stringByAppendingString:self._balanceMethod];
    
    
  NSDecimalNumber *subtotal = self._purchaseValue;
  

  NSDecimalNumber *total = subtotal;
  
  PayPalPayment *payment = [[PayPalPayment alloc] init];
  payment.amount = total;
  payment.currencyCode = self._currency;
  payment.shortDescription = description;
  payment.items = nil;  // if not including multiple items, then leave payment.items as nil
  payment.paymentDetails = nil; // if not including payment details, then leave payment.paymentDetails as nil

    NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];

    AccountModelObject* accountModelObject = [AccountModelObject MR_findFirstByAttribute:NSStringFromSelector(@selector(active)) withValue:@YES inContext:defaultContext];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.chainID = %lld", BlockchainNetworkTypeEthereum];
    NetworkModelObject *networkModelObject = [[accountModelObject.networks filteredSetUsingPredicate:predicate] anyObject];
    if (!networkModelObject) {
      networkModelObject = [accountModelObject.networks anyObject];
    }

    NSDictionary *customBodyDict = @{
        @"method":accountModelObject.balanceMethod,
        @"source":networkModelObject.master.address,
        @"destination":networkModelObject.master.address,
        @"ether":[self._purchaseUnits stringValue],
        @"currency":accountModelObject.currency,
        @"commission":[networkModelObject.master.price.commission stringValue],
        @"amount":[total stringValue]
    };
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:customBodyDict options:NSJSONWritingPrettyPrinted error:&error];

    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
        return;
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        payment.custom = jsonString;
    }
    
  if (!payment.processable) {
    // This particular payment will always be processable. If, for
    // example, the amount was negative or the shortDescription was
    // empty, this payment wouldn't be processable, and you'd want
    // to handle that here.
  }
  
  PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment
                                                                                              configuration:self.payPalConfig
                                                                                                   delegate:self];
  [self presentViewController:paymentViewController animated:YES completion:nil];
}


#pragma mark PayPalPaymentDelegate methods

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment {
  NSLog(@"PayPal Payment Success!");

  [self sendCompletedPaymentToServer:completedPayment]; // Payment was processed successfully; send to server for verification and fulfillment
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
  NSLog(@"PayPal Payment Canceled");
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Proof of payment validation
- (void)sendCompletedPaymentToServer:(PayPalPayment *)completedPayment {
  // TODO: Send completedPayment.confirmation to server
  NSLog(@"Here is your proof of payment:\n\n%@\n\nSend this to your server for confirmation and fulfillment.", completedPayment.confirmation);
}


#pragma mark - BuyEtherAmountViewInput

- (void) setupInitialStateWithCurrency:(SimplexServiceCurrencyType)currency minimumAmount:(NSDecimalNumber *)minimumAmount localeCurrency:(NSString *)localeCurrencyString {
  switch ([UIScreen mainScreen].screenSizeType) {
    case ScreenSizeTypeInches40: {
      self.amountTopOffsetConstraint.constant = -4.0;
      self.keypadToContainerTopOffsetConstraint.constant = 17.0;
      self.buttonBottomOffsetConstraint.constant = 22.0;
            break;
    }
    case ScreenSizeTypeInches47: {
      self.amountTopOffsetConstraint.constant = 13.0;
      break;
    }
    case ScreenSizeTypeInches55: {
      self.amountTopOffsetConstraint.constant = 26.0;
      break;
    }
    default: {
      self.approximateFeeTopConstraint.constant = 30.0;
      break;
    }
  }
  self.approximateFeeLabel.text = NSLocalizedString(@"Approximated fee included in rate", @"BuyEther. Approximate fee");

  {
    NSDictionary *attributes = @{NSFontAttributeName: self.approximateFeeLabel.font,
                                 NSForegroundColorAttributeName: self.approximateFeeLabel.textColor};
    NSMutableAttributedString *approximateString = [[NSMutableAttributedString alloc] initWithString:self.approximateFeeLabel.text
                                                                                          attributes:attributes];
    NSRange simplexRange = [approximateString.string rangeOfString:@"Simplex"];
    if (simplexRange.location != NSNotFound) {
      [approximateString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:simplexRange];
    }
    
    self.approximateFeeLabel.attributedText = approximateString;
  }
  
  
  _currency = currency;
    self.amountCurrencyLabel.text = localeCurrencyString;// NSStringFromSimplexServiceCurrencyType(currency);
  
  UIImage *switchCurrencyBackgroundImage = [UIImage imageWithColor:[UIColor backgroundLightBlue]
                                                              size:CGSizeMake(36.0, 36.0)
                                                      cornerRadius:10.0];
  [self.switchCurrencyButton setBackgroundImage:switchCurrencyBackgroundImage forState:UIControlStateNormal];
  
  NSNumberFormatter *usdFormatter = [NSNumberFormatter usdFormatter];
  usdFormatter.maximumFractionDigits = 0;
  NSString *minimumAmountTitle = [NSString stringWithFormat:NSLocalizedString(@"%@ MINIMUM PURCHASE", @"BuyEther. Minimum amount format"),
                                  [usdFormatter stringFromNumber:minimumAmount]];
  [self.buyButton setTitle:minimumAmountTitle forState:UIControlStateDisabled];
  
  if ([UIScreen mainScreen].screenSizeType == ScreenSizeTypeInches55) {
    UIFont *font = [UIFont systemFontOfSize:25.0 weight:UIFontWeightRegular];
    for (UIButton *keypadButton in self.keypadButtons) {
      keypadButton.titleLabel.font = font;
    }
  }
}

- (void) updateWithEnteredAmount:(NSString *)enteredAmount convertedAmount:(NSDecimalNumber *)convertedAmount balanceMethod:(NSString *)balanceMethodString {
  NSString *prefix = nil;
  NSNumberFormatter *convertedFormatter = nil;
  NSString *nullSuffix = nil;
    
    self._purchaseUnits = [NSDecimalNumber decimalNumberWithString:[convertedAmount stringValue]];
    self._purchaseValue = [NSDecimalNumber decimalNumberWithString:enteredAmount];
    
    self._balanceMethod = balanceMethodString;
    
    NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];

    AccountModelObject* accountModelObject = [AccountModelObject MR_findFirstByAttribute:NSStringFromSelector(@selector(active)) withValue:@YES inContext:defaultContext];

    self._currency = accountModelObject.currency;
    

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.chainID = %lld", BlockchainNetworkTypeEthereum];
    NetworkModelObject *networkModelObject = [[accountModelObject.networks filteredSetUsingPredicate:predicate] anyObject];
    if (!networkModelObject) {
      networkModelObject = [accountModelObject.networks anyObject];
    }
    
    self._purchaseValue = [self._purchaseValue decimalNumberByAdding:
      networkModelObject.master.price.commission];

    
  prefix = [NSNumberFormatter usdFormatter].currencySymbol;
  convertedFormatter = [NSNumberFormatter ethereumFormatterWithBalanceMethod:balanceMethodString];
  nullSuffix = convertedFormatter.currencySymbol;

    NSString *purchaseTitle = [NSString stringWithFormat:NSLocalizedString(@"Purchase %@", @"Purchase title"), balanceMethodString];

    self.title = purchaseTitle;
    
  self.amountLabel.text = [prefix stringByAppendingString:[self._purchaseValue stringValue]];
  if (convertedAmount) {
      
      NSDecimalNumber *originalNumber = [NSDecimalNumber decimalNumberWithString:[convertedAmount stringValue]];
      NSDecimalNumberHandler *behavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:4 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];

      NSDecimalNumber *roundedNumber = [originalNumber decimalNumberByRoundingAccordingToBehavior:behavior];

    NSString *convertedAmountText = [@"≈ " stringByAppendingString:[convertedFormatter stringFromNumber:roundedNumber]];
      
      self.resultLabel.text = convertedAmountText;
  } else {
    self.resultLabel.text = [@"— " stringByAppendingString:nullSuffix];
  }
}

- (void)updateCurrency:(SimplexServiceCurrencyType)currency {
  _currency = currency;
  self.amountCurrencyLabel.text = NSStringFromSimplexServiceCurrencyType(currency);
}

- (void) enableContinue {  
  self.buyButton.enabled = YES;
}

- (void) disableContinue {
    if(self.environment == PayPalEnvironmentSandbox){
        self.buyButton.enabled = YES;
    } else {
        self.buyButton.enabled = NO;
    }
}

- (void) showLoading {
  self.buyButton.loading = YES;
}

- (void) hideLoading {
  self.buyButton.loading = NO;
}

- (void) hidePriceActivity {
  [self.priceActivityIndicator stopAnimating];
}

#pragma mark - IBActions

- (IBAction) padButtonAction:(UIButton *)sender {
  NSString *symbol = nil;
  if (sender.tag < 10) {
    symbol = [NSString stringWithFormat:@"%zd", sender.tag];
  } else {
    symbol = [sender titleForState:UIControlStateNormal];
  }
  [self.output didEnterSymbolAction:symbol];
}

- (IBAction) padBackspaceAction:(__unused UIButton *)sender {
  [self.output eraseSymbolAction];
}

- (IBAction) closeAction:(__unused id)sender {
  [self.output closeAction];
}

- (IBAction) historyAction:(__unused id)sender {
  [self.output historyAction];
}

- (IBAction) buyAction:(__unused id)sender {
  [self pay];
}

@end
