//
//  CIORequest.m
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/10/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import "CIORequest.h"

#import <objc/runtime.h>

@interface CIORequest ()

@property (nonatomic) CIOAPIClient *client;
@property (nonnull, nonatomic) NSURLRequest *urlRequest;

@property (nonatomic) NSMutableDictionary *internalParameters;
@property (nonatomic) NSString *path;
@property (nonatomic) NSString *method;


@end

@implementation CIORequest

+ (instancetype)requestWithPath:(NSString *)path method:(NSString *)method parameters:(nullable NSDictionary *)params client:(nullable CIOAPIClient *)client {
    CIORequest *request = [[self alloc] init];
    request.internalParameters = [params mutableCopy] ?: [NSMutableDictionary dictionary];
    request.path = path;
    request.method = method;
    request.client = client;
    return request;
}

+ (NSString *)nameForAccountStatus:(CIOAccountStatus)status {
    switch (status) {
        case CIOAccountStatusInvalidCredentials:
            return @"INVALID_CREDENTIALS";
        case CIOAccountStatusConnectionImpossible:
            return @"CONNECTION_IMPOSSIBLE";
        case CIOAccountStatusNoAccessToAllMail:
            return @"NO_ACCESS_TO_ALL_MAIL";
        case CIOAccountStatusOK:
            return @"OK";
        case CIOAccountStatusTempDisabled:
            return @"TEMP_DISABLED";
        case CIOAccountStatusDisabled:
            return @"DISABLED";
        case CIOAccountStatusNull:
        default:
            return nil;
    }
}

- (NSError *)validateResponseObject:(id)response {
    if ([response isKindOfClass:[NSDictionary class]]) {
        NSNumber *success = ((NSDictionary *)response)[@"success"];
        if ([success isKindOfClass:[NSNumber class]]) {
            if (![success boolValue]) {
                return [NSError errorWithDomain:@"io.context.error.response.object"
                                    code:NSURLErrorBadServerResponse
                                userInfo:@{NSLocalizedDescriptionKey: @"Request unsuccessful"}];
            }
        }
    }
    return nil;
}

- (NSError *)_validateResponse:(id)response ofType:(Class)type {
    if (![response isKindOfClass:type]) {
        NSString *errorString = [NSString stringWithFormat:@"Wrong response type: %@ expecting: %@",
                                 [response class], NSStringFromClass(type)];
        return [NSError errorWithDomain:@"io.context.error.response.type"
                                   code:NSURLErrorBadServerResponse
                               userInfo:@{NSLocalizedDescriptionKey: errorString}];
    }
    return nil;
}

#pragma mark - KVC Parameter Generation

- (NSDictionary *)parameters {
    NSMutableDictionary *parameters = [[self dictionaryWithValuesForKeys:[self.class propertyNames]] mutableCopy];
    [parameters addEntriesFromDictionary:self.internalParameters];
    for (NSString *key in [parameters copy]) {
        if (parameters[key] == [NSNull null]) {
            [parameters removeObjectForKey:key];
        } else if ([parameters[key] isKindOfClass:[NSDate class]]) {
            parameters[key] = @([(NSDate*)parameters[key] timeIntervalSince1970]);
        } else if ([parameters[key] isKindOfClass:[NSArray class]]) {
            parameters[key] = [(NSArray *)parameters[key] componentsJoinedByString:@","];
        } else if ([key isEqualToString:@"sort_order"] && [parameters[key] isKindOfClass:[NSNumber class]]) {
            CIOSortOrder order = [(NSNumber*)parameters[key] integerValue];
            if (order == CIOSortOrderAscending) {
                parameters[key] = @"asc";
            } else if (order == CIOSortOrderDescending) {
                parameters[key] = @"desc";
            } else {
                [parameters removeObjectForKey:key];
            }
        }
    }
    return parameters;
}

+ (NSArray *)propertyNames {
    unsigned int count = 0;
    objc_property_t *properties = NULL;
    Class currentClass = self;
    NSMutableArray *propertyNames = [NSMutableArray array];
    while (currentClass != nil && currentClass != [CIORequest class]) {
        @try {
            properties = class_copyPropertyList(currentClass, &count);
            for (int i = 0; i < count; i++) {
                objc_property_t property = properties[i];
                NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
                [propertyNames addObject:propertyName];
            }
        } @finally {
            free(properties);
        }
        currentClass = [currentClass superclass];
    }
    return propertyNames;
}

@end

@implementation CIODictionaryRequest

- (NSError *)validateResponseObject:(id)response {
    NSError *error = [super validateResponseObject:response];
    if (error) {
        return error;
    }
    return [self _validateResponse:response ofType:[NSDictionary class]];
}

@end

@implementation CIOArrayRequest

- (NSError *)validateResponseObject:(id)response {
    NSError *error = [super validateResponseObject:response];
    if (error) {
        return error;
    }
    return [self _validateResponse:response ofType:[NSArray class]];
}

@end

@implementation CIOStringRequest

- (NSError *)validateResponseObject:(id)response {
    NSError *error = [super validateResponseObject:response];
    if (error) {
        return error;
    }
    return [self _validateResponse:response ofType:[NSString class]];
}

@end

@implementation CIOConnectTokenRequest

+ (instancetype)requestWithToken:(NSString *)token client:(nullable CIOAPIClient *)client {
    return [self requestWithPath:[@"connect_tokens" stringByAppendingPathComponent:token]
                          method:@"GET"
                      parameters:nil
                          client:client];
}

@end