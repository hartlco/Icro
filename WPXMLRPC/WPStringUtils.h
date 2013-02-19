//
//  WPStringUtils.h
//  WPXMLRPCTest
//
//  Created by Jorge Bernal on 2/19/13.
//
//

#import <Foundation/Foundation.h>

@interface WPStringUtils : NSObject
+ (NSString *)unescapedStringWithString:(NSString *)string;
+ (NSString *)escapedStringWithString:(NSString *)string;
@end
