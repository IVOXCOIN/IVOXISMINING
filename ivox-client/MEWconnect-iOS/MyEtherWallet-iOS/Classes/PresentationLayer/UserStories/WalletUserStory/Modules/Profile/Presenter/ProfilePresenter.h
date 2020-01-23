//
//  ProfilePresenter.h
//  MyEtherWallet-iOS
//
//  Created by Victor Lopez on 17/01/20.
//  Copyright © 2020 MyEtherWallet, Inc. All rights reserved.
//

#import "ProfileModuleInput.h"

@protocol ProfileViewInput;
@protocol ProfileRouterInput;

@interface ProfilePresenter : NSObject <ProfileModuleInput>

@property (nonatomic, weak) id<ProfileViewInput> view;
@property (nonatomic, strong) id<ProfileRouterInput> router;

@end
