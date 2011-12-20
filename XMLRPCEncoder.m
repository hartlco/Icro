#import "XMLRPCEncoder.h"
#import "NSStringAdditions.h"

@interface XMLRPCEncoder (XMLRPCEncoderPrivate)

- (void)valueTag: (NSString *)tag value: (NSString *)value;

#pragma mark -

- (NSString *)replaceTarget: (NSString *)target withValue: (NSString *)value inString: (NSString *)string;

#pragma mark -

- (void)encodeObject: (id)object;

#pragma mark -

- (void)encodeArray: (NSArray *)array;

- (void)encodeDictionary: (NSDictionary *)dictionary;

#pragma mark -

- (void)encodeBoolean: (CFBooleanRef)boolean;

- (void)encodeNumber: (NSNumber *)number;

- (void)encodeString: (NSString *)string omitTag: (BOOL)omitTag;

- (void)encodeDate: (NSDate *)date;

- (void)encodeData: (NSData *)data;

#pragma mark -

- (void)appendString:(NSString *)aString;

- (void)appendFormat:(NSString *)format, ...;

#pragma mark -

- (void)openStreamingCache;

@end

#pragma mark -

@implementation XMLRPCEncoder

- (id)init {
    self = [super init];
    if (self) {
        myMethod = [[NSString alloc] init];
        myParameters = [[NSArray alloc] init];
    }
    
    return self;
}

#pragma mark -

- (NSString *)encode {
    [self encodeForStreaming];

    NSInputStream *stream = [self encodedStream];
    NSMutableData *encodedData = [NSMutableData data];

    [stream open];

    while ([stream hasBytesAvailable]) {
        uint8_t buf[1024];
        unsigned int len = 0;

        len = [stream read:buf maxLength:1024];
        if (len) {
            [encodedData appendBytes:buf length:len];
        }
    }

    [stream close];

    return [[[NSString alloc] initWithData:encodedData encoding:NSUTF8StringEncoding] autorelease];
}

- (void)encodeForStreaming {
    [self appendString: @"<?xml version=\"1.0\"?><methodCall><methodName>"];

    [self encodeString: myMethod omitTag: YES];

    [self appendString: @"</methodName><params>"];
    
    if (myParameters) {
        NSEnumerator *enumerator = [myParameters objectEnumerator];
        id parameter = nil;
        
        while ((parameter = [enumerator nextObject])) {
            [self appendString: @"<param>"];
            [self encodeObject: parameter];
            [self appendString: @"</param>"];
        }
    }
    
    [self appendString: @"</params>"];
    
    [self appendString: @"</methodCall>"];
}

- (NSInputStream *)encodedStream {
    return [NSInputStream inputStreamWithFileAtPath:streamingCacheFilePath];
}

#pragma mark -

- (void)setMethod: (NSString *)method withParameters: (NSArray *)parameters {
    if (myMethod)    {
        [myMethod release];
    }
    
    if (!method) {
        myMethod = nil;
    } else {
        myMethod = [method retain];
    }
    
    if (myParameters) {
        [myParameters release];
    }
    
    if (!parameters) {
        myParameters = nil;
    } else {
        myParameters = [parameters retain];
    }
}

#pragma mark -

- (NSString *)method {
    return myMethod;
}

- (NSArray *)parameters {
    return myParameters;
}

#pragma mark -

- (void)dealloc {
    [myMethod release];
    [myParameters release];
    if (streamingCacheFile != nil) {
        [streamingCacheFile closeFile];
        [streamingCacheFile release];
        [[NSFileManager defaultManager] removeItemAtPath:streamingCacheFilePath error:nil];
    }
    [streamingCacheFilePath release];
    [super dealloc];
}

@end

#pragma mark -

@implementation XMLRPCEncoder (XMLRPCEncoderPrivate)

- (void)valueTag: (NSString *)tag value: (NSString *)value {
    [self appendFormat: @"<value><%@>%@</%@></value>", tag, value, tag];
}

#pragma mark -

- (NSString *)replaceTarget: (NSString *)target withValue: (NSString *)value inString: (NSString *)string {
    return [[string componentsSeparatedByString: target] componentsJoinedByString: value];    
}

#pragma mark -

- (void)encodeObject: (id)object {
    if (!object) {
        return;
    }
    
    if ([object isKindOfClass: [NSArray class]]) {
        [self encodeArray: object];
    } else if ([object isKindOfClass: [NSDictionary class]]) {
        [self encodeDictionary: object];
    } else if (((CFBooleanRef)object == kCFBooleanTrue) || ((CFBooleanRef)object == kCFBooleanFalse)) {
        [self encodeBoolean: (CFBooleanRef)object];
    } else if ([object isKindOfClass: [NSNumber class]]) {
        [self encodeNumber: object];
    } else if ([object isKindOfClass: [NSString class]]) {
        [self encodeString: object omitTag: NO];
    } else if ([object isKindOfClass: [NSDate class]]) {
        [self encodeDate: object];
    } else if ([object isKindOfClass: [NSData class]]) {
        [self encodeData: object];
    } else {
        [self encodeString: object omitTag: NO];
    }
}

#pragma mark -

- (void)encodeArray: (NSArray *)array {
    NSEnumerator *enumerator = [array objectEnumerator];
    
    [self appendString: @"<value><array><data>"];
    
    id object = nil;
    
    while (object = [enumerator nextObject]) {
        [self encodeObject: object];
    }
    
    [self appendString: @"</data></array></value>"];
}

- (void)encodeDictionary: (NSDictionary *)dictionary {
    NSEnumerator *enumerator = [dictionary keyEnumerator];
    
    [self appendString: @"<value><struct>"];
    
    NSString *key = nil;
    
    while (key = [enumerator nextObject]) {
        [self appendString: @"<member>"];
        [self appendString: @"<name>"];
        [self encodeString: key omitTag: YES];
        [self appendString: @"</name>"];
        [self encodeObject: [dictionary objectForKey: key]];
        [self appendString: @"</member>"];
    }
    
    [self appendString: @"</struct></value>"];
}

#pragma mark -

- (void)encodeBoolean: (CFBooleanRef)boolean {
    if (boolean == kCFBooleanTrue) {
        [self valueTag: @"boolean" value: @"1"];
    } else {
        [self valueTag: @"boolean" value: @"0"];
    }
}

- (void)encodeNumber: (NSNumber *)number {
    NSString *numberType = [NSString stringWithCString: [number objCType] encoding: NSUTF8StringEncoding];
    
    if ([numberType isEqualToString: @"d"]) {
        [self valueTag: @"double" value: [number stringValue]];
    } else {
        [self valueTag: @"i4" value: [number stringValue]];
    }
}

- (void)encodeString: (NSString *)string omitTag: (BOOL)omitTag {
    return omitTag ? [string escapedString] : [self valueTag: @"string" value: [string escapedString]];
}

- (void)encodeDate: (NSDate *)date {
    unsigned components = kCFCalendarUnitYear | kCFCalendarUnitMonth | kCFCalendarUnitDay | kCFCalendarUnitHour | kCFCalendarUnitMinute | kCFCalendarUnitSecond;
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components: components fromDate: date];
    NSString *buffer = [NSString stringWithFormat: @"%.4d%.2d%.2dT%.2d:%.2d:%.2d", [dateComponents year], [dateComponents month], [dateComponents day], [dateComponents hour], [dateComponents minute], [dateComponents second], nil];
    
    [self valueTag: @"dateTime.iso8601" value: buffer];
}

- (void)encodeData: (NSData *)data {
    NSString *buffer = [NSString base64StringFromData: data length: [data length]];

    [self valueTag: @"base64" value: buffer];
}

#pragma mark -

- (void)appendString:(NSString *)aString {
    [streamingCacheFile writeData:[aString dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)appendFormat:(NSString *)format, ... {
    va_list ap;
	va_start(ap, format);
	NSString *message = [[[NSString alloc] initWithFormat:format arguments:ap] autorelease];

    [self appendString:message];
}

#pragma mark -

- (void)openStreamingCache {
    if (streamingCacheFile != nil)
        return;

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString];
    streamingCacheFilePath = [[directory stringByAppendingPathComponent:guid] retain];

    [fileManager createFileAtPath:streamingCacheFilePath contents:nil attributes:nil];
    streamingCacheFile = [[NSFileHandle fileHandleForWritingAtPath:streamingCacheFilePath] retain];
}

@end
