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

NS_ASSUME_NONNULL_BEGIN

/**
 `WPXMLRPCEncoder` encodes a XML-RPC request
 */
@interface WPXMLRPCEncoder : NSObject

- (instancetype)init NS_UNAVAILABLE;

/**
 Initializes a `WPXMLRPCEncoder` object with the specified method and parameters.

 @param method the XML-RPC method for this request
 @param parameters an array containing the parameters for the request. If you want to support streaming, you can use either `NSInputStream` or `NSFileHandle` to encode binary data

 @return The newly-initialized XML-RPC request
 */
- (instancetype)initWithMethod:(NSString *)method andParameters:(nullable NSArray *)parameters NS_DESIGNATED_INITIALIZER;

/**
 Initializes a `WPXMLRPCEncoder` object with the specified response params.

 @warning The response encoder is for testing purposes only, and hasn't been tested to implement a XML-RPC server

 @param parameters an array containing the result parameters for the response

 @return The newly-initialized XML-RPC response
 */
- (instancetype)initWithResponseParams:(nullable NSArray *)params NS_DESIGNATED_INITIALIZER;

/**
 Initializes a `WPXMLRPCEncoder` object with the specified response fault.

 @warning The response encoder is for testing purposes only, and hasn't been tested to implement a XML-RPC server

 @param faultCode the fault code
 @param faultString the fault message string

 @return The newly-initialized XML-RPC response
 */
- (instancetype)initWithResponseFaultCode:(NSNumber *)faultCode andString:(NSString *)faultString NS_DESIGNATED_INITIALIZER;

/**
 The XML-RPC method for this request.
 
 This is a *read-only* property, as requests can't be reused.
 */
@property (nonatomic, readonly) NSString * method;

/**
 The XML-RPC parameters for this request.

 This is a *read-only* property, as requests can't be reused.
 */
@property (nonatomic, readonly, nullable) NSArray * parameters;

///------------------------------------
/// @name Accessing the encoded request
///------------------------------------

/**
 The encoded request as a `NSData`
 
 You should pass this to `[NSMutableRequest setHTTPBody:]`
 @warning This method is now deprecated you should use dataEncodedWithError:(NSError *)error;
 
 @param error On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify nil for this parameter if you do not want the error information.
 
 @return A NSData object with the encoded method and paramaters, nil if there was an error.
 */
@property (nonatomic, readonly, nullable) NSData * body DEPRECATED_ATTRIBUTE;

/**
 The encoded request as a `NSData` object.
 
 You should pass this to `[NSMutableRequest setHTTPBody:]`
 
 @param error On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify nil for this parameter if you do not want the error information.
 
 @return A NSData object with the encoded method and paramaters, nil if there was an error.
 */
- (nullable NSData *) dataEncodedWithError:(NSError *_Nullable*_Nullable) error;

/**
 Encodes the request to the filePath.
 
 The caller is responsible to manage the resulting file after the request is finished.
 
 @param error On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify nil for this parameter if you do not want the error information.
 
 @return BOOL, YES if the request was completed with success, NO if some error occurred.
 */
- (BOOL)encodeToFile:(NSString *)filePath error:(NSError *_Nullable*_Nullable) error;

@end

NS_ASSUME_NONNULL_END
