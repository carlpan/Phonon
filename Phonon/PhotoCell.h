//
//  PhotoCell.h
//  Phonon
//
//  Created by Carl Pan on 2/28/16.
//  Copyright © 2016 Carl Pan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoCell : UICollectionViewCell

// Image container inside collection view cell to display image
@property (strong, nonatomic) UIImageView *imageView;

// Dictionary containing image info
@property (strong, nonatomic) NSDictionary *photo;

@end
