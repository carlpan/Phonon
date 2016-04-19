//
//  PhotoController.m
//  Phonon
//
//  Created by Carl Pan on 2/28/16.
//  Copyright © 2016 Carl Pan. All rights reserved.
//

#import "PhotoController.h"
#import "FriendsTagViewController.h"
#import <SAMCache/SAMCache.h>

@implementation PhotoController

+ (void)imageForPhoto:(NSDictionary *)photo size:(NSString *)size completion:(void(^)(UIImage *))completion {
    if (photo == nil || size == nil || completion == nil) {
        return;
    }
    
    NSString *key = [NSString stringWithFormat:@"%@-%@", photo[@"id"], size];
    NSURL *url = [NSURL URLWithString:photo[@"images"][size][@"url"]];
    [self downloadURL:url key:key completion:completion];
}

+ (void)avatarForPhoto:(NSDictionary *)photo completion:(void (^)(UIImage *))completion {
    if (photo == nil || completion == nil) {
        return;
    }
    
    NSString *key = [NSString stringWithFormat:@"%@", photo[@"user"][@"id"]];
    NSURL *url = [NSURL URLWithString:photo[@"user"][@"profile_picture"]];
    [self downloadURL:url key:key completion:completion];
}


#pragma mark - Private

+ (void)downloadURL:(NSURL *)url key:(NSString *)key completion:(void(^)(UIImage *))completion {
    UIImage *image = [[SAMCache sharedCache] imageForKey:key];
    if (image) {
        completion(image);
    }
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        NSData *data = [NSData dataWithContentsOfURL:location];
        UIImage *image = [UIImage imageWithData:data];
        
        // Cached the image
        [[SAMCache sharedCache] setImage:image forKey:key];
        
        // return to foreground
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(image);
        });
        
    }];
    
    [task resume];
}



@end
