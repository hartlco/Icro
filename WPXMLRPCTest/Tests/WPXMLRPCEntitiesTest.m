#import "WPXMLRPCDecoder.h"
#import "WPXMLRPCEncoder.h"
#import "WPStringUtils.h"

#import <XCTest/XCTest.h>

@interface WPXMLRPCEntitiesTest : XCTestCase

@end

@implementation WPXMLRPCEntitiesTest

- (void)testXMLEntitiesDecoding {
    NSString *testCase = [[NSBundle bundleForClass:[self class]] pathForResource:@"entities" ofType:@"xml"];
    NSData *testCaseData =[[NSData alloc] initWithContentsOfFile:testCase];
    WPXMLRPCDecoder *decoder = [[WPXMLRPCDecoder alloc] initWithData:testCaseData];
    NSString *decoded = [[decoder object] objectForKey:@"description"];

    NSString *expectedPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"entitiesDecoded" ofType:@"xml"];
    NSData *expectedData =[[NSData alloc] initWithContentsOfFile:expectedPath];
    NSString *expected = [[NSString alloc] initWithData:expectedData encoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(decoded, expected);

    decoded = [WPStringUtils unescapedStringWithString:@"&lt;td&gt;&amp;gt;&lt;/td&gt;&lt;td&gt;&amp;amp;#62;&lt;/td&gt;&lt;td&gt;&amp;amp;gt;&lt;/td&gt;"];
    expected = @"<td>&gt;</td><td>&amp;#62;</td><td>&amp;gt;</td>";
    XCTAssertEqualObjects(decoded, expected);
}

- (void)testXmlEntitiesEncoding {
    WPXMLRPCEncoder *encoder = [[WPXMLRPCEncoder alloc] initWithMethod:@"fake.test" andParameters:@[@"<b>&lt;b&gt;</b> tag &amp; &quot;other&quot; \"tags\""]];
    NSString *encoded = [[NSString alloc] initWithData:[encoder dataEncodedWithError:nil] encoding:NSUTF8StringEncoding];
    NSString *expected = @"<?xml version=\"1.0\"?><methodCall><methodName>fake.test</methodName><params><param><value><string>&#60;b&#62;&#38;lt;b&#38;gt;&#60;/b&#62; tag &#38;amp; &#38;quot;other&#38;quot; \"tags\"</string></value></param></params></methodCall>";
    XCTAssertEqualObjects(encoded, expected);
}


@end
