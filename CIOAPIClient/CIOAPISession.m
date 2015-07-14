//
//  CIOAPISession.m
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/14/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import "CIOAPISession.h"

NSString * const CIOAPISessionURLResponseErrorKey = @"io.context.error.response";

@interface CIOAPISession ()

@property (nonatomic) NSURLSession *urlSession;
@property (nonatomic) NSIndexSet *acceptableStatusCodes;

@end

@implementation CIOAPISession

- (instancetype)initWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret token:(NSString *)token tokenSecret:(NSString *)tokenSecret accountID:(NSString *)accountID {
    if ((self = [super initWithConsumerKey:consumerKey consumerSecret:consumerSecret token:token tokenSecret:tokenSecret accountID:accountID])) {
        self.urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        // Hat tip to AFNetworking
        self.acceptableStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
    }
    return self;
}

// If `block` is nonnull, calls it with `parameter` on the main dispatch queue
- (void)_dispatchMain:(nullable void (^)(id param))block parameter:(id)parameter {
    if (block) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(parameter);
        });
    }
}

- (NSError *)errorForResponse:(NSHTTPURLResponse *)response responseObject:(id)responseObject {
    NSString *errorString = nil;
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        if ([responseObject[@"type"] isEqual:@"error"]) {
            errorString = responseObject[@"value"];
        } else if ([responseObject[@"success"] isEqual:@NO]) {
            NSArray *responseValues = @[responseObject[@"feedback_code"] ?: @"", responseObject[@"connectionLog"] ?: @""];
            errorString = [responseValues componentsJoinedByString:@"\n"];
        }
    }
    if (!errorString) {
        NSInteger code = response.statusCode;
        errorString = [NSString stringWithFormat:@"Invalid server response: %@ (%ld)", [NSHTTPURLResponse localizedStringForStatusCode:code], (long)code];
    }
    return [NSError errorWithDomain:@"io.context.error.statuscode"
                               code:NSURLErrorBadServerResponse
                           userInfo:@{ NSLocalizedDescriptionKey: errorString,
                                       CIOAPISessionURLResponseErrorKey: response
                                       }];
}

- (id)parseResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError **)error {
    id jsonResponse = nil;
    if (data && [data length] > 0) {
        NSError *jsonError;
        jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (jsonError) {
            *error = jsonError;
            return nil;
        }
    }
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSUInteger code = (NSUInteger)[(NSHTTPURLResponse*)response statusCode];
        if (![self.acceptableStatusCodes containsIndex:code]) {
            *error = [self errorForResponse:(NSHTTPURLResponse*)response responseObject:jsonResponse];
            return jsonResponse;
        }
    }
    return jsonResponse;
}

- (void)executeRequest:(NSURLRequest *)request success:(void (^)(id responseObject))successBlock failure:(void (^)(NSError *error))failureBlock {
    NSURLSessionDataTask *dataTask = [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            [self _dispatchMain:failureBlock parameter:error];
            return;
        }
        id jsonResponse = [self parseResponse:response data:data error:&error];
        if (error) {
            [self _dispatchMain:failureBlock parameter:error];
        } else {
            [self _dispatchMain:successBlock parameter:jsonResponse];
        }
    }];
    [dataTask resume];
}

- (void)executeDictionaryRequest:(CIODictionaryRequest *)request success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure {
    [self executeRequest:request.urlRequest success:success failure:failure];
}

- (void)executeArrayRequest:(CIOArrayRequest *)request success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure {
    [self executeRequest:request.urlRequest success:success failure:failure];
}

@end
