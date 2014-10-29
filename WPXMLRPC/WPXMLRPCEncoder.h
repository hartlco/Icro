// WPXMLRPCEncoder.h
//
// Copyright (c) 2013 WordPress - http://wordpress.org/
// Based on Eric Czarny's xmlrpc library - https://github.com/eczarny/xmlrpc
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>

/**
 `WPXMLRPCEncoder` encodes a XML-RPC request
 */
@interface WPXMLRPCEncoder : NSObject

/**
 Initializes a `WPXMLRPCEncoder` object with the specified method and parameters.

 @param method the XML-RPC method for this request
 @param parameters an array containing the parameters for the request. If you want to support streaming, you can use either `NSInputStream` or `NSFileHandle` to encode binary data

 @return The newly-initialized XML-RPC request
 */
- (id)initWithMethod:(NSString *)method andParameters:(NSArray *)parameters;

/**
 Initializes a `WPXMLRPCEncoder` object with the specified method and parameters.
 
 @param method the XML-RPC method for this request
 @param parameters an array containing the parameters for the request. If you want to support streaming, you can use either `NSInputStream` or `NSFileHandle` to encode binary data
 @param cacheFilePath path for the cache file that the encoder will user.If defined the invoker is responsible to delete it after the encoding is done.
 @return The newly-initialized XML-RPC request
 */
- (id)initWithMethod:(NSString *)method andParameters:(NSArray *)parameters cacheFilePath:(NSString *) path NS_DESIGNATED_INITIALIZER; 

/**
 Initializes a `WPXMLRPCEncoder` object with the specified response params.

 @warning The response encoder is for testing purposes only, and hasn't been tested to implement a XML-RPC server

 @param parameters an array containing the result parameters for the response

 @return The newly-initialized XML-RPC response
 */
- (id)initWithResponseParams:(NSArray *)params;

/**
 Initializes a `WPXMLRPCEncoder` object with the specified response fault.

 @warning The response encoder is for testing purposes only, and hasn't been tested to implement a XML-RPC server

 @param faultCode the fault code
 @param faultString the fault message string

 @return The newly-initialized XML-RPC response
 */
- (id)initWithResponseFaultCode:(NSNumber *)faultCode andString:(NSString *)faultString;

/**
 The XML-RPC method for this request.
 
 This is a *read-only* property, as requests can't be reused.
 */
@property (nonatomic, readonly) NSString *method;

/**
 The XML-RPC parameters for this request.

 This is a *read-only* property, as requests can't be reused.
 */
@property (nonatomic, readonly) NSArray *parameters;

///------------------------------------
/// @name Accessing the encoded request
///------------------------------------

/**
 The encoded request as a `NSData`
 
 You should pass this to `[NSMutableRequest setHTTPBody:]`
 */
@property (nonatomic, readonly) NSData *body;

/**
 The encoded request as a `NSInputStream`

 Every `WPXMLRPCEncoder` instance supports streaming, but it's specially useful when enconding large data files.

 You should pass this to `[NSMutableRequest setHTTPBodyStream:]`
 */
- (NSInputStream *)bodyStream;

/**
 The encoded request as a `NSInputStream`. If the enconding fails it will return nil and a the error parameter will be filled.
 
 Every `WPXMLRPCEncoder` instance supports streaming, but it's specially useful when enconding large data files.
 
 You should pass this to `[NSMutableRequest setHTTPBodyStream:]`

 @param error On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify nil for this parameter if you do not want the error information.
 
 @return an NSInputStream if the encoding works or nil if it fails.
 
 */
- (NSInputStream *)bodyStreamWithError:(NSError **) error;

/**
 The encoded request content length

 If you are using bodyStream to build your request, you should set the `Content-Length` header with this value.
 */
@property (nonatomic, readonly) NSUInteger contentLength;

/**
 The path for the cache file that is being used to stream the request.
 */
@property (nonatomic, readonly) NSString * streamingCacheFilePath;

@end
