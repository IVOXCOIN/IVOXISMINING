//
//  TokensServiceImplementation.m
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 20/05/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

@import MagicalRecord;

#import "OperationScheduler.h"
#import "CompoundOperationBase.h"

#import "TokensOperationFactory.h"

#import "TokensServiceImplementation.h"

#import "TokensBody.h"
#import "MasterTokenBody.h"

#import "MasterTokenModelObject.h"
#import "MasterTokenPlainObject.h"
#import "AccountModelObject.h"
#import "BalanceModelObject.h"
#import "TokenModelObject.h"
#import "TokenPlainObject.h"
#import "FiatPriceModelObject.h"
#import "NetworkModelObject.h"
#import "NetworkPlainObject.h"

#import "AccountsService.h"


#define DEBUG_BALANCE 0
#define DEBUG_TOKENS 0

#if !DEBUG
  #undef DEBUG_BALANCE
  #undef DEBUG_TOKENS
  #define DEBUG_TOKENS 0
  #define DEBUG_BALANCE 0
#endif

#if DEBUG_TOKENS || DEBUG_BALANCE
static NSString *const kMEWDonateAddress = @"0xDECAF9CD2367cdbb726E904cD6397eDFcAe6068D";
#endif

static NSString *const TokensABI = @"[{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"},{\"name\":\"name\",\"type\":\"bool\"},{\"name\":\"website\",\"type\":\"bool\"},{\"name\":\"email\",\"type\":\"bool\"},{\"name\":\"count\",\"type\":\"uint256\"}],\"name\":\"getAllBalance\",\"outputs\":[{\"name\":\"\",\"type\":\"bytes\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"}]";
static NSString *const MainnetTokensContractAddress = @"0x2783c0a4bfd3721961653a9e9939fc63687bf07f";
static NSString *const RopstenTokensContractAddress = @"0xb8e1bbc50fd87ea00d8ce73747ac6f516af26dac";

@implementation TokensServiceImplementation

- (void) performRateLookup:(MasterTokenPlainObject *)masterToken withCompletion:(TokensServiceCompletion)completion balanceMethod:(NSString *)balanceMethodString isUSD:(BOOL)isUSDLookup{
    NSManagedObjectContext *rootSavingContext = [NSManagedObjectContext MR_rootSavingContext];
    
    [rootSavingContext performBlock:^{
        
        NSLocale *locale = [NSLocale currentLocale];

        NSDictionary *jsonBodyDict = @{@"method":balanceMethodString, @"tag":isUSDLookup?@"USD":[locale currencyCode]};
        
        NSData *jsonBodyData = [NSJSONSerialization dataWithJSONObject:jsonBodyDict options:kNilOptions error:nil];

        NSString *urlString = @"https://ivoxis-backend.azurewebsites.net/api/currency/get";

        NSMutableURLRequest *request = [NSMutableURLRequest new];
        request.HTTPMethod = @"POST";

        // for alternative 1:
        [request setURL:[NSURL URLWithString:urlString]];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setHTTPBody:jsonBodyData];
       
       NSURLSession *session = [NSURLSession sharedSession];
       NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           
           BOOL hasError = false;

           if (!error) {
               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
               if(httpResponse.statusCode == 200)
               {
                  @try {
                      NSError *parseError = nil;
                      NSArray *responseArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
                      NSLog(@"The response is - %@",responseArray);


                      NSDictionary *item = responseArray[0];
                      NSDecimalNumber *rate = [NSDecimalNumber decimalNumberWithString:[item objectForKey:@"rate"]];

                      MasterTokenModelObject *masterTokenModelObject = [MasterTokenModelObject MR_findFirstByAttribute:NSStringFromSelector(@selector(address)) withValue:masterToken.address inContext:rootSavingContext];

                      
                      NSEntityDescription *fiatPriceEntity = [NSEntityDescription entityForName:@"FiatPrice" inManagedObjectContext:rootSavingContext];
                      FiatPriceModelObject *fiatPrice = (FiatPriceModelObject *)[[NSManagedObject alloc] initWithEntity:fiatPriceEntity insertIntoManagedObjectContext:rootSavingContext];

                      
                      fiatPrice.usdPrice = rate;
                      masterTokenModelObject.price = fiatPrice;
                      AccountModelObject* account =
                      
                      [AccountModelObject MR_findFirstByAttribute:NSStringFromSelector(@selector(active)) withValue:@YES inContext:rootSavingContext];
                      
                      [account setCurrency:isUSDLookup?@"USD":[locale currencyCode]];
                      
                      [self.accountsService setCurrency:account currency:account.currency];
                      
                  }
           
                  @catch ( NSException *e ) {
                      hasError = true;
                  }
               }
               else {
                   hasError = true;
               }
           }
           else {
               hasError = true;
           }
           
           if ([rootSavingContext hasChanges]) {
             [rootSavingContext MR_saveToPersistentStoreWithCompletion:^(__unused BOOL contextDidSave, __unused NSError * _Nullable saveError) {

                 if(!hasError){
                     dispatch_async(dispatch_get_main_queue(), ^{
                       if (completion) {
                         completion(error);
                       }
                     });
                 } else {
                     if(!isUSDLookup){
                         [self performRateLookup:masterToken withCompletion:completion balanceMethod:balanceMethodString isUSD:true];
                     }else {
                         dispatch_async(dispatch_get_main_queue(), ^{
                           if (completion) {
                             completion(error);
                           }
                         });
                     }
                 }

             }];
           } else {
               if(!hasError){
                   dispatch_async(dispatch_get_main_queue(), ^{
                     if (completion) {
                       completion(error);
                     }
                   });
               } else {
                   if(!isUSDLookup){
                       [self performRateLookup:masterToken withCompletion:completion balanceMethod:balanceMethodString isUSD:true];
                   }else {
                       dispatch_async(dispatch_get_main_queue(), ^{
                         if (completion) {
                           completion(error);
                         }
                       });
                   }
               }

           }
       }];
       
       [dataTask resume];
    
    }];

}

- (void) updateBalanceOfMasterToken:(MasterTokenPlainObject *)masterToken withCompletion:(TokensServiceCompletion)completion {
  NSManagedObjectContext *rootSavingContext = [NSManagedObjectContext MR_rootSavingContext];
  
    AccountModelObject* account =
    
    [AccountModelObject MR_findFirstByAttribute:NSStringFromSelector(@selector(active)) withValue:@YES inContext:rootSavingContext];

    NSString *formattedEthereumAddress = masterToken.address;
    
    NSDictionary *jsonBodyDict = @{@"account":formattedEthereumAddress, @"method":account.balanceMethod};
    NSData *jsonBodyData = [NSJSONSerialization dataWithJSONObject:jsonBodyDict options:kNilOptions error:nil];

    NSString *urlString = @"https://ivoxis-backend.azurewebsites.net/ethereum/balance";

    NSMutableURLRequest *request = [NSMutableURLRequest new];
    request.HTTPMethod = @"POST";

    // for alternative 1:
    [request setURL:[NSURL URLWithString:urlString]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:jsonBodyData];
  
  [rootSavingContext performBlock:^{
    
      NSURLSession *session = [NSURLSession sharedSession];
      NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

          BOOL hasError = false;
          
           if (!error) {
               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
               if(httpResponse.statusCode == 200)
               {
                    NSError *parseError = nil;
                    NSArray *responseArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
                    NSLog(@"The response is - %@",responseArray);


                    NSDictionary *item = responseArray[0];
                    NSDecimalNumber *balance = [NSDecimalNumber decimalNumberWithString:[item objectForKey:@"BALANCE"]];

                    MasterTokenModelObject *masterTokenModelObject = [MasterTokenModelObject MR_findFirstByAttribute:NSStringFromSelector(@selector(address)) withValue:masterToken.address inContext:rootSavingContext];
                    
                    masterTokenModelObject.balance = balance;
                    masterTokenModelObject.decimals = [NSNumber numberWithInt:18];
                    masterTokenModelObject.symbol = account.balanceMethod;

               }
               else
               {
                   NSLog(@"Error");
                   hasError = true;
               }
           }
           else {
               NSLog(@"Error");
               hasError = true;
           }
          
       if ([rootSavingContext hasChanges]) {
         [rootSavingContext MR_saveToPersistentStoreWithCompletion:^(__unused BOOL contextDidSave, __unused NSError * _Nullable saveError) {

             if(!hasError){
                 [self performRateLookup:masterToken withCompletion:completion balanceMethod:account.balanceMethod isUSD:false];
             } else {
                 dispatch_async(dispatch_get_main_queue(), ^{
                   if (completion) {
                     completion(error);
                   }
                 });
             }

         }];
       } else {
           if(!hasError){
               [self performRateLookup:masterToken withCompletion:completion balanceMethod:account.balanceMethod isUSD:false];
           } else {
               dispatch_async(dispatch_get_main_queue(), ^{
                 if (completion) {
                   completion(error);
                 }
               });
           }
       }

       }];
       [dataTask resume];
  }];

}

- (void) updateTokenBalancesOfMasterToken:(MasterTokenPlainObject *)masterToken withCompletion:(TokensServiceCompletion)completion {
  /*
    
    NSManagedObjectContext *rootSavingContext = [NSManagedObjectContext MR_rootSavingContext];
  
#if DEBUG_TOKENS
  NSString *originalPublicAddress = masterToken.address;
  if ([masterToken.fromNetworkMaster network] == BlockchainNetworkTypeMainnet) {
    masterToken.address = kMEWDonateAddress;
  }
#endif
  
  NSString *contractAddress = nil;
  BlockchainNetworkType network = [masterToken.fromNetworkMaster network];
  if (network == BlockchainNetworkTypeEthereum) {
    contractAddress = MainnetTokensContractAddress;
  } else {
    contractAddress = RopstenTokensContractAddress;
  }
  
  TokensBody *body = [self obtainTokensBodyWithToken:masterToken
                                     contractAddresses:@[contractAddress]];
#if DEBUG_TOKENS
  masterToken.address = originalPublicAddress;
#endif
  [rootSavingContext performBlock:^{
    CompoundOperationBase *compoundOperation = [self.tokensOperationFactory contractBalancesWithBody:body inNetwork:network];
    [compoundOperation setResultBlock:^(NSArray <TokenModelObject *> *data, NSError *error) {
      if (!error) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.master.address ==[c] %@", masterToken.address];
        NetworkModelObject *networkModelObject = [NetworkModelObject MR_findFirstWithPredicate:predicate inContext:rootSavingContext];
        if ([data isKindOfClass:[NSArray class]]) {
          if ([networkModelObject.tokens count] == 0) {
            [networkModelObject addTokens:[NSSet setWithArray:data]];
          } else {
            NSMutableArray *tokensToAdd = [[NSMutableArray alloc] initWithArray:data];
            NSMutableArray *tokensToDelete = [[NSMutableArray alloc] initWithCapacity:0];
            
            NSArray <TokenModelObject *> *tokens = [networkModelObject.tokens allObjects];
            for (TokenModelObject *token in tokens) {
              NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.address ==[c] %@", token.address];
              TokenModelObject *refreshingToken = [[data filteredArrayUsingPredicate:predicate] firstObject];
              if (refreshingToken) {
                [tokensToAdd removeObject:refreshingToken];
                token.balance = refreshingToken.balance;
                token.decimals = refreshingToken.decimals;
                [tokensToDelete addObject:refreshingToken];
              } else {
                [tokensToDelete addObject:token];
              }
            }
            if ([tokensToDelete count] > 0) {
              [rootSavingContext MR_deleteObjects:tokensToDelete];
            }
            if ([tokensToAdd count] > 0) {
              [networkModelObject addTokens:[NSSet setWithArray:tokensToAdd]];
            }
          }
        }
      }
      if ([rootSavingContext hasChanges]) {
        [rootSavingContext MR_saveToPersistentStoreWithCompletion:^(__unused BOOL contextDidSave, __unused NSError * _Nullable saveError) {
          dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
              completion(error);
            }
          });
        }];
      } else {
        dispatch_async(dispatch_get_main_queue(), ^{
          if (completion) {
            completion(error);
          }
        });
      }
    }];
    [self.operationScheduler addOperation:compoundOperation];
  }];
    
    */
    
        NSManagedObjectContext *rootSavingContext = [NSManagedObjectContext MR_rootSavingContext];
      
 
      NSString *contractAddress = nil;
      BlockchainNetworkType network = [masterToken.fromNetworkMaster network];
      if (network == BlockchainNetworkTypeEthereum) {
        contractAddress = MainnetTokensContractAddress;
      } else {
        contractAddress = RopstenTokensContractAddress;
      }
    
    [self resetBalances];
    [self resetTokensButMaster];

    [rootSavingContext performBlock:^{

    NSString *formattedEthereumAddress = [masterToken.address lowercaseString];

    NSDictionary *jsonBodyDict = @{@"source":formattedEthereumAddress};
    NSData *jsonBodyData = [NSJSONSerialization dataWithJSONObject:jsonBodyDict options:kNilOptions error:nil];

    NSString *urlString = @"https://ivoxis-backend.azurewebsites.net/api/balance/get";

    NSMutableURLRequest *request = [NSMutableURLRequest new];
    request.HTTPMethod = @"POST";

    [request setURL:[NSURL URLWithString:urlString]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:jsonBodyData];


    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

      if (!error) {
          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
          if(httpResponse.statusCode == 200)
          {
              NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.master.address ==[c] %@", masterToken.address];
              NetworkModelObject *networkModelObject = [NetworkModelObject MR_findFirstWithPredicate:predicate inContext:rootSavingContext];

              NSError *parseError = nil;
              NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
              NSLog(@"The response is - %@",responseDictionary);
              
              NSMutableArray *balancesToAdd = [[NSMutableArray alloc] initWithCapacity:0];
              
              for(NSDictionary * item in responseDictionary)
              {
                  NSString *paypal = [item objectForKey:@"paypal"];
                  NSString *wallet = [item objectForKey:@"wallet"];
                  NSString *source = [item objectForKey:@"source"];
                  NSString *identifier = [item objectForKey:@"id"];
                  NSString *destination = [item objectForKey:@"destination"];
                  NSString *purchase = [item objectForKey:@"purchase"];
                  NSString *date = [item objectForKey:@"date"];
                  NSString *status = [item objectForKey:@"status"];
                  NSString *value = [item objectForKey:@"value"];

                  NSEntityDescription *balanceEntity = [NSEntityDescription entityForName:@"Balance" inManagedObjectContext:rootSavingContext];
                  BalanceModelObject *balance = (BalanceModelObject *)[[NSManagedObject alloc] initWithEntity:balanceEntity insertIntoManagedObjectContext:rootSavingContext];
                  
                  balance.fromNetwork = (NetworkModelObject *) masterToken.fromNetwork;
                  balance.total = [NSDecimalNumber decimalNumberWithString:value];
                  
                  [balancesToAdd addObject:balance];

              }

              if ([balancesToAdd count] > 0) {
                [networkModelObject addBalances:[NSSet setWithArray:balancesToAdd]];
              }


          }
          else
          {
              NSLog(@"Error");
          }
      }
      else {
          NSLog(@"Error");
      }
      
      if ([rootSavingContext hasChanges]) {
        [rootSavingContext MR_saveToPersistentStoreWithCompletion:^(__unused BOOL contextDidSave, __unused NSError * _Nullable saveError) {
          dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
              completion(error);
            }
          });
        }];
      } else {
        dispatch_async(dispatch_get_main_queue(), ^{
          if (completion) {
            completion(error);
          }
        });
      }
      
    }];
    [dataTask resume];
    }];
}

- (NSUInteger) obtainNumberOfTokensOfMasterToken:(MasterTokenPlainObject *)masterToken {
  NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.fromNetwork.master.address ==[c] %@", masterToken.address];
  return [TokenModelObject MR_countOfEntitiesWithPredicate:predicate inContext:context];
}

- (NSDecimalNumber *) obtainTokensTotalPriceOfMasterToken:(MasterTokenPlainObject *)masterToken {
  NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.fromNetwork.master.address ==[c] %@", masterToken.address];
  NSArray <BalanceModelObject *> *balances = [BalanceModelObject MR_findAllWithPredicate:predicate inContext:context];
  NSDecimalNumber *totalPrice = [NSDecimalNumber zero];
  for (BalanceModelObject *balanceModelObject in balances) {
      
      totalPrice = [totalPrice decimalNumberByAdding:balanceModelObject.total];
      
      /*
    NSDecimalNumber *decimals = [NSDecimalNumber decimalNumberWithMantissa:1 exponent:[tokenModelObject.decimals shortValue] isNegative:NO];
    NSDecimalNumber *tokenBalance = [tokenModelObject.balance decimalNumberByDividingBy:decimals];
    NSDecimalNumber *price = [tokenBalance decimalNumberByMultiplyingBy:tokenModelObject.price.usdPrice];
    totalPrice = [totalPrice decimalNumberByAdding:price];*/
  }
  return totalPrice;
}

- (MasterTokenModelObject *) obtainActiveMasterToken {
  NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.fromNetworkMaster.active = YES && SELF.fromNetworkMaster.fromAccount.active = YES"];
  MasterTokenModelObject *masterToken = [MasterTokenModelObject MR_findFirstWithPredicate:predicate inContext:context];
  return masterToken;
}

- (TokenModelObject *) obtainTokenWithAddress:(NSString *)address ofMasterToken:(MasterTokenPlainObject *)masterToken {
  if (!address) {
    return nil;
  }
  NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.address ==[c] %@ && SELF.fromNetwork.master.address ==[c] %@", address, masterToken.address];
  TokenModelObject *tokenModelObject = [TokenModelObject MR_findFirstWithPredicate:predicate inContext:context];
  return tokenModelObject;
}

- (void) resetTokens {
  NSManagedObjectContext *rootSavingContext = [NSManagedObjectContext MR_rootSavingContext];
  [rootSavingContext performBlockAndWait:^{
    NSArray <TokenModelObject *> *tokens = [TokenModelObject MR_findAllInContext:rootSavingContext];
    [rootSavingContext MR_deleteObjects:tokens];
    [rootSavingContext MR_saveToPersistentStoreAndWait];
  }];
}

- (void) resetTokensButMaster {
    NSManagedObjectContext *rootSavingContext = [NSManagedObjectContext MR_rootSavingContext];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
     fetchRequest.entity = [NSEntityDescription entityForName:@"Token" inManagedObjectContext:rootSavingContext];

     NSArray *results = [rootSavingContext executeFetchRequest:fetchRequest error:nil];

     for (TokenModelObject *Entity in results) {
         if(![Entity isKindOfClass:[MasterTokenModelObject class]]){
             [rootSavingContext deleteObject:Entity];
         }
     }

}

- (void) resetBalances {
    NSManagedObjectContext *rootSavingContext = [NSManagedObjectContext MR_rootSavingContext];
    [rootSavingContext performBlockAndWait:^{
      NSArray <BalanceModelObject *> *balances = [BalanceModelObject MR_findAllInContext:rootSavingContext];
      [rootSavingContext MR_deleteObjects:balances];
      [rootSavingContext MR_saveToPersistentStoreAndWait];
    }];

}

#pragma mark - Private

- (TokensBody *) obtainTokensBodyWithToken:(MasterTokenPlainObject *)token contractAddresses:(NSArray <NSString *>*)contractAddresses {
  TokensBody *body = [[TokensBody alloc] init];
  body.address = token.address;
  body.contractAddresses = contractAddresses;
  body.abi = TokensABI;
  body.method = @"getAllBalance";
  body.nameRequired = YES;
  return body;
}

- (MasterTokenBody *) obtainMasterTokenBodyWithMasterToken:(MasterTokenPlainObject *)masterToken {
  MasterTokenBody *body = [[MasterTokenBody alloc] init];
  body.address = masterToken.address;
  return body;
}

@end
