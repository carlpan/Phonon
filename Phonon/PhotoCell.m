//
//  PhotoCell.m
//  Phonon
//
//  Created by Carl Pan on 2/28/16.
//  Copyright © 2016 Carl Pan. All rights reserved.
//

#import "PhotoCell.h"
#import "PhotoController.h"
#import "FriendsTagViewController.h"

@implementation PhotoCell

- (void)setPhoto:(NSDictionary *)photo {
    _photo = photo; // set instance variable
    
    [PhotoController imageForPhoto:photo size:@"thumbnail" completion:^(UIImage *image) {
        self.imageView.image = image;
    }];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialize an image view
        self.imageView = [[UIImageView alloc] init];
        
        // Adding tap gesture to like
        // Add a gesture
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(like)];
        tap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:tap];
        
        [self.contentView addSubview:self.imageView];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = self.contentView.bounds;
}

- (void)like {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Liked" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // executed on the main queue after delay
        [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    });
}


@end
