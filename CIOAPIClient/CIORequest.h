//
//  CIORequest.h
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/10/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CIOAPIClient;

/**
    A single request against the Context.IO API.
 */
@interface CIORequest : NSObject

/**
 *  The `CIOAPIClient` or `CIOAPISession` used to construct this request.
 */
@property (nullable, readonly, nonatomic) CIOAPIClient *client;

/**
 *  The underlying `NSURLRequest` that will be made against the Context.IO API.
 */
@property (readonly, nonatomic) NSURLRequest *urlRequest;

/**
 *  Creates a new `CIORequest` around an `NSURLRequest.
 *
 *  @param URLrequest the HTTP request against the Context.IO API
 *  @param client     The `CIOAPIClient` used to generate the request
 *
 *  @return a new `CIORequest`
 */
+ (instancetype)withURLRequest:(NSURLRequest *)URLrequest client:(nullable CIOAPIClient *)client;

/**
 *  Checks if a response returned by a 200 API call is a valid response.
 *
 *  @return nil if the response is valid, otherwise an NSError representing the response returned.
 */
- (nullable NSError *)validateResponseObject:(nullable id)response;

@end

/**
 *  A Context.io API request which returns a dictionary
 *  as its top level response object.
 */
@interface CIODictionaryRequest : CIORequest

@end

/**
 *  A Context.io API request which returns an array
 *  as its top level response object.
 */
@interface CIOArrayRequest : CIORequest
@end

/**
 *  A Context.io API request which returns a single string
    in its response.
 */
@interface CIOStringRequest : CIORequest
@end

NS_ASSUME_NONNULL_END
