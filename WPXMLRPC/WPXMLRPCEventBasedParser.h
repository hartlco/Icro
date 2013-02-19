#import <Foundation/Foundation.h>

@class WPXMLRPCEventBasedParserDelegate;

@interface WPXMLRPCEventBasedParser : NSObject

- (id)initWithData:(NSData *)data;

#pragma mark -

- (id)parse;

#pragma mark -

- (NSError *)parserError;

#pragma mark -

- (BOOL)isFault;

@end
