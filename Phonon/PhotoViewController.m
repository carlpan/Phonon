//
//  PhotoViewController.m
//  Phonon
//
//  Created by Carl Pan on 2/27/16.
//  Copyright © 2016 Carl Pan. All rights reserved.
//

#import "PhotoCell.h"
#import "PhotoViewController.h"
#import "DetailViewController.h"
#import "DownloadController.h"
#import "PresentDetailTransition.h"
#import "DismissDetailTransition.h"
#import "SearchResultsController.h"
#import "LoginViewController.h"
#import <SimpleAuth/SimpleAuth.h>

@interface PhotoViewController () <UIViewControllerTransitioningDelegate, SearchResultsControllerDelegate>

// Save user access token from instagram
@property (strong, nonatomic) NSString *accessToken;

// Store array data info from Instagram API
@property (strong, nonatomic) NSArray *photoData;

@property (strong, nonatomic) UISearchController *searchController;

@property (strong, nonatomic) SearchResultsController *resultsController;

@property (strong, nonatomic) NSMutableArray *tagNames;

@property (strong, nonatomic) UIRefreshControl *refreshControll;

@end

@implementation PhotoViewController

static NSString * const reuseIdentifier = @"Photo";

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
    
    // Save token (save into disk)
    // Note: NSUserDefaults is good to store access tokens (passwords)
    // better to store in to ssh keychain
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.accessToken = [userDefaults objectForKey:@"accessToken"];
    
    if (self.accessToken == nil) {
        [SimpleAuth authorize:@"instagram" options:@{@"scope": @[@"public_content", @"follower_list"]} completion:^(NSDictionary *responseObject, NSError *error) {
            
            // Get access token
            NSString *accessToken = responseObject[@"credentials"][@"token"];
            
            [userDefaults setObject:accessToken forKey:@"accessToken"];
            [userDefaults synchronize];
        }];
    }
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    // Navigation bar setup
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleDone target:self action:@selector(logoutPressed:)];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.61 green:0.17 blue:0.88 alpha:1.0];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    // Initialize Search bar here
    [self initializeSearchController];

    self.resultsController.delegate = self;
    
    [self refresh];
    
    // Initalize array of tag names for search results controller to use
    self.tagNames = [NSMutableArray array];
    
    self.friendIds = [NSMutableArray array];
    [self getListOfFollowerIds];
    
    // Initialize refresh
    self.refreshControll = [[UIRefreshControl alloc] init];
    [self.refreshControll addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControll];
    self.collectionView.alwaysBounceVertical = YES;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.photoData count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell *cell = (PhotoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    cell.photo = self.photoData[indexPath.row];
    
    return cell;
}


#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *photo = self.photoData[indexPath.row];
    
    DetailViewController *detailViewController = [[DetailViewController alloc] init];
    // Set to custom transition
    detailViewController.modalPresentationStyle = UIModalPresentationCustom;
    // set self to delegate of transitioning delegate
    detailViewController.transitioningDelegate = self;
    // Pass photo dictionary for detail display
    detailViewController.photo = photo;
    
    [self presentViewController:detailViewController animated:YES completion:nil];
}


#pragma mark <UIViewControllerTransitioningDelegate>

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[PresentDetailTransition alloc] init];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[DismissDetailTransition alloc] init];
}

/*
- (void)willPresentSearchController:(UISearchController *)searchController {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.searchController.searchResultsController.view.hidden = NO;
    });
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    self.searchController.searchResultsController.view.hidden = NO;
}
*/


#pragma mark - SearchResultsDelegate method

- (void)showResultsList {
    self.searchController.searchResultsController.view.hidden = NO;
}

#pragma mark - Private methods

- (void)initializeSearchController {
    self.resultsController = [[SearchResultsController alloc] init];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultsController];
    self.searchController.searchResultsUpdater = self.resultsController;
    // put search bar on nav bar
    self.searchController.searchBar.placeholder = @"Search your hashtags.";
    self.searchController.searchBar.tintColor = [UIColor whiteColor];
    self.navigationItem.titleView = self.searchController.searchBar;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    //self.searchController.obscuresBackgroundDuringPresentation = YES;
    self.definesPresentationContext = YES;
}

// Perform data downloading from Instgram API
- (void)refresh {
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *urlString = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/self/media/recent/?access_token=%@", self.accessToken];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {

        NSData *data = [NSData dataWithContentsOfURL:location];
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        // Array of data containing images
        self.photoData = [responseDictionary valueForKey:@"data"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // build array of tag names for user
            for (NSDictionary *photoInfo in self.photoData) {
                // get all tag names of the user
                [self.tagNames addObjectsFromArray:photoInfo[@"tags"]];
            }
            // hand the data to search results controller
            self.resultsController.mediaTagNames = [self.tagNames copy];
            
            // reload collection view
            [self.collectionView reloadData];
            
            if ([self.refreshControll isRefreshing]) {
                [self.refreshControll endRefreshing];
            }
        });
    }];
    
    [task resume];
}

- (void)getListOfFollowerIds {
    NSString *urlString = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/self/follows?access_token=%@", self.accessToken];
    
    // Call download controller class method
    [DownloadController downLoadWithURLString:urlString completion:^(NSArray *resultArray) {
        for (NSDictionary *followerInfo in resultArray) {
            [self.friendIds addObject:followerInfo[@"id"]];
        }
    }];
}


#pragma mark - IBActions

/*
- (IBAction)logoutPressed:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults removeObjectForKey:@"accessToken"];
    [userDefaults synchronize];
    
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    [self.navigationController pushViewController:loginVC animated:YES];
    //[self presentViewController:loginVC animated:YES completion:nil];
}
*/

@end
