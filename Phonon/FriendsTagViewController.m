//
//  FriendsTagViewController.m
//  Phonon
//
//  Created by Carl Pan on 3/4/16.
//  Copyright © 2016 Carl Pan. All rights reserved.
//

#import "FriendsTagViewController.h"
#import "SearchResultsController.h"
#import "PhotoViewController.h"
#import "DownloadController.h"
#import "DetailViewController.h"
#import "PhotoController.h"
#import "PhotoCell.h"

@interface FriendsTagViewController ()

@property (strong, nonatomic) NSString *accessToken;

@property (strong, nonatomic) NSArray *friendsPhotoData;


@property (strong, nonatomic) SearchResultsController *resultsController;

@property (strong, nonatomic) UIRefreshControl *refreshControll;

@end

@implementation FriendsTagViewController

static NSString * const reuseIdentifier = @"Cell";

- (instancetype)init {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    // Make cell dynamic accross all devices
    int numCellsInRow = 3;
    CGFloat cellWidth = [[UIScreen mainScreen] bounds].size.width / numCellsInRow;
    layout.itemSize = CGSizeMake(cellWidth-1, cellWidth-1);
    layout.minimumInteritemSpacing = 1.0;
    layout.minimumLineSpacing = 1.0;
    
    return self = [super initWithCollectionViewLayout:layout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Register cell classes
    [self.collectionView registerClass:[PhotoCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    // At this point, we already have access token stored
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.accessToken = [userDefaults objectForKey:@"accessToken"];
    
    self.friendsPhotoData = [NSArray array];
    
    // Initialize refresh
    self.refreshControll = [[UIRefreshControl alloc] init];
    [self.refreshControll addTarget:self action:@selector(showFriendsPhotoWithTag:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControll];
    self.collectionView.alwaysBounceVertical = YES;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self showFriendsPhotoWithTag:self.tagName];
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.friendsPhotoData count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell *cell = (PhotoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    //cell.photo = self.friendsPhotoData[indexPath.row];
    NSDictionary *photo = self.friendsPhotoData[indexPath.row];
    [PhotoController imageForPhoto:photo size:@"thumbnail" completion:^(UIImage *image) {
        cell.imageView.image = image;
    }];
    
    return cell;
}

#pragma mark - Private methods

- (void)showFriendsPhotoWithTag:(NSString *)tagName {
    
    NSMutableArray *photoData = [NSMutableArray array];
    
    [self.userIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *friendId = (NSString *)obj;
        
        NSString *urlString = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/%@/media/recent/?access_token=%@", friendId, self.accessToken];
    
        [DownloadController downLoadWithURLString:urlString completion:^(NSArray *resultArray) {
            for (NSDictionary *photoInfo in resultArray) {
                NSArray *tags = photoInfo[@"tags"];
                if ([tags containsObject:self.tagName]) {
                    [photoData addObject:photoInfo];
                }
            }
            
            self.friendsPhotoData = [photoData copy];
            [self.collectionView reloadData];
            
            if ([self.refreshControll isRefreshing]) {
                [self.refreshControll endRefreshing];
            }

        }];
    }];
}

@end
