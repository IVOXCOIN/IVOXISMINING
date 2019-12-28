//
//  InfoViewInput.h
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 24/06/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

@import Foundation;

@protocol InfoViewInput <NSObject>
- (void) setupInitialStateWithVersion:(NSString *)version backupAvailability:(BOOL)available backedStatus:(BOOL)isBackedUp;
- (void) updateWithBackupAvailability:(BOOL)avaiable backupStatus:(BOOL)isBackedUp;
- (void) presentResetConfirmation;
- (void) presentMailComposeWithSubject:(NSString *)subject recipients:(NSArray <NSString *> *)recipients;
@end
