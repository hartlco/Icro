#import <Foundation/Foundation.h>

@interface WPXMLRPCEncoder : NSObject

- (NSString *)encode;

- (void)encodeForStreaming;

- (NSInputStream *)encodedStream;

- (NSNumber *)encodedLength;

#pragma mark -

- (void)setMethod:(NSString *)method withParameters:(NSArray *)parameters;

#pragma mark -

- (NSString *)method;

- (NSArray *)parameters;

@end
