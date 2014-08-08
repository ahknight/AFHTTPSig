//
//  HTTPSigTests.m
//  HTTPSigTests
//
//  Created by Adam Knight on 6/25/14.
//  Copyright (c) 2014 Adam Knight. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AFHTTPSig/AFHTTPSig.h>

#include <unistd.h>
#include <stdio.h>
#include <arpa/inet.h>

int check_port(char* host, unsigned port)
{
	int sockd, status;
	struct sockaddr_in serv_name;
	
	/* create a socket */
	sockd = socket(AF_INET, SOCK_STREAM, 0);
	if (sockd < 0) {
		perror("socket");
		return -1;
	}
	
	/* server address */ 
	serv_name.sin_family = AF_INET;
	inet_aton(host, &serv_name.sin_addr);
	serv_name.sin_port = htons(port);
	
	/* connect to the server */
	status = connect(sockd, (struct sockaddr*)&serv_name, sizeof(serv_name));
	close(sockd);
	
	if (status < 0) return -1;
	return 0;  
}

@interface HTTPSigTests : XCTestCase
@property HSURLRequestSigner* signer;
@end

@implementation HTTPSigTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
	
	NSString *keyID = @"129ea28979bbeb0ea7eb861e1c7a092fa1579dbe7e0f975f276bd2d09e73b685";
	NSString *secret = @"57d76b9b11287caa8291043e58186e7e6a2b0c53808a5fdb6f43843361cdec23";
	NSString *algorithm = HSAlgoHmacSha256;
	NSArray *headers = @[ @"(request-line)" ];//, @"date", @"x-nonce", @"accept" ];
	
	self.signer = [[HSURLRequestSigner alloc] initWithKeyID:keyID
													 secret:secret
												  algorithm:algorithm
												signHeaders:headers];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSigning
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://localhost/users/?baz=luhrman&foo=bar"]];
	[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[request setValue:@"en;q=1, fr;q=0.9, de;q=0.8, zh-Hans;q=0.7, zh-Hant;q=0.6, ja;q=0.5" forHTTPHeaderField:@"Accept-Language"];
	[request setValue:@"User-Agent" forHTTPHeaderField:@"HTTPSig/1.0 (iPhone Simulator; iOS 7.1; Scale/2.00)"];
	
	NSError *error = nil;
	NSURLRequest *signedRequest = [self.signer signRequest:request error:&error];
	XCTAssertNil(error, @"Error signing request: %@", error);
	
	NSString *expectation = @"signature=\"UmZTE0o26dXG7QKSwj+C2CTQMteXu5z3Xhbx+xHR7Qg=\"";
	NSString *signatureHeader = [signedRequest valueForHTTPHeaderField:@"Authorization"];
	XCTAssertNotNil(signatureHeader, @"Signature header not found in signed headers.");
	
	NSRange range = [signatureHeader rangeOfString:expectation];
	
	XCTAssertNotEqual(range.location, NSNotFound, @"Expected signature not found in response headers.");
}

- (void)testSessionWithLocalServer
{
	if (check_port("127.0.0.1", 8000) != 0) {
		NSLog(@"Skipping test: server not available.");
		return;
	}
	
	NSURL* baseURL = [NSURL URLWithString:@"http://127.0.0.1:8000/"];
		
	HSHTTPSessionManager* session = [[HSHTTPSessionManager alloc] initWithBaseURL:baseURL];
	session.signer = self.signer;
	
	AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer new];
	[requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	session.requestSerializer = requestSerializer;
	
	AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer new];
	responseSerializer.acceptableStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 1000)];
	session.responseSerializer = responseSerializer;
	
	[session GET:@"/users/"
	       parameters:@{ @"foo": @"bar", @"baz": @"luhrman" }
	          success: ^(NSURLSessionDataTask *task, id responseObject) {
				  if (responseObject && [responseObject isKindOfClass:[NSData class]]) {
					  NSLog(@"%@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
				  } else {
					  NSLog(@"%@", responseObject);
				  }
			  }
	 
	          failure: ^(NSURLSessionDataTask *task, NSError *error) {
				  NSLog(@"%@", error);
			  }];

}

@end
