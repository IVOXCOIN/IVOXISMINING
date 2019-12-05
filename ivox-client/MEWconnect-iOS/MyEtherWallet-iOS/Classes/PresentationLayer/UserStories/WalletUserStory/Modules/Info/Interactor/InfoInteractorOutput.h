//
//  InfoInteractorOutput.h
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 24/06/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

@import Foundation;

@protocol InfoInteractorOutput <NSObject>
- (void) mnemonicsDidReceived:(NSArray <NSString *> *)mnemonics;
@end
