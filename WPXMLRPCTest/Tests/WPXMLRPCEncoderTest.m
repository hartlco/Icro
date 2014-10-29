//
//  WPXMLRPCEncoderTest.m
//  WPXMLRPCTest
//
//  Created by Jorge Bernal on 2/25/13.
//
//

#import "WPXMLRPCEncoder.h"
#import "WPXMLRPCEncoderTest.h"

@implementation WPXMLRPCEncoderTest

- (void)testRequestEncoder {
    WPXMLRPCEncoder *encoder = [[WPXMLRPCEncoder alloc] initWithMethod:@"wp.getUsersBlogs" andParameters:@[@"username", @"password"]];
    NSString *testCase = [[self unitTestBundle] pathForResource:@"RequestTestCase" ofType:@"xml"];
    NSString *testCaseData = [[NSString alloc] initWithContentsOfFile:testCase encoding:NSUTF8StringEncoding error:nil];
    NSString *parsedResult = [[NSString alloc] initWithData:[encoder body] encoding:NSUTF8StringEncoding];
    STAssertEqualObjects(parsedResult, testCaseData, nil);
}

/*
 This is meant to test https://github.com/wordpress-mobile/wpxmlrpc/issues/15
 
 I haven't found a way to change the locale for testing, so I had to switch the calendar manually on the simulator settings
 */
- (void)testDateEncoder {
    WPXMLRPCEncoder *encoder = [[WPXMLRPCEncoder alloc] initWithMethod:@"wp.getUsersBlogs" andParameters:@[[NSDate dateWithTimeIntervalSince1970:0]]];
    NSString *result = [[NSString alloc] initWithData:[encoder body] encoding:NSUTF8StringEncoding];
    NSString *expected = @"<?xml version=\"1.0\"?><methodCall><methodName>wp.getUsersBlogs</methodName><params><param><value><dateTime.iso8601>19700101T00:00:00Z</dateTime.iso8601></value></param></params></methodCall>";
    STAssertEqualObjects(expected, result, nil);
}

- (void)testStreamingEncoder {
    NSString * filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"TestImage" ofType:@"png"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *cacheFilePath = [directory stringByAppendingPathComponent:guid];
    
    WPXMLRPCEncoder *encoder = [[WPXMLRPCEncoder alloc] initWithMethod:@"wp.getUsersBlogs" andParameters:@[@"username", @"password", @{@"bits": [NSInputStream inputStreamWithFileAtPath:filePath]}] cacheFilePath:cacheFilePath];
    
    NSInputStream * inputStream = [encoder bodyStream];
    
    encoder = nil;
    
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath isDirectory:nil],@"Cache File must be present");
    
    STAssertTrue([[NSFileManager defaultManager] removeItemAtPath:cacheFilePath error:nil], @"It must be possible to remove the file");

}

#pragma mark - 

- (NSBundle *)unitTestBundle {
    return [NSBundle bundleForClass:[WPXMLRPCEncoderTest class]];
}

@end
