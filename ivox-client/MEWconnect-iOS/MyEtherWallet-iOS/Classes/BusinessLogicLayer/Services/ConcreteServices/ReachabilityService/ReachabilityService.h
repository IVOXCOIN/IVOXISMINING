//
//  ReachabilityService.h
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 31/07/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

@import Foundation;

@protocol ReachabilityService <NSObject>
- (BOOL) isReachable;
@end
