//
//  FriendsTagViewController.h
//  Phonon
//
//  Created by Carl Pan on 3/4/16.
//  Copyright © 2016 Carl Pan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendsTagViewController : UICollectionViewController

@property (strong, nonatomic) NSString *tagName;

@property (strong, nonatomic) NSArray *userIds;

@end
