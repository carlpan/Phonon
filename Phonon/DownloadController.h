//
//  DownloadController.h
//  Phonon
//
//  Created by Carl Pan on 3/3/16.
//  Copyright © 2016 Carl Pan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadController : NSObject

+ (void)downLoadWithURLString:(NSString *)urlString completion:(void(^)(NSArray *))completion;


@end
