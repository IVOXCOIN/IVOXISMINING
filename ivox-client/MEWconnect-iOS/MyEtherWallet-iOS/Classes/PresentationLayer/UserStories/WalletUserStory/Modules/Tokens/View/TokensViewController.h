//
//  InfoViewController.h
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 24/06/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

@import UIKit;

#import "TokensViewInput.h"

@protocol TokensViewOutput;

@interface TokensViewController : UIViewController <TokensViewInput, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) id <TokensViewOutput> output;
@property (nonatomic, strong) id <UIViewControllerTransitioningDelegate> customTransitioningDelegate;

@end
