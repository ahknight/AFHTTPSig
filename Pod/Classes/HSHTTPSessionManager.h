//
//  HSHTTPSessionManager.h
//  HTTPSig
//
//  Created by Adam Knight on 8/7/14.
//  Copyright (c) 2014 Adam Knight. All rights reserved.
//

#import <AFNetworking/AFHTTPSessionManager.h>
#import "HSURLRequestSigner.h"

@interface HSHTTPSessionManager : AFHTTPSessionManager

@property (retain, nonatomic) HSURLRequestSigner* signer;

@end
