//
//  CIORequest.h
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/10/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CIOSortOrder) {
    CIOSortOrderUnspecified = 0,
    CIOSortOrderAscending,
    CIOSortOrderDescending
};


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

@property (readonly, nonatomic) NSDictionary *parameters;
@property (readonly, nonatomic) NSString *path;
@property (readonly, nonatomic) NSString *method;
/**
 A few API calls allow an arbitrary JSON body. If this is set, `parameters` will be ignored, and instead `requestBody` will be realized to json and sent as `Content-Type: application/json`.
 */
@property (nonatomic) id requestBody;


/**
 *  Creates a new `CIORequest` representing a single API call against the Context.IO API.
 *
 *  @param path   API path, e.g. "2.0/accounts/<id>/messages"
 *  @param params Parameters added to API call
 *  @param method HTTP method to use
 *  @param client optional client to be retained with this request for later execution
 *
 *  @return a new CIOAPIRequest for a specific endpoint
 */
+ (instancetype)requestWithPath:(NSString *)path method:(NSString *)method parameters:(nullable NSDictionary *)params client:(nullable CIOAPIClient *)client;

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

/**
 *  The maximum number of results to return. The maximum limit is `100`.
 */
@property (nonatomic) NSInteger limit;
/**
 *  Start the list at this offset (zero-based).
 */
@property (nonatomic) NSInteger offset;

@end

/**
 *  A Context.io API request which returns a single string
    in its response.
 */
@interface CIOStringRequest : CIORequest
@end

@interface CIOConnectTokenRequest : CIODictionaryRequest
+ (instancetype)requestWithToken:(NSString *)token client:(nullable CIOAPIClient *)client;
@end

NS_ASSUME_NONNULL_END
