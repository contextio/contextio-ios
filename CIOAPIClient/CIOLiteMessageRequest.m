//
//  CIOLiteMessageRequest.m
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 9/17/15.
//  Copyright © 2015 Context.io. All rights reserved.
//

#import "CIOLiteMessageRequest.h"
#import "CIOAPIClientHeader.h"

@implementation CIOLiteMessageRequest

- (NSDictionary *)defaultParams {
    return (self.delimiter != nil) ? @{@"delimiter": self.delimiter} : @{};
}

- (CIODictionaryRequest *)moveToFolder:(NSString *)newFolder {

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:newFolder forKey:@"new_folder_id"];
    if (self.delimiter) {
        params[@"delimiter"] = self.delimiter;
    }
    return [self.client dictionaryRequestForPath:self.path method:@"PUT" params:params];
}

#pragma mark - Attachments

- (CIOArrayRequest *)listAttachments {
    NSString *path = [self.path stringByAppendingPathComponent:@"attachments"];
    return [self.client arrayRequestForPath:path method:@"GET" params:[self defaultParams]];
}

- (CIORequest *)downloadAttachmentWithID:(NSString *)attachmentID {
    NSString *path = [NSString pathWithComponents:@[self.path,
                                                    @"attachments",
                                                    attachmentID]];
    return [CIORequest requestWithPath:path
                                method:@"GET" 
                            parameters:[self defaultParams] 
                                client:self.client];
}

#pragma mark - Body

- (CIOArrayRequest *)getBodyOfType:(NSString *)bodyType {
    NSString *path = [self.path stringByAppendingPathComponent:@"body"];
    NSMutableDictionary *params = [[self defaultParams] mutableCopy];
    if (bodyType) {
        params[@"type"] = bodyType;
    }
    return [self.client arrayRequestForPath:path method:@"GET" params:params];
}

#pragma mark - Flags

- (CIODictionaryRequest *)getFlags {
    NSString *path = [self.path stringByAppendingPathComponent:@"flags"];
    return [self.client dictionaryRequestForPath:path method:@"GET" params:[self defaultParams]];
}

#pragma mark - Headers

- (CIODictionaryRequest *)getHeaders {
    NSString *path = [self.path stringByAppendingPathComponent:@"headers"];
    return [self.client dictionaryRequestForPath:path method:@"GET" params:[self defaultParams]];
}

- (CIORequest *)getRawHeaders {
    NSString *path = [self.path stringByAppendingPathComponent:@"headers"];
    NSMutableDictionary *params = [[self defaultParams] mutableCopy];
    params[@"raw"] = @YES;
    return [CIORequest requestWithPath:path method:@"GET" parameters:params client:self.client];
}

#pragma mark - Raw

- (CIORequest *)getRawMessage {
    NSString *path = [self.path stringByAppendingPathComponent:@"raw"];
    return [CIORequest requestWithPath:path
                                method:@"GET"
                            parameters:[self defaultParams]
                                client:self.client];
}

#pragma mark - Read

- (CIODictionaryRequest *)markRead {
    NSString *path = [self.path stringByAppendingPathComponent:@"read"];
    return [self.client dictionaryRequestForPath:path method:@"POST" params:[self defaultParams]];
}

- (CIODictionaryRequest *)markUnread {
    NSString *path = [self.path stringByAppendingPathComponent:@"read"];
    return [self.client dictionaryRequestForPath:path method:@"DELETE" params:[self defaultParams]];
}

@end