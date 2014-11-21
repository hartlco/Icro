#import "WPXMLRPCDataCleanerTest.h"
#import "WPXMLRPCDataCleaner.h"

@interface WPXMLRPCDataCleaner (CleaningSteps)
- (NSString *)cleanClosingTagIfNeeded:(NSString *)str;
@end

@implementation WPXMLRPCDataCleanerTest

- (void)testClosingTagRepaired
{
    WPXMLRPCDataCleaner *cleaner = [[WPXMLRPCDataCleaner alloc] init];

    NSString *completeResponse = @"<methodResponse><params><param><value><string>Hello!</string></value></param></params></methodResponse>";
    NSString *truncatedResponse = [completeResponse substringWithRange:NSMakeRange(0, [completeResponse length] - 20)];
    NSString *cleanedString = [cleaner cleanClosingTagIfNeeded:truncatedResponse];
    STAssertEqualObjects(truncatedResponse, cleanedString, @"Should not try to fix a response that is too damaged.");

    completeResponse = @"<methodResponse><params><param><value><string>Hello!</string></value></param></params></methodResponse>";
    truncatedResponse = [completeResponse substringWithRange:NSMakeRange(0, [completeResponse length] - 10)];
    cleanedString = [cleaner cleanClosingTagIfNeeded:truncatedResponse];
    STAssertEqualObjects(completeResponse, cleanedString, @"The closing tag for the XML-RPC response was not repaired.");

    NSString *completeFault = @"<methodResponse><fault><value><struct><member><name>faultCode</name><value><int>403</int></value></member><member><name>faultString</name><value><string>Incorrect username or password.</string></value></member></struct></value></fault></methodResponse>";
    NSString *truncatedFault = [completeFault substringWithRange:NSMakeRange(0, [completeFault length] - 10)];
    cleanedString = [cleaner cleanClosingTagIfNeeded:truncatedFault];
    STAssertEqualObjects(completeFault, cleanedString, @"The closing tag for the XML-RPC fault was not repaired.");
}

@end

