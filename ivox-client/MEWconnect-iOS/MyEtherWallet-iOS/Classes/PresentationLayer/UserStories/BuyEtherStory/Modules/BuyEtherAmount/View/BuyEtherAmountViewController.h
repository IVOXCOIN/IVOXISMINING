//
//  BuyEtherAmountViewController.h
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 02/07/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

@import UIKit;

#import "BuyEtherAmountViewInput.h"

#import "PayPalMobile.h"

@protocol BuyEtherAmountViewOutput;

@interface BuyEtherAmountViewController : UIViewController <BuyEtherAmountViewInput, PayPalPaymentDelegate>
@property (nonatomic, strong) id <BuyEtherAmountViewOutput> output;

- (void)setPayPalEnvironment:(NSString *)environment;
- (void)pay;

@property(nonatomic, strong, readwrite) PayPalConfiguration *payPalConfig;
@property(nonatomic, strong, readwrite) NSString *environment;

@end
