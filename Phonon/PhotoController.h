//
//  PhotoController.h
//  Phonon
//
//  Created by Carl Pan on 2/28/16.
//  Copyright © 2016 Carl Pan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PhotoController : NSObject

+ (void)imageForPhoto:(NSDictionary *)photo size:(NSString *)size completion:(void(^)(UIImage *image))completion;

+ (void)avatarForPhoto:(NSDictionary *)photo completion:(void(^)(UIImage *image))completion;

@end
