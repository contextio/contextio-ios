//
//  CIOAFNetworkingClient.h
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/10/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CIOAPIClient.h"

NS_ASSUME_NONNULL_BEGIN

@interface CIOAFNetworkingClient : NSObject

@property (readonly, nonatomic) CIOAPIClient *CIOClient;

/**
 The HTTP client used to interact with the API.
 */
@property (readonly, nonatomic) AFHTTPClient *HTTPClient;

/**
 Initializes a `CIOAPIClient` object with the specified consumer key and secret.

 @param consumerKey The consumer key for the API client. This argument must not be `nil`.
 @param consumerSecret The consumer secret for the API client. This argument must not be `nil`.

 @return The newly-initialized API client
 */
- (instancetype)initWithConsumerKey:(NSString *)consumerKey
           consumerSecret:(NSString *)consumerSecret;

/**
 Initializes a `CIOAPIClient` object with the specified consumer key and secret, and additionally token and token secret. Use this method if you have already obtained a token and token secret on your own, and do not wish to use the built-in keychain storage.

 @param consumerKey The consumer key for the API client. This argument must not be `nil`.
 @param consumerSecret The consumer secret for the API client. This argument must not be `nil`.
 @param token The auth token for the API client.
 @param tokenSecret The auth token secret for the API client.
 @param accountID The account ID the client should use to construct requests.

 @return The newly-initialized API client
 */
- (instancetype)initWithConsumerKey:(NSString *)consumerKey
           consumerSecret:(NSString *)consumerSecret
                    token:(nullable NSString *)token
              tokenSecret:(nullable NSString *)tokenSecret
                accountID:(nullable NSString *)accountID;

@end

NS_ASSUME_NONNULL_END
