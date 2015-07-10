#import "WPBase64Utils.h"

#import <XCTest/XCTest.h>

@interface WPBase64UtilsTest : XCTestCase

@end

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
    XCTAssertEqualObjects(expectedEncoded, parsedEncoded);
}

- (void)testDecodeWithData {
    NSData *parsedDecoded = [WPBase64Utils decodeString:expectedEncoded];
    XCTAssertEqualObjects(expectedDecoded, parsedDecoded);
}

- (void)testDecodeControlCharactersString {
    NSData *parsedDecoded = [WPBase64Utils decodeString:encodedControlCharacters];
    XCTAssertEqualObjects(expectedDecodedControlCharacters, parsedDecoded);
}

- (void)testEncodeWithInputStream {
    NSMutableString *parsedEncoded = [NSMutableString string];
    [WPBase64Utils encodeInputStream:[NSInputStream inputStreamWithFileAtPath:encodedFilePath] withChunkHandler:^(NSString *chunk) {
        [parsedEncoded appendString:chunk];
    }];
    XCTAssertEqualObjects(expectedEncoded, parsedEncoded);
}

- (void)testEncodeWithFileHandle {
    NSMutableString *parsedEncoded = [NSMutableString string];
    [WPBase64Utils encodeFileHandle:[NSFileHandle fileHandleForReadingAtPath:encodedFilePath] withChunkHandler:^(NSString *chunk) {
        [parsedEncoded appendString:chunk];
    }];
    XCTAssertEqualObjects(expectedEncoded, parsedEncoded);
}

@end
