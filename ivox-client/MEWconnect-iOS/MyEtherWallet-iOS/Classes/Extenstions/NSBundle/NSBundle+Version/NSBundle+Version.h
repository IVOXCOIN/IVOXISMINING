//
//  NSBundle+Version.h
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 26/06/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

@import Foundation;

@interface NSBundle (Version)
- (NSString *) fullApplicationVersion;
- (NSString *) applicationVersion;
- (NSString *) applicationBuild;
@end
