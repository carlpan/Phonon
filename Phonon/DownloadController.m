//
//  DownloadController.m
//  Phonon
//
//  Created by Carl Pan on 3/3/16.
//  Copyright © 2016 Carl Pan. All rights reserved.
//

#import "DownloadController.h"

@implementation DownloadController

+ (void)downLoadWithURLString:(NSString *)urlString completion:(void (^)(NSArray *))completion {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *reuqest = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:reuqest completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        NSData *data = [NSData dataWithContentsOfURL:location];
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        NSArray *resultArray = [responseDictionary objectForKey:@"data"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(resultArray);
        });
    }];
    
    [task resume];
}

@end
