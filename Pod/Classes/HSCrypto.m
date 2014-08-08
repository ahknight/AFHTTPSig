//
//  HSCrypto.m
//  Pods
//
//  Created by Adam Knight on 8/8/14.
//
//

#import "HSCrypto.h"

@implementation HSCrypto

+(NSData*)HMACData:(NSData*)data key:(NSData*)key algorithm:(int)algorithm
{
	unsigned digestLength = 0;
	switch (algorithm) {
		case kCCHmacAlgMD5:
			digestLength = CC_MD5_DIGEST_LENGTH;
			break;
			
		case kCCHmacAlgSHA1:
			digestLength = CC_SHA1_DIGEST_LENGTH;
			break;
			
		case kCCHmacAlgSHA224:
			digestLength = CC_SHA224_DIGEST_LENGTH;
			break;
			
		case kCCHmacAlgSHA256:
			digestLength = CC_SHA256_DIGEST_LENGTH;
			break;
			
		case kCCHmacAlgSHA384:
			digestLength = CC_SHA384_DIGEST_LENGTH;
			break;
			
		case kCCHmacAlgSHA512:
			digestLength = CC_SHA512_DIGEST_LENGTH;
			break;
			
		default:
			[[NSException exceptionWithName:@"HSCrypto" reason:@"Unknown algorithm." userInfo:nil] raise];
			return nil;
	}
	
	uint8_t *digest = calloc(digestLength, 1);
    CCHmac(algorithm, [key bytes], [key length], [data bytes], [data length], digest);
	return [NSData dataWithBytesNoCopy:digest length:digestLength freeWhenDone:YES];
}

+(NSData*)HMACString:(NSString*)string key:(NSData*)key algorithm:(int)algorithm
{
	NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
	return [self HMACData:data key:key algorithm:algorithm];
}

+(NSData*)SHA256Data:(NSData*)data
{
	unsigned digestLength = CC_SHA256_DIGEST_LENGTH;
	uint8_t *digest = calloc(digestLength, 1);
	digest = CC_SHA256([data bytes], [data length], digest);
	return [NSData dataWithBytesNoCopy:digest length:digestLength freeWhenDone:YES];
}

@end
