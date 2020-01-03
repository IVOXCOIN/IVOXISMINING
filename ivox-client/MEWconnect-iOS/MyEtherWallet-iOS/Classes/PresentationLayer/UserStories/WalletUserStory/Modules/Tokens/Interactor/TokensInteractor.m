//
//  InfoInteractor.m
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 24/06/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

#import "TokensInteractor.h"

#import "TokensInteractorOutput.h"

#import "AccountsService.h"
#import "KeychainService.h"
#import "TokensService.h"
#import "MEWwallet.h"
#import "Ponsomizer.h"

#import "AccountPlainObject.h"
#import "MasterTokenPlainObject.h"
#import "NetworkPlainObject.h"
#import "TokenPlainObject.h"

@interface TokensInteractor ()
@property (nonatomic, strong) AccountPlainObject *account;
@property (nonatomic, strong) MasterTokenPlainObject *masterToken;
@property (nonatomic) BOOL displayIsEther;
@end

@implementation TokensInteractor

#pragma mark - TokensInteractorInput
- (void) configureWithAccountAndMasterToken:(AccountPlainObject *)account masterToken:(MasterTokenPlainObject*)masterToken isEther:(BOOL)isEther{
    self.account = account;
    self.masterToken = masterToken;
    self.displayIsEther = isEther;
}

-(MasterTokenPlainObject*)obtainMasterToken{
    return self.masterToken;
}

-(BOOL) isEther{
    return self.displayIsEther;
}

@end
