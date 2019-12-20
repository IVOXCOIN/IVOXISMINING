//
//  TokensServiceImplementation.h
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 20/05/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

#import "TokensService.h"

@class TokensOperationFactory;
@protocol OperationScheduler;
@protocol AccountsService;

@interface TokensServiceImplementation : NSObject <TokensService>
@property (nonatomic, strong) TokensOperationFactory *tokensOperationFactory;
@property (nonatomic, strong) id <OperationScheduler> operationScheduler;
@property (nonatomic, strong) id <AccountsService> accountsService;
@end
