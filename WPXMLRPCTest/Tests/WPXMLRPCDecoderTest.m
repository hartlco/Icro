#import "WPXMLRPCDecoderTest.h"
#import "WPXMLRPCDecoder.h"
#import "WPStringUtils.h"

@implementation WPXMLRPCDecoderTest {
    NSDictionary *myTestCases;
}

- (void)setUp {
    myTestCases = [self testCases];
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
}

- (void)testEventBasedParser {
    NSEnumerator *testCaseEnumerator = [myTestCases keyEnumerator];
    id testCaseName;
    
    while (testCaseName = [testCaseEnumerator nextObject]) {
        NSString *testCase = [[self unitTestBundle] pathForResource:testCaseName ofType:@"xml"];
        NSData *testCaseData =[[NSData alloc] initWithContentsOfFile:testCase];
        WPXMLRPCDecoder *decoder = [[WPXMLRPCDecoder alloc] initWithData:testCaseData];
        id testCaseResult = [myTestCases objectForKey:testCaseName];
        id parsedResult = [decoder object];

        XCTAssertEqualObjects(parsedResult, testCaseResult);
    }
}

- (void)testNoXmlThrowsError {
    NSString *testCase = [[self unitTestBundle] pathForResource:@"NoXmlResponseTestCase" ofType:@"xml"];
    NSData *testCaseData =[[NSData alloc] initWithContentsOfFile:testCase];
    WPXMLRPCDecoder *decoder = [[WPXMLRPCDecoder alloc] initWithData:testCaseData];
    XCTAssertNil([decoder object]);
    XCTAssertNotNil([decoder error]);
    NSError *error = [decoder error];
    XCTAssertEqualObjects([error domain], WPXMLRPCErrorDomain);
    XCTAssertEqual([error code], WPXMLRPCInvalidInputError);
}

#pragma mark -

- (NSBundle *)unitTestBundle {
    return [NSBundle bundleForClass:[WPXMLRPCDecoderTest class]];
}

- (NSDictionary *)testCases {
    NSString *file = [[self unitTestBundle] pathForResource:@"TestCases" ofType:@"plist"];
    NSDictionary *testCases = [[NSDictionary alloc] initWithContentsOfFile:file];
    
    return testCases;
}

@end
