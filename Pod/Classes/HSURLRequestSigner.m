//
//  HSURLRequestSigner.m
//  HTTPSig
//
//  Created by Adam Knight on 8/7/14.
//  Copyright (c) 2014 Adam Knight. All rights reserved.
//

#import <AFHTTPSig/HSURLRequestSigner.h>
#import <AFHTTPSig/NSDate+NSDateRFC1123.h>
#import <CocoaSecurity.h>


NSString *HSErrorDomain     = @"HTTPSIG";
//NSString *HSAlgoRsaSha1     = @"rsa-sha1";
//NSString *HSAlgoRsaSha256   = @"rsa-sha256";
NSString *HSAlgoHmacSha1	= @"hmac-sha1";
NSString *HSAlgoHmacSha256  = @"hmac-sha256";
NSString *HSAlgoHmacSha512  = @"hmac-sha512";


@implementation HSURLRequestSigner

+(NSURLRequest *)signHeaders:(NSArray *)signHeaders
                   ofRequest:(NSURLRequest *)request
                   withKeyID:(NSString *)keyID
                   andSecret:(NSString *)secret
                   algorithm:(NSString *)algorithm
                       error:(NSError **)error
{
	// Ensure we have what we need
	if (!keyID) {
		if (error != NULL)
			*error = [NSError errorWithDomain:HSErrorDomain code:-1 userInfo:@{ NSLocalizedDescriptionKey: @"keyId not set" }];
		return nil;
	}
	if (!secret) {
		if (error != NULL)
			*error = [NSError errorWithDomain:HSErrorDomain code:-1 userInfo:@{ NSLocalizedDescriptionKey: @"secret not set" }];
		return nil;
	}
	
	NSMutableURLRequest *mutableRequest = [request mutableCopy];
	
	// Build message
	NSMutableArray *messageLines = [NSMutableArray new];
	NSDictionary *requestHeaders = [mutableRequest allHTTPHeaderFields];
	
	for (NSString *header in signHeaders) {
		NSString *value = nil;
		
		if ([header isEqualToString:@"(request-line)"]) {
			/*
			 We need the portion of the URL after the host EXACTLY as it will be sent. Therefore, we search for the path in the URL and then grab everything after. This ensures we get things like the fragment and query args in exactly the same order they will be sent to the server.
			 */
			NSURL *url = mutableRequest.URL;
			NSString *urlString = [url absoluteString];
			NSString *requestPath = nil;
			
			NSRange range = [urlString rangeOfString:url.path options:NSCaseInsensitiveSearch];
			if (range.location == NSNotFound) return nil;
			range = NSMakeRange(range.location, urlString.length - range.location);
			requestPath = [urlString substringWithRange:range];
			
			value = [NSString stringWithFormat:@"%@ %@", mutableRequest.HTTPMethod.lowercaseString, requestPath];
			
		} else if ([header isEqualToString:@"date"]) {
			value = [[NSDate date] rfc1123String];
			[mutableRequest setValue:value forHTTPHeaderField:@"Date"];
			
		} else if ([header isEqualToString:@"x-nonce"]) {
			// Optional. Include X-Nonce as a header to activate.
			// Ensures that if two identical requests are sent in the same second that the sig is different.
			// Also, with server support, prevents replay attacks for the duration of the date/time window.
			
			// rndData takes ownership of the rnd allocation and frees it when it is released.
			const NSUInteger dataLen = 1024;
			uint8_t* rnd = calloc(dataLen, sizeof(uint8_t));
			NSData *rndData = [NSData dataWithBytesNoCopy:rnd length:dataLen freeWhenDone:YES];
			
			if (SecRandomCopyBytes(NULL, dataLen, rnd)) {
				//fail
				if (error != NULL)
					*error = [NSError errorWithDomain:HSErrorDomain
					                             code:-1
					                         userInfo:@{ NSLocalizedDescriptionKey: @"SecRandomCopyBytes failed" }];
				return nil;
			}
			
			value = [CocoaSecurity sha256WithData:rndData].base64;
			[mutableRequest setValue:value forHTTPHeaderField:@"X-Nonce"];
			
		} else {
			value = [requestHeaders objectForKey:header];
			if (value == nil) {
				if (error != NULL)
					*error = [NSError errorWithDomain:HSErrorDomain
					                             code:-1
					                         userInfo:@{
														NSLocalizedDescriptionKey: @"Missing required header.",
														NSLocalizedFailureReasonErrorKey: header
														}
							  ];
				return nil;
			}
		}
		
		[messageLines addObject:[NSString stringWithFormat:@"%@: %@", [header lowercaseString], value]];
	}
	
#ifdef DEBUG
	NSLog(@"%@", [mutableRequest allHTTPHeaderFields]);
#endif
	
	// HMAC message
	NSString *message = [messageLines componentsJoinedByString:@"\n"];
	NSString *signature = nil;
	
	if ([algorithm isEqualToString:HSAlgoHmacSha256]) {
		signature = [CocoaSecurity hmacSha256:message hmacKey:secret].base64;
		
	} else if ([algorithm isEqualToString:HSAlgoHmacSha512]) {
		signature = [CocoaSecurity hmacSha512:message hmacKey:secret].base64;
		
	} else if ([algorithm isEqualToString:HSAlgoHmacSha1]) {
		signature = [CocoaSecurity hmacSha1:message hmacKey:secret].base64;
		
	} else {
		if (error != NULL)
			*error = [NSError errorWithDomain:HSErrorDomain
			                             code:-1
			                         userInfo:@{ NSLocalizedDescriptionKey: @"Unsupported algorithm." }];
		return nil;
	}
	
#ifdef DEBUG
	NSLog(@"Message: %@", message);
	NSLog(@"Signature: %@", signature);
#endif
	
	// Create and add header
	NSString *authValue = [NSString stringWithFormat:
	                       @"Signature keyId=\"%@\",algorithm=\"%@\",signature=\"%@\",headers=\"%@\"",
	                       keyID,
	                       algorithm,
	                       signature,
	                       [signHeaders componentsJoinedByString:@" "]
						   ];
	
	[mutableRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
	
#ifdef DEBUG
	NSLog(@"Authorization: %@", authValue);
#endif
	
	return [mutableRequest copy];
}

-(instancetype)initWithKeyID:(NSString *)keyID secret:(NSString *)secret algorithm:(NSString *)algorithm signHeaders:(NSArray *)signHeaders
{
	if ((self = [super init])) {
		self.keyID = keyID;
		self.secret = secret;
		
		if (algorithm) {
			self.algorithm = algorithm;
		} else {
			self.algorithm = HSAlgoHmacSha256;
		}
		
		if (signHeaders) {
			self.signHeaders = signHeaders;
		} else {
			self.signHeaders = @[@"date"]; // per spec, if headers is unspecified then we use just Date.
		}
	}
	return self;
}

-(NSURLRequest *)signRequest:(NSURLRequest *)request error:(NSError **)error
{
	NSError *outError = nil;
	NSURLRequest *signedRequest = [self.class signHeaders:self.signHeaders
	                                            ofRequest:request
	                                            withKeyID:self.keyID
	                                            andSecret:self.secret
	                                            algorithm:self.algorithm
	                                                error:& outError];
	if (error != nil) *error = outError;
	
	return signedRequest;
}

@end
