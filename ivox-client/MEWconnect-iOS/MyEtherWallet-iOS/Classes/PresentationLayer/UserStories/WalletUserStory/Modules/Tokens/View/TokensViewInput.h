//
//  InfoViewInput.h
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 24/06/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

@import Foundation;

@class IvoxTokenModelObject;
@class EtherTokenModelObject;

@protocol TokensViewInput <NSObject>
- (void) setupInitialStateWithVersion:(NSString *)version backupAvailability:(BOOL)available backedStatus:(BOOL)isBackedUp;
-(void) addIvoxTokensAndRefresh:(NSArray <IvoxTokenModelObject *> *)tokens;

-(void) addEtherTokensAndRefresh:(NSArray <EtherTokenModelObject *> *)tokens;
@end
