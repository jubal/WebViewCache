//
//  JHURLCache.m
//  WebCache
//
//  Created by Jubal Hoo on 27/4/12.
//  Copyright (c) 2012 MarsLight Studio. All rights reserved.
//

#import "JHURLCache.h"
#import <CommonCrypto/CommonDigest.h>

static NSString *cacheDirectory;
static NSSet *supportSchemes;

@implementation JHURLCache

@synthesize cachedResponses = cachedResponses_;
@synthesize responsesInfo = responsesInfo_;

-(NSString*) sha1:(NSString*)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
    
}

- (void)removeCachedResponseForRequest:(NSURLRequest *)request {
    NSLog(@"removeCachedResponseForRequest:%@", request.URL.absoluteString);
    [cachedResponses_ removeObjectForKey:request.URL.absoluteString];
    [super removeCachedResponseForRequest:request];
}

- (void)removeAllCachedResponses {
    NSLog(@"removeAllObjects");
    [cachedResponses_ removeAllObjects];
    [super removeAllCachedResponses];
}

- (id)initWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity diskPath:(NSString *)path {
    if (self = [super initWithMemoryCapacity:memoryCapacity diskCapacity:diskCapacity diskPath:path]) {
        cachedResponses_ = [[NSMutableDictionary alloc] init];
        NSString *path = [cacheDirectory stringByAppendingString:@"responsesInfo.plist"];
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        if ([fileManager fileExistsAtPath:path]) {
            responsesInfo_ = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        } else {
            responsesInfo_ = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request {
    if ([request.HTTPMethod compare:@"GET"] != NSOrderedSame) {
        return [super cachedResponseForRequest:request];
    }
    
    NSURL *url = request.URL;
    if (![supportSchemes containsObject:url.scheme]) {
        return [super cachedResponseForRequest:request];
    }
    //
    // supported url
    // check if url already cached
    NSString *absoluteString = url.absoluteString;
    NSLog(@"%@", absoluteString);
    NSCachedURLResponse *cachedResponse = [cachedResponses_ objectForKey:absoluteString];
    if (cachedResponse) {
        NSLog(@"cached: %@", absoluteString);
        return cachedResponse;
    }
    
    //
    // check if it exist in disk
    NSDictionary *responseInfo = [responsesInfo_ objectForKey:absoluteString];
    if (responseInfo) {
        NSString *path = [cacheDirectory stringByAppendingString:[responseInfo objectForKey:@"filename"]];
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        if ([fileManager fileExistsAtPath:path]) {
            
            NSData *data = [NSData dataWithContentsOfFile:path];
            NSURLResponse *response = [[NSURLResponse alloc] initWithURL:request.URL MIMEType:[responseInfo objectForKey:@"MIMEType"] expectedContentLength:data.length textEncodingName:nil];
            cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
            
            [cachedResponses_ setObject:cachedResponse forKey:absoluteString];
            NSLog(@"cached: %@", absoluteString);
            return cachedResponse;
        }
    }
    
    //
    // not cached, then we make a request and return it.
    NSMutableURLRequest *newRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:request.timeoutInterval];
    newRequest.allHTTPHeaderFields = request.allHTTPHeaderFields;
    newRequest.HTTPShouldHandleCookies = request.HTTPShouldHandleCookies;
    // if error happen
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:newRequest returningResponse:&response error:&error];
    if (error) {
        NSLog(@"%@", error);
        NSLog(@"not cached: %@", absoluteString);
        return nil;
    }
    // no error save it
    NSString *filename = [self sha1:absoluteString];
    NSString *path = [cacheDirectory stringByAppendingString:filename];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    [fileManager createFileAtPath:path contents:data attributes:nil];
    // reocord response
    NSURLResponse *newResponse = [[NSURLResponse alloc] initWithURL:response.URL MIMEType:response.MIMEType expectedContentLength:data.length textEncodingName:nil];
    responseInfo = [NSDictionary dictionaryWithObjectsAndKeys:filename, @"filename", newResponse.MIMEType, @"MIMEType", nil];
    [responsesInfo_ setObject:responseInfo forKey:absoluteString];
    NSLog(@"saved: %@", absoluteString);
    
    cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:newResponse data:data];
    [cachedResponses_ setObject:cachedResponse forKey:absoluteString];
    return cachedResponse;
}// cachedResponseForRequest:

+ (void)initialize {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    cacheDirectory = [paths objectAtIndex:0];
    supportSchemes = [NSSet setWithObjects:@"http", @"https", @"ftp", nil];
}

- (void)saveInfo {
    if ([responsesInfo_ count]) {
        NSString *path = [cacheDirectory stringByAppendingString:@"responsesInfo.plist"];
        [responsesInfo_ writeToFile:path atomically: YES];
        NSLog(@"Cache saved");
    }	
}



@end
