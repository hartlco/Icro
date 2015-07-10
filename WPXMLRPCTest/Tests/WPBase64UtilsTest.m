//
//  WPBase64UtilsTest.m
//  WPXMLRPCTest
//
//  Created by Jorge Bernal on 2/19/13.
//
//

#import "WPBase64UtilsTest.h"
#import "WPBase64Utils.h"

@implementation WPBase64UtilsTest {
    NSString *expectedEncoded;
    NSData *expectedDecoded;
    NSData *expectedDecodedControlCharacters;
    NSString *encodedFilePath;
    NSString *encodedControlCharacters;
}

- (void)setUp {
    expectedEncoded = [NSString stringWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"TestImage" ofType:@"base64"] encoding:NSASCIIStringEncoding error:nil];
    encodedFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"TestImage" ofType:@"png"];
    expectedDecoded = [NSData dataWithContentsOfFile:encodedFilePath];
    encodedControlCharacters = @"\r\n";
    expectedDecodedControlCharacters = [@"" dataUsingEncoding:NSASCIIStringEncoding];
}

- (void)testEncodeWithData {
    NSString *parsedEncoded = [WPBase64Utils encodeData:expectedDecoded];
    STAssertEqualObjects(expectedEncoded, parsedEncoded, nil);
}

- (void)testDecodeWithData {
    NSData *parsedDecoded = [WPBase64Utils decodeString:expectedEncoded];
    STAssertEqualObjects(expectedDecoded, parsedDecoded, nil);
}

- (void)testDecodeControlCharactersString {
    NSData *parsedDecoded = [WPBase64Utils decodeString:encodedControlCharacters];
    STAssertEqualObjects(expectedDecodedControlCharacters, parsedDecoded, nil);
}

- (void)testEncodeWithInputStream {
    NSMutableString *parsedEncoded = [NSMutableString string];
    [WPBase64Utils encodeInputStream:[NSInputStream inputStreamWithFileAtPath:encodedFilePath] withChunkHandler:^(NSString *chunk) {
        [parsedEncoded appendString:chunk];
    }];
    STAssertEqualObjects(expectedEncoded, parsedEncoded, nil);
}

- (void)testEncodeWithFileHandle {
    NSMutableString *parsedEncoded = [NSMutableString string];
    [WPBase64Utils encodeFileHandle:[NSFileHandle fileHandleForReadingAtPath:encodedFilePath] withChunkHandler:^(NSString *chunk) {
        [parsedEncoded appendString:chunk];
    }];
    STAssertEqualObjects(expectedEncoded, parsedEncoded, nil);
}

@end
