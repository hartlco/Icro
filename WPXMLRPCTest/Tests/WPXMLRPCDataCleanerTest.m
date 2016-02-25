#import <XCTest/XCTest.h>
#import "WPXMLRPCDataCleaner.h"

static NSString * const CompleteResponse = @"<methodResponse><params><param><value><string>Hello!</string></value></param></params></methodResponse>";
static NSString * const CompleteFault = @"<methodResponse><fault><value><struct><member><name>faultCode</name><value><int>403</int></value></member><member><name>faultString</name><value><string>Incorrect username or password.</string></value></member></struct></value></fault></methodResponse>";

@interface WPXMLRPCDataCleaner (CleaningSteps)
- (NSString *)cleanClosingTagIfNeeded:(NSString *)str lengthOfCharactersPrecedingPreamble:(NSInteger)length;
@end

@interface WPXMLRPCDataCleanerTest : XCTestCase
@end

@implementation WPXMLRPCDataCleanerTest



- (void)testClosingTagRepaired
{
    WPXMLRPCDataCleaner *cleaner = [[WPXMLRPCDataCleaner alloc] init];

    // Test a whole response
    NSString *cleanedString = [cleaner cleanClosingTagIfNeeded:CompleteResponse lengthOfCharactersPrecedingPreamble:0];
    XCTAssertEqualObjects(CompleteResponse, cleanedString, @"A good reponse should just be returned intact.");
}

- (void)testReturnsGoodStringWhenPreambleWasCleanedOfJunk
{
    WPXMLRPCDataCleaner *cleaner = [[WPXMLRPCDataCleaner alloc] init];
    // Test a whole response but some info was cleaned from before the preamble
    NSString *cleanedString = [cleaner cleanClosingTagIfNeeded:CompleteResponse lengthOfCharactersPrecedingPreamble:35];
    XCTAssertEqualObjects(CompleteResponse, cleanedString, @"Info cleaned from the preamble should not affect a good response.");
}

- (void)testReturnsOriginalStringWhenPreambleHadTooMuchJunk
{
    WPXMLRPCDataCleaner *cleaner = [[WPXMLRPCDataCleaner alloc] init];
    // Test a truncated response where too much info was cleaned from before the preamble.
    NSString *truncatedResponse = [CompleteResponse substringWithRange:NSMakeRange(0, [CompleteResponse length] - 35)];
    NSString *cleanedString = [cleaner cleanClosingTagIfNeeded:truncatedResponse lengthOfCharactersPrecedingPreamble:35];
    XCTAssertEqualObjects(truncatedResponse, cleanedString, @"Should not try to fix a response where too much junk was removed from the preamble.");
}

- (void)testCleansResponseTurncatedBeforeParam
{
    WPXMLRPCDataCleaner *cleaner = [[WPXMLRPCDataCleaner alloc] init];
    // Test a response truncated just before the param tag
    NSString *truncatedResponse = [CompleteResponse substringWithRange:NSMakeRange(0, [CompleteResponse length] - 34)];
    NSString *cleanedString = [cleaner cleanClosingTagIfNeeded:truncatedResponse lengthOfCharactersPrecedingPreamble:0];
    XCTAssertEqualObjects(CompleteResponse, cleanedString, @"Failed to repair a damanged closing param tag.");
}

- (void)testCleansResponseTurncatedInParam
{
    WPXMLRPCDataCleaner *cleaner = [[WPXMLRPCDataCleaner alloc] init];
    // Test a response truncated in the param tag
    NSString *truncatedResponse = [CompleteResponse substringWithRange:NSMakeRange(0, [CompleteResponse length] - 33)];
    NSString *cleanedString = [cleaner cleanClosingTagIfNeeded:truncatedResponse lengthOfCharactersPrecedingPreamble:0];
    XCTAssertEqualObjects(CompleteResponse, cleanedString, @"Failed to repair a damanged closing param tag.");
}

- (void)testCleansResponseTurncatedInParams
{
    WPXMLRPCDataCleaner *cleaner = [[WPXMLRPCDataCleaner alloc] init];
    // test a response truncated in the params tag
    NSString *truncatedResponse = [CompleteResponse substringWithRange:NSMakeRange(0, [CompleteResponse length] - 20)];
    NSString *cleanedString = [cleaner cleanClosingTagIfNeeded:truncatedResponse lengthOfCharactersPrecedingPreamble:0];
    XCTAssertEqualObjects(CompleteResponse, cleanedString, @"Failed to repair a damanged closing params tag.");
}

- (void)testCleansResponseTurncatedInMethodResponse
{
    WPXMLRPCDataCleaner *cleaner = [[WPXMLRPCDataCleaner alloc] init];
    // test a response truncated in the methodResponse tag
    NSString *truncatedResponse = [CompleteResponse substringWithRange:NSMakeRange(0, [CompleteResponse length] - 10)];
    NSString *cleanedString = [cleaner cleanClosingTagIfNeeded:truncatedResponse lengthOfCharactersPrecedingPreamble:0];
    XCTAssertEqualObjects(CompleteResponse, cleanedString, @"Failed to repair a damanged closing methodResponse tag.");
}

- (void)testCleansFaultTurncateBeforeValue
{
    WPXMLRPCDataCleaner *cleaner = [[WPXMLRPCDataCleaner alloc] init];
    // Test a fault truncated at the value tag
    NSString *truncatedFault = [CompleteFault substringWithRange:NSMakeRange(0, [CompleteFault length] - 33)];
    NSString *cleanedString = [cleaner cleanClosingTagIfNeeded:truncatedFault lengthOfCharactersPrecedingPreamble:0];
    XCTAssertEqualObjects(CompleteFault, cleanedString, @"Failed to repair a damanged closing value tag.");
}

- (void)testCleansFaultTurncatedIValue
{
    WPXMLRPCDataCleaner *cleaner = [[WPXMLRPCDataCleaner alloc] init];
    // Test a fault truncated in the value tag
    NSString *truncatedFault = [CompleteFault substringWithRange:NSMakeRange(0, [CompleteFault length] - 30)];
    NSString *cleanedString = [cleaner cleanClosingTagIfNeeded:truncatedFault lengthOfCharactersPrecedingPreamble:0];
    XCTAssertEqualObjects(CompleteFault, cleanedString, @"Failed to repair a damanged closing value tag.");
}

- (void)testCleansFaultTurncatedInFault
{
    WPXMLRPCDataCleaner *cleaner = [[WPXMLRPCDataCleaner alloc] init];
    // Test a fault truncated in the fault tag
    NSString *truncatedFault = [CompleteFault substringWithRange:NSMakeRange(0, [CompleteFault length] - 20)];
    NSString *cleanedString = [cleaner cleanClosingTagIfNeeded:truncatedFault lengthOfCharactersPrecedingPreamble:0];
    XCTAssertEqualObjects(CompleteFault, cleanedString, @"Failed to repair a damanged closing fault tag.");
}

- (void)testCleansFaultTurncatedInMethodResponse
{
    WPXMLRPCDataCleaner *cleaner = [[WPXMLRPCDataCleaner alloc] init];
    // Test a fault truncated in the method response tag
    NSString *truncatedFault = [CompleteFault substringWithRange:NSMakeRange(0, [CompleteFault length] - 10)];
    NSString *cleanedString = [cleaner cleanClosingTagIfNeeded:truncatedFault lengthOfCharactersPrecedingPreamble:0];
    XCTAssertEqualObjects(CompleteFault, cleanedString, @"Failed to repair a damanged closing methodResponse tag.");
}

@end

