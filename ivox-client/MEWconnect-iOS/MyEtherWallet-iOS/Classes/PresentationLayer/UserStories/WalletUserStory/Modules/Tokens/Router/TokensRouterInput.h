//
//  InfoRouterInput.h
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 24/06/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

@import Foundation;

@protocol TokensRouterInput <NSObject>
- (void) close;
- (void) unwindToStart;
- (void) openUserGuide;
@end
