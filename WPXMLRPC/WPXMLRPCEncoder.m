#import "WPXMLRPCEncoder.h"
#import "WPBase64Utils.h"
#import "WPStringUtils.h"

@interface WPXMLRPCEncoder (WPXMLRPCEncoderPrivate)

- (void)valueTag:(NSString *)tag value:(NSString *)value;

#pragma mark -

- (NSString *)replaceTarget:(NSString *)target withValue:(NSString *)value inString:(NSString *)string;

#pragma mark -

- (void)encodeObject:(id)object;

#pragma mark -

- (void)encodeArray:(NSArray *)array;

- (void)encodeDictionary:(NSDictionary *)dictionary;

#pragma mark -

- (void)encodeBoolean:(CFBooleanRef)boolean;

- (void)encodeNumber:(NSNumber *)number;

- (void)encodeString:(NSString *)string omitTag:(BOOL)omitTag;

- (void)encodeDate:(NSDate *)date;

- (void)encodeData:(NSData *)data;

- (void)encodeInputStream:(NSInputStream *)stream;

- (void)encodeFileHandle:(NSFileHandle *)handle;

#pragma mark -

- (void)appendString:(NSString *)aString;

- (void)appendFormat:(NSString *)format, ...;

#pragma mark -

- (void)openStreamingCache;

@end

#pragma mark -

@implementation WPXMLRPCEncoder {
    NSString *myMethod;
    NSArray *myParameters;
    NSFileHandle *streamingCacheFile;
    NSString *streamingCacheFilePath;
}

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
    if (streamingCacheFilePath == nil) {
        [self encodeForStreaming];
    }

    NSInputStream *stream = [self encodedStream];
    NSMutableData *encodedData = [NSMutableData data];

    [stream open];

    while ([stream hasBytesAvailable]) {
        uint8_t buf[1024];
        NSInteger len = 0;

        len = [stream read:buf maxLength:1024];
        if (len) {
            [encodedData appendBytes:buf length:len];
        }
    }

    [stream close];

    return [[NSString alloc] initWithData:encodedData encoding:NSUTF8StringEncoding];
}

- (void)encodeForStreaming {
    [self openStreamingCache];

    [self appendString:@"<?xml version=\"1.0\"?><methodCall><methodName>"];

    [self encodeString:myMethod omitTag:YES];

    [self appendString:@"</methodName><params>"];
    
    if (myParameters) {
        NSEnumerator *enumerator = [myParameters objectEnumerator];
        id parameter = nil;
        
        while ((parameter = [enumerator nextObject])) {
            [self appendString:@"<param>"];
            [self encodeObject:parameter];
            [self appendString:@"</param>"];
        }
    }
    
    [self appendString:@"</params>"];
    
    [self appendString:@"</methodCall>"];

    [streamingCacheFile synchronizeFile];
}

- (NSInputStream *)encodedStream {
    if (streamingCacheFilePath == nil) {
        [self encodeForStreaming];
    }
    return [NSInputStream inputStreamWithFileAtPath:streamingCacheFilePath];
}

- (NSNumber *)encodedLength {
    if (streamingCacheFilePath == nil) {
        [self encodeForStreaming];
    }

    NSError *error = nil;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:streamingCacheFilePath error:&error];
    if (error) {
        return nil;
    }

    return [attributes objectForKey:NSFileSize];
}

#pragma mark -

- (void)setMethod:(NSString *)method withParameters:(NSArray *)parameters {
    
    if (!method) {
        myMethod = nil;
    } else {
        myMethod = method;
    }
    
    
    if (!parameters) {
        myParameters = nil;
    } else {
        myParameters = parameters;
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
    if (streamingCacheFile != nil) {
        [streamingCacheFile closeFile];
        [[NSFileManager defaultManager] removeItemAtPath:streamingCacheFilePath error:nil];
    }
}

@end

#pragma mark -

@implementation WPXMLRPCEncoder (WPXMLRPCEncoderPrivate)

- (void)valueTag:(NSString *)tag value:(NSString *)value {
    [self appendFormat:@"<value><%@>%@</%@></value>", tag, value, tag];
}

#pragma mark -

- (NSString *)replaceTarget:(NSString *)target withValue:(NSString *)value inString:(NSString *)string {
    return [[string componentsSeparatedByString:target] componentsJoinedByString:value];    
}

#pragma mark -

- (void)encodeObject:(id)object {
    if (!object) {
        return;
    }
    
    if ([object isKindOfClass:[NSArray class]]) {
        [self encodeArray:object];
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        [self encodeDictionary:object];
    } else if (((__bridge CFBooleanRef)object == kCFBooleanTrue) || ((__bridge CFBooleanRef)object == kCFBooleanFalse)) {
        [self encodeBoolean:(CFBooleanRef)object];
    } else if ([object isKindOfClass:[NSNumber class]]) {
        [self encodeNumber:object];
    } else if ([object isKindOfClass:[NSString class]]) {
        [self encodeString:object omitTag:NO];
    } else if ([object isKindOfClass:[NSDate class]]) {
        [self encodeDate:object];
    } else if ([object isKindOfClass:[NSData class]]) {
        [self encodeData:object];
    } else if ([object isKindOfClass:[NSInputStream class]]) {
        [self encodeInputStream:object];
    } else if ([object isKindOfClass:[NSFileHandle class]]) {
        [self encodeFileHandle:object];
    } else {
        [self encodeString:object omitTag:NO];
    }
}

#pragma mark -

- (void)encodeArray:(NSArray *)array {
    NSEnumerator *enumerator = [array objectEnumerator];
    
    [self appendString:@"<value><array><data>"];
    
    id object = nil;
    
    while (object = [enumerator nextObject]) {
        [self encodeObject:object];
    }
    
    [self appendString:@"</data></array></value>"];
}

- (void)encodeDictionary:(NSDictionary *)dictionary {
    NSEnumerator *enumerator = [dictionary keyEnumerator];
    
    [self appendString:@"<value><struct>"];
    
    NSString *key = nil;
    
    while (key = [enumerator nextObject]) {
        [self appendString:@"<member>"];
        [self appendString:@"<name>"];
        [self encodeString:key omitTag:YES];
        [self appendString:@"</name>"];
        [self encodeObject:[dictionary objectForKey:key]];
        [self appendString:@"</member>"];
    }
    
    [self appendString:@"</struct></value>"];
}

#pragma mark -

- (void)encodeBoolean:(CFBooleanRef)boolean {
    if (boolean == kCFBooleanTrue) {
        [self valueTag:@"boolean" value:@"1"];
    } else {
        [self valueTag:@"boolean" value:@"0"];
    }
}

- (void)encodeNumber:(NSNumber *)number {
    NSString *numberType = [NSString stringWithCString:[number objCType] encoding:NSUTF8StringEncoding];
    
    if ([numberType isEqualToString:@"d"]) {
        [self valueTag:@"double" value:[number stringValue]];
    } else {
        [self valueTag:@"i4" value:[number stringValue]];
    }
}

- (void)encodeString:(NSString *)string omitTag:(BOOL)omitTag {
    if (omitTag)
        [self appendString:[WPStringUtils escapedStringWithString:string]];
    else
        [self valueTag:@"string" value:[WPStringUtils escapedStringWithString:string]];
}

- (void)encodeDate:(NSDate *)date {
    unsigned components = kCFCalendarUnitYear | kCFCalendarUnitMonth | kCFCalendarUnitDay | kCFCalendarUnitHour | kCFCalendarUnitMinute | kCFCalendarUnitSecond;
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:components fromDate:date];
    NSString *buffer = [NSString stringWithFormat:@"%.4ld%.2d%.2dT%.2d:%.2ld:%.2ld", (long)[dateComponents year], (int)[dateComponents month], (int)[dateComponents day], (int)[dateComponents hour], (long)[dateComponents minute], (long)[dateComponents second], nil];
    
    [self valueTag:@"dateTime.iso8601" value:buffer];
}

- (void)encodeData:(NSData *)data {
    [self valueTag:@"base64" value:[WPBase64Utils encodeData:data]];
}

- (void)encodeInputStream:(NSInputStream *)stream {
    [self appendString:@"<value><base64>"];

    [WPBase64Utils encodeInputStream:stream withChunkHandler:^(NSString *chunk) {
        [self appendString:chunk];
    }];

    [self appendString:@"</base64></value>"];
}

- (void)encodeFileHandle:(NSFileHandle *)handle {
    [self appendString:@"<value><base64>"];

    [WPBase64Utils encodeFileHandle:handle withChunkHandler:^(NSString *chunk) {
        [self appendString:chunk];
    }];

    [self appendString:@"</base64></value>"];
}

#pragma mark -

- (void)appendString:(NSString *)aString {
    [streamingCacheFile writeData:[aString dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)appendFormat:(NSString *)format, ... {
    va_list ap;
	va_start(ap, format);
	NSString *message = [[NSString alloc] initWithFormat:format arguments:ap];

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
    streamingCacheFilePath = [directory stringByAppendingPathComponent:guid];

    [fileManager createFileAtPath:streamingCacheFilePath contents:nil attributes:nil];
    streamingCacheFile = [NSFileHandle fileHandleForWritingAtPath:streamingCacheFilePath];
}

@end
