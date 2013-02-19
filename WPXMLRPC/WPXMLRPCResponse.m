#import "WPXMLRPCResponse.h"
#import "WPXMLRPCEventBasedParser.h"
#import "WPXMLRPCDataCleaner.h"

@implementation WPXMLRPCResponse

- (id)initWithData:(NSData *)data {
    if (!data) {
        return nil;
    }

    self = [super init];
    if (self) {
        WPXMLRPCEventBasedParser *parser = [[WPXMLRPCEventBasedParser alloc] initWithData:data];
        
        if (!parser) {
            
            return nil;
        }

        myBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        myObject = [parser parse];
        if (myObject == nil) {
            WPXMLRPCDataCleaner *cleaner = [[WPXMLRPCDataCleaner alloc] initWithData:data];
            NSData *cleanData = [cleaner cleanData];
            parser = [[WPXMLRPCEventBasedParser alloc] initWithData:cleanData];
            myBody = [[NSString alloc] initWithData:cleanData encoding:NSUTF8StringEncoding];
            myObject = [parser parse];
        }
        
        isFault = [parser isFault];
        
    }
    
    return self;
}

#pragma mark -

- (BOOL)isFault {
    return isFault;
}

- (NSNumber *)faultCode {
    if (isFault) {
        return [myObject objectForKey:@"faultCode"];
    }
    
    return nil;
}

- (NSString *)faultString {
    if (isFault) {
        return [myObject objectForKey:@"faultString"];
    }
    
    return nil;
}

#pragma mark -

- (id)object {
    return myObject;
}

#pragma mark -

- (NSString *)body {
    return myBody;
}

#pragma mark -


@end
