//
//  CleanLaunchAppDelegate.m
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 15/04/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

#import "CleanLaunchAppDelegate.h"

#import "CleanLaunchRouter.h"
#import "ApplicationConfigurator.h"
#import "ThirdPartiesConfigurator.h"
#import "MigrationService.h"
#import "CoreDataConfigurator.h"
#import "CrashCatcherConfigurator.h"

#import "PayPalMobile.h"


@implementation CleanLaunchAppDelegate

- (BOOL) application:(__unused UIApplication *)application didFinishLaunchingWithOptions:(__unused NSDictionary *)launchOptions {
  [self.crashCatcherConfigurator configurate];
  [self.thirdPartiesConfigurator configurate];
  if ([self.migrationService isMigrationNeeded]) {
    NSError *error = nil;
    [self.migrationService migrate:&error];
    if (error) {
      NSLog(@"%@", error);
    }
  } else if ([self.migrationService isMigrationNeededForKeychain]) {
    NSError *error = nil;
    [self.migrationService migratekeychain:&error];
    if (error) {
      NSLog(@"%@", error);
    }
  }
  [self.coreDataConfigurator setupCoreDataStack];
  [self.applicationConfigurator configureInitialSettings];
  [self.applicationConfigurator configurateAppearance];
  [self.cleanStartRouter openInitialScreen];
    #warning "Enter your credentials"
    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction : @"AT9bbsd8BR0a3fJoasIcSjAVo0av2HCRbZYRYEoJoy97khQWV3vKa-txCP3FE4zq-NexrxtinZmZBOKh",
                                                           PayPalEnvironmentSandbox : @"AXL5V4cY1Max_pu3I2_4W9XAWnAWNa30aBshR6v4Cpzn4T8Q_RsNHGEOSgCT3b1X9dmmQjGnPqU6AHkg"}];

    
  return YES;
}

- (void)applicationWillTerminate:(__unused UIApplication *)application {
  [self.thirdPartiesConfigurator cleanup];
}

@end
