//
//  InfoCellObjectBuilder.m
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 24/06/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

#import "InfoCellObjectBuilder.h"

#import "InfoNormalTableViewCellObject.h"
#import "InfoDestructiveTableViewCellObject.h"
#import "InfoEmptyTableViewCellObject.h"

@implementation InfoCellObjectBuilder

- (InfoNormalTableViewCellObject *) buildContactCellObjectWithCompactSize:(BOOL)compact {
  return [InfoNormalTableViewCellObject objectWithType:InfoNormalTableViewCellObjectTypeContact compact:compact];
}

- (InfoNormalTableViewCellObject *) buildKnowledgeBaseCellObjectWithCompactSize:(BOOL)compact {
  return [InfoNormalTableViewCellObject objectWithType:InfoNormalTableViewCellObjectTypeKnowledgeBase compact:compact];
}

- (InfoNormalTableViewCellObject *) buildPrivacyAndTermsCellObjectWithCompactSize:(BOOL)compact {
  return [InfoNormalTableViewCellObject objectWithType:InfoNormalTableViewCellObjectTypePrivateAndTerms compact:compact];
}

- (InfoNormalTableViewCellObject *) buildMyetherwalletComCellObjectWithCompactSize:(BOOL)compact {
  return [InfoNormalTableViewCellObject objectWithType:InfoNormalTableViewCellObjectTypeMyEtherWalletCom compact:compact];
}

- (InfoNormalTableViewCellObject *) buildUserGuideCellObjectWithCompactSize:(BOOL)compact {
  return [InfoNormalTableViewCellObject objectWithType:InfoNormalTableViewCellObjectTypeUserGuide compact:compact];
}

- (InfoNormalTableViewCellObject *) buildAboutCellObjectWithCompactSize:(BOOL)compact {
  return [InfoNormalTableViewCellObject objectWithType:InfoNormalTableViewCellObjectTypeAbout compact:compact];
}

- (InfoNormalTableViewCellObject *) buildViewBackupPhraseCellObjectWithCompactSize:(BOOL)compact {
  return [InfoNormalTableViewCellObject objectWithType:InfoNormalTableViewCellObjectTypeBackupPhrase compact:compact];
}

- (InfoNormalTableViewCellObject *) buildMakeBackupCellObjectWithCompactSize:(BOOL)compact {
  return [InfoNormalTableViewCellObject objectWithType:InfoNormalTableViewCellObjectTypeMakeBackup compact:compact];
}

- (InfoDestructiveTableViewCellObject *) buildResetWalletCellObjectWithCompactSize:(BOOL)compact {
  return [InfoDestructiveTableViewCellObject objectWithType:InfoDestructiveTableViewCellObjectResetType compact:compact];
}

- (InfoEmptyTableViewCellObject *) buildEmptyCellObject {
  return [InfoEmptyTableViewCellObject object];
}

@end
