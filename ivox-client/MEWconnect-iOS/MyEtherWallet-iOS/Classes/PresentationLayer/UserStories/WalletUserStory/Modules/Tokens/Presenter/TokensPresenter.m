//
//  InfoPresenter.m
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 24/06/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//
@import libextobjc.EXTScope;

#import "TokensPresenter.h"

#import "TokensViewInput.h"
#import "TokensInteractorInput.h"
#import "TokensInteractor.h"
#import "TokensRouterInput.h"

#import "ContextPasswordModuleOutput.h"

#import "ApplicationConstants.h"

#import "NSBundle+Version.h"

#import "AccountModelObject.h"
#import "MasterTokenModelObject.h"
#import "IvoxTokenModelObject.h"
#import "EtherTokenModelObject.h"

#import "NSManagedObjectContext+MagicalRecord.h"
#import "NSManagedObject+MagicalFinders.h"

#import "TokensService.h"


@interface TokensPresenter ()
@end

@implementation TokensPresenter

#pragma mark - TokensModuleInput
- (void) configureModuleWithAccountAndMasterToken:(AccountPlainObject *)account masterToken:(MasterTokenPlainObject*)masterToken isEther:(BOOL)isEther {
    [self.interactor configureWithAccountAndMasterToken:account masterToken:masterToken isEther:isEther];
}


#pragma mark - TokensViewOutput

- (void) didTriggerViewReadyEvent {
  NSString *version = [[NSBundle mainBundle] fullApplicationVersion];
  [self.view setupInitialStateWithVersion:version backupAvailability:NO backedStatus:NO];
    
    @weakify(self);
    
    TokensInteractor* interactor = self.interactor;
    
    if([interactor isEther]){
        [interactor.tokensService obtainEtherTokensFromMasterToken:[interactor obtainMasterToken]
                                        withCompletion:^(NSError *error) {
                                          @strongify(self);
                                          if (!error) {

                                              [self setupEtherTokens:(MasterTokenModelObject*)[interactor obtainMasterToken]];
                                        
                                          }
                                        }];


    } else{
        
        [interactor.tokensService obtainIvoxTokensFromMasterToken:[interactor obtainMasterToken]
                                        withCompletion:^(NSError *error) {
                                          @strongify(self);
                                          if (!error) {

                                              [self setupIvoxTokens:(MasterTokenModelObject*)[interactor obtainMasterToken]];
                                        
                                          }
                                        }];

    }
    

    
}

- (void) setupEtherTokens:(MasterTokenModelObject*)masterToken{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.fromNetwork.master.address ==[c] %@", masterToken.address];
    NSArray <EtherTokenModelObject *> *tokens = [EtherTokenModelObject MR_findAllWithPredicate:predicate inContext:context];
    
    [self.view addEtherTokensAndRefresh:tokens];
}

- (void) setupIvoxTokens:(MasterTokenModelObject*)masterToken{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.fromNetwork.master.address ==[c] %@", masterToken.address];
    NSArray <IvoxTokenModelObject *> *tokens = [IvoxTokenModelObject MR_findAllWithPredicate:predicate inContext:context];
    
    [self.view addIvoxTokensAndRefresh:tokens];
}

- (void) closeAction {
  [self.router close];
}

- (void) userGuideAction {
  [self.router openUserGuide];
}

#pragma mark - TokensInteractorOutput

@end
