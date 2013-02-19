#import <Foundation/Foundation.h>

typedef enum {
    WPXMLRPCElementTypeArray,
    WPXMLRPCElementTypeDictionary,
    WPXMLRPCElementTypeMember,
    WPXMLRPCElementTypeName,
    WPXMLRPCElementTypeInteger,
    WPXMLRPCElementTypeDouble,
    WPXMLRPCElementTypeBoolean,
    WPXMLRPCElementTypeString,
    WPXMLRPCElementTypeDate,
    WPXMLRPCElementTypeData
} WPXMLRPCElementType;

#pragma mark -

@interface WPXMLRPCEventBasedParserDelegate : NSObject<NSXMLParserDelegate> {
    WPXMLRPCEventBasedParserDelegate *myParent;
    NSMutableArray *myChildren;
    WPXMLRPCElementType myElementType;
    NSString *myElementKey;
    id myElementValue;
}

- (id)initWithParent:(WPXMLRPCEventBasedParserDelegate *)parent;

#pragma mark -

- (void)setParent:(WPXMLRPCEventBasedParserDelegate *)parent;

- (WPXMLRPCEventBasedParserDelegate *)parent;

#pragma mark -

- (void)setElementType:(WPXMLRPCElementType)elementType;

- (WPXMLRPCElementType)elementType;

#pragma mark -

- (void)setElementKey:(NSString *)elementKey;

- (NSString *)elementKey;

#pragma mark -

- (void)setElementValue:(id)elementValue;

- (id)elementValue;

@end
