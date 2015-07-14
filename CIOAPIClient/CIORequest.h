//
//  CIORequest.h
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/10/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CIORequest : NSObject

@property (readonly, nonatomic) NSURLRequest *urlRequest;

+ (instancetype)withURLRequest:(NSURLRequest *)URLrequest;

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