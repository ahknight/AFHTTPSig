//
//  HSCrypto.h
//  Pods
//
//  Created by Adam Knight on 8/8/14.
//
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>

/// Simple Obj-C interface to CommonCrypto.
@interface HSCrypto : NSObject

/** Returns the HMAC digest using the given data and key.
 
 This is a thin wrapper around `CCHmac` so look at that for more details.
 
 @param data The data to sign.
 @param key The key to sign with.
 @param algorithm The algorithm to use (use CC constants such as kCCHmacAlgSHA256).
 @seealso CCHmac
 */
+(NSData*)HMACData:(NSData*)data key:(NSData*)key algorithm:(int)algorithm;


/** Returns the HMAC digest using the given UTF-8 string and key.
 
 This is a thin wrapper around `CCHmac` so look at that for more details.
 
 @param string An NSString object that will cleanly decode to bytes using the UTF8 encoding.
 @param key The key to sign with.
 @param algorithm The algorithm to use (use CC constants such as kCCHmacAlgSHA256).
 @seealso [HSCrypto HMACData:key:algorithm:]
 */
+(NSData*)HMACString:(NSString*)string key:(NSData*)key algorithm:(int)algorithm;


/** Returns the SHA256 digest for the given data.
 
 This is a thin wrapper around `CC_SHA256` so look at that for more details.
 
 @param data The data to hash.
 @seealso CC_SHA256
*/
 +(NSData*)SHA256Data:(NSData*)data;

@end
