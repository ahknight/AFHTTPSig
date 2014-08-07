//
//  HSURLRequestSigner.h
//  HTTPSig
//
//  Created by Adam Knight on 8/7/14.
//  Copyright (c) 2014 Adam Knight. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString *HSErrorDomain;
//extern NSString *HSAlgoRsaSha1;
//extern NSString *HSAlgoRsaSha256;
extern NSString *HSAlgoHmacSha1;
extern NSString *HSAlgoHmacSha256;
extern NSString *HSAlgoHmacSha512;


/// Signs NSURLRequests.
@interface HSURLRequestSigner : NSObject

@property (copy, nonatomic)     NSString *keyID;
@property (copy, nonatomic)     NSString *secret;
@property (retain, nonatomic)   NSString *algorithm;
@property (copy, nonatomic)     NSArray *signHeaders;

/// Sign an NSURLRequest with the given parameters.
+(NSURLRequest *)signHeaders:(NSArray *)signHeaders
                   ofRequest:(NSURLRequest *)request
                   withKeyID:(NSString *)keyID
                   andSecret:(NSString *)secret
                   algorithm:(NSString *)algorithm
                       error:(NSError **)outError;

/// Convenience initializer.
-(instancetype)initWithKeyID:(NSString *)keyID
                      secret:(NSString *)secret
                   algorithm:(NSString *)algorithm
                 signHeaders:(NSArray *)signHeaders;

/// Signs a request using the signer's current configuration.
-(NSURLRequest *)signRequest:(NSURLRequest *)request error:(NSError **)error;

@end
