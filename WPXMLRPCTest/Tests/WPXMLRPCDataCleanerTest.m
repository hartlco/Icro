#import "WPXMLRPCDataCleanerTest.h"
#import "WPXMLRPCDataCleaner.h"

@interface WPXMLRPCDataCleaner (CleaningSteps)
- (NSString *)cleanClosingTagIfNeeded:(NSString *)str lengthOfCharactersPrecedingPreamble:(NSInteger)length;
@end

@implementation WPXMLRPCDataCleanerTest

- (void)testClosingTagRepaired
{
    WPXMLRPCDataCleaner *cleaner = [[WPXMLRPCDataCleaner alloc] init];

    // Test a whole response
    NSString *completeResponse = @"<methodResponse><params><param><value><string>Hello!</string></value></param></params></methodResponse>";
    NSString *cleanedString = [cleaner cleanClosingTagIfNeeded:completeResponse lengthOfCharactersPrecedingPreamble:0];
    STAssertEqualObjects(completeResponse, cleanedString, @"A good reponse should just be returned intact.");

    // Test a whole response but some info was cleaned from before the preamble
    cleanedString = [cleaner cleanClosingTagIfNeeded:completeResponse lengthOfCharactersPrecedingPreamble:35];
    STAssertEqualObjects(completeResponse, cleanedString, @"Info cleaned from the preamble should not affect a good response.");

    // Test a truncated response where too much info was cleaned from before the preamble.
    NSString *truncatedResponse = [completeResponse substringWithRange:NSMakeRange(0, [completeResponse length] - 35)];
    cleanedString = [cleaner cleanClosingTagIfNeeded:truncatedResponse lengthOfCharactersPrecedingPreamble:35];
    STAssertEqualObjects(truncatedResponse, cleanedString, @"Should not try to fix a response where too much junk was removed from the preamble.");

    // Test a response truncated just before the param tag
    truncatedResponse = [completeResponse substringWithRange:NSMakeRange(0, [completeResponse length] - 34)];
    cleanedString = [cleaner cleanClosingTagIfNeeded:truncatedResponse lengthOfCharactersPrecedingPreamble:0];
    STAssertEqualObjects(completeResponse, cleanedString, @"Failed to repair a damanged closing param tag.");

    // Test a response truncated in the param tag
    truncatedResponse = [completeResponse substringWithRange:NSMakeRange(0, [completeResponse length] - 33)];
    cleanedString = [cleaner cleanClosingTagIfNeeded:truncatedResponse lengthOfCharactersPrecedingPreamble:0];
    STAssertEqualObjects(completeResponse, cleanedString, @"Failed to repair a damanged closing param tag.");

    // test a response truncated in the params tag
    truncatedResponse = [completeResponse substringWithRange:NSMakeRange(0, [completeResponse length] - 20)];
    cleanedString = [cleaner cleanClosingTagIfNeeded:truncatedResponse lengthOfCharactersPrecedingPreamble:0];
    STAssertEqualObjects(completeResponse, cleanedString, @"Failed to repair a damanged closing params tag.");

    // test a response truncated in the methodResponse tag
    truncatedResponse = [completeResponse substringWithRange:NSMakeRange(0, [completeResponse length] - 10)];
    cleanedString = [cleaner cleanClosingTagIfNeeded:truncatedResponse lengthOfCharactersPrecedingPreamble:0];
    STAssertEqualObjects(completeResponse, cleanedString, @"Failed to repair a damanged closing methodResponse tag.");


    // Test a fault truncated at the value tag
    NSString *completeFault = @"<methodResponse><fault><value><struct><member><name>faultCode</name><value><int>403</int></value></member><member><name>faultString</name><value><string>Incorrect username or password.</string></value></member></struct></value></fault></methodResponse>";
    NSString *truncatedFault = [completeFault substringWithRange:NSMakeRange(0, [completeFault length] - 33)];
    cleanedString = [cleaner cleanClosingTagIfNeeded:truncatedFault lengthOfCharactersPrecedingPreamble:0];
    STAssertEqualObjects(completeFault, cleanedString, @"Failed to repair a damanged closing value tag.");

    // Test a fault truncated in the value tag
    truncatedFault = [completeFault substringWithRange:NSMakeRange(0, [completeFault length] - 30)];
    cleanedString = [cleaner cleanClosingTagIfNeeded:truncatedFault lengthOfCharactersPrecedingPreamble:0];
    STAssertEqualObjects(completeFault, cleanedString, @"Failed to repair a damanged closing value tag.");

    // Test a fault truncated in the fault tag
    truncatedFault = [completeFault substringWithRange:NSMakeRange(0, [completeFault length] - 20)];
    cleanedString = [cleaner cleanClosingTagIfNeeded:truncatedFault lengthOfCharactersPrecedingPreamble:0];
    STAssertEqualObjects(completeFault, cleanedString, @"Failed to repair a damanged closing fault tag.");

    // Test a fault truncated in the method response tag
    truncatedFault = [completeFault substringWithRange:NSMakeRange(0, [completeFault length] - 10)];
    cleanedString = [cleaner cleanClosingTagIfNeeded:truncatedFault lengthOfCharactersPrecedingPreamble:0];
    STAssertEqualObjects(completeFault, cleanedString, @"Failed to repair a damanged closing methodResponse tag.");
}

@end

