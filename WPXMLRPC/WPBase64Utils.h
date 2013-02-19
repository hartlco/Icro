//
//  WPBase64Utils.h
//  WPXMLRPCTest
//
//  Created by Jorge Bernal on 2/19/13.
//
//

@interface WPBase64Utils : NSObject
+ (NSString *)encodeData:(NSData *)data;
+ (void)encodeInputStream:(NSInputStream *)stream withChunkHandler:(void (^)(NSString *chunk))chunkHandler;
+ (void)encodeFileHandle:(NSFileHandle *)fileHandle withChunkHandler:(void (^)(NSString *chunk))chunkHandler;
+ (NSData *)decodeString:(NSString *)string;
@end
