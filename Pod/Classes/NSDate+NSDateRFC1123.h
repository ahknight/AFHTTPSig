//
//  NSDate+NSDateRFC1123.h
//  HTTPSig
//
//  Created by Adam Knight on 6/25/14.
//  Copyright (c) 2014 Adam Knight. All rights reserved.
//  Original (2014-Jun-25): http://blog.mro.name/2009/08/nsdateformatter-http-header/
//

#import <Foundation/Foundation.h>

/** Category on NSDate to support rfc1123 formatted date strings.
 http://blog.mro.name/2009/08/nsdateformatter-http-header/ and
 http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.3.1
 */
@interface NSDate (NSDateRFC1123)

/**
 Convert a RFC1123 'Full-Date' string
 (http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.3.1)
 into NSDate.
 */
+(NSDate*)dateFromRFC1123:(NSString*)value_;

/**
 Convert NSDate into a RFC1123 'Full-Date' string
 (http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.3.1).
 */
-(NSString*)rfc1123String;

@end
