//
//  HSHTTPSessionManager.m
//  HTTPSig
//
//  Created by Adam Knight on 8/7/14.
//  Copyright (c) 2014 Adam Knight. All rights reserved.
//

#import "HSHTTPSessionManager.h"
#import "HSURLRequestSigner.h"

@implementation HSHTTPSessionManager

-(NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                           completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
{
	NSError *error = nil;
	NSURLRequest *signedRequest = nil;
	
	if (self.signer) {
		signedRequest = [self.signer signRequest:request error:& error];
		if (error != nil) signedRequest = request;  // Bail out on error. TODO: Real error handler?
	} else {
		signedRequest = request;
	}
	
	return [super dataTaskWithRequest:signedRequest completionHandler:completionHandler];
}

@end
