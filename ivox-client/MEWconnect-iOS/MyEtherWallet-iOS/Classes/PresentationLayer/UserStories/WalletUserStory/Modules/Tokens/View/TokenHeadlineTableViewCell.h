//
//  HeadlineTableViewCell.h
//  MyEtherWallet-iOS
//
//  Created by Victor Lopez on 23/12/19.
//  Copyright © 2019 MyEtherWallet, Inc. All rights reserved.
//

@import UIKit;

@interface TokenHeadlineTableViewCell: UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *headlineTitleLabel;

@property (weak, nonatomic) IBOutlet UITextView *headlineTextView;

@end
