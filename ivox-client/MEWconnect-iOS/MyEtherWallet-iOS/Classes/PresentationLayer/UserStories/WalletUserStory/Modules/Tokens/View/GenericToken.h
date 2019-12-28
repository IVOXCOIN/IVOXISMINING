//
//  GenericToken.h
//  MyEtherWallet-iOS
//
//  Created by Victor Lopez on 23/12/19.
//  Copyright © 2019 MyEtherWallet, Inc. All rights reserved.
//

@import UIKit;

@interface GenericToken: NSObject
    @property (nonatomic, strong, nullable) NSNumber* identifier;

    @property (nonatomic, strong, nullable) NSString* currency;

    @property (nonatomic, strong, nullable) NSString* date;

    @property (nonatomic, strong, nullable) NSString* destination;

    @property (nonatomic, strong, nullable) NSString* txIdentifier;

    @property (nonatomic, strong, nullable) NSString* paypal;

    @property (nonatomic, strong, nullable) NSString* purchase;

    @property (nonatomic, strong, nullable) NSString* rate;

    @property (nonatomic, strong, nullable) NSString* source;

    @property (nonatomic, strong, nullable) NSString* status;

    @property (nonatomic, strong, nullable) NSString* value;

    @property (nonatomic, strong, nullable) NSString* wallet;

    @property (nonatomic, strong, nullable) NSString* image;
@end
