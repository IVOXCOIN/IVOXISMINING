//
//  InfoDestructiveTableViewCell.m
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 24/06/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

#import "InfoDestructiveTableViewCell.h"
#import "InfoDestructiveTableViewCellObject.h"

static CGFloat const kInfoDestructiveTableViewCellHeight = 56.0;
static CGFloat const kInfoDestructiveTableViewCellCompactHeight = 44.0;

@interface InfoDestructiveTableViewCell ()
@end

@implementation InfoDestructiveTableViewCell

#pragma mark - NICell methods

- (BOOL)shouldUpdateCellWithObject:(InfoDestructiveTableViewCellObject *)object {
  self.textLabel.text = object.title;
  return YES;
}

+ (CGFloat)heightForObject:(InfoDestructiveTableViewCellObject *)object atIndexPath:(__unused NSIndexPath *)indexPath tableView:(__unused UITableView *)tableView {
  if (object.compact) {
    return kInfoDestructiveTableViewCellCompactHeight;
  } else {
    return kInfoDestructiveTableViewCellHeight;
  }
}

@end
