//
//  InfoPresenter.h
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 24/06/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

#import "TokensViewOutput.h"
#import "TokensInteractorOutput.h"
#import "TokensModuleInput.h"

@protocol TokensViewInput;
@protocol TokensInteractorInput;
@protocol TokensRouterInput;

@interface TokensPresenter : NSObject <TokensModuleInput, TokensViewOutput, TokensInteractorOutput>

@property (nonatomic, weak) id<TokensViewInput> view;
@property (nonatomic, strong) id<TokensInteractorInput> interactor;
@property (nonatomic, strong) id<TokensRouterInput> router;

@end
