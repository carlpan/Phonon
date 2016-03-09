//
//  SearchResultsController.m
//  Phonon
//
//  Created by Carl Pan on 3/3/16.
//  Copyright © 2016 Carl Pan. All rights reserved.
//

#import "SearchResultsController.h"
#import "FriendsTagViewController.h"
#import "PhotoViewController.h"

@interface SearchResultsController ()

// For general tag search, not used here
@property (strong, nonatomic) NSMutableArray *tagNames;

// For filtered user tags
@property (strong, nonatomic) NSArray *filteredMediaTagNames;

@property (strong, nonatomic) NSString *accessToken;

@end

@implementation SearchResultsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Register cell classes
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];

    self.tableView.backgroundColor = [UIColor whiteColor];
    
    // At this point, we already have access token stored
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.accessToken = [userDefaults objectForKey:@"accessToken"];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.filteredMediaTagNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [self.filteredMediaTagNames objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // removes the row highlight after selecting
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    // Get the cell
    //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    // Get the selected tag
    NSString *selectedTag = [self.filteredMediaTagNames objectAtIndex:indexPath.row];


    // Show the friends controller
    PhotoViewController *photoViewController = [[PhotoViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:photoViewController];
    navController.modalPresentationStyle = UIModalPresentationCustom;
    navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
    [UIView transitionWithView:self.view.window
                      duration:0.25
                       options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowAnimatedContent
                    animations:^{
                        [self presentViewController:navController animated:NO completion:^{
                            FriendsTagViewController *friendsViewController = [[FriendsTagViewController alloc] init];
                            friendsViewController.tagName = selectedTag;
                            friendsViewController.userIds = [photoViewController.friendIds copy];
                            [navController pushViewController:friendsViewController animated:YES];
                        }];
                    }
                    completion:nil];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - UISearchResultsUpdatingDelegate

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchTag = searchController.searchBar.text;
    if (searchTag == nil || [searchTag length] == 0) {
        [self.delegate showResultsList];
    }
    
    self.filteredMediaTagNames = [[NSArray alloc] init];
    [self filterTagsForSearchText:searchTag];
}


#pragma mark - Private methods

- (void)searchWithTagName:(NSString *)tagName {
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *urlString = [NSString stringWithFormat:@"https://api.instagram.com/v1/tags/search?q=%@&access_token=%@", tagName, self.accessToken];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
        NSData *data = [NSData dataWithContentsOfURL:location];
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        // Array of data containing searched tag infos
        NSArray *resultArray = [responseDictionary valueForKey:@"data"];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            for (NSDictionary *tagInfo in resultArray) {
                [self.tagNames addObject:[tagInfo valueForKey:@"name"]];
            }
            
            [self.tableView reloadData];
        });
    }];
    
    [task resume];
}


- (void)filterTagsForSearchText:(NSString *)searchText {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary<NSString *,id> *bindings) {
        NSString *tag = (NSString *)evaluatedObject;
        return [tag.lowercaseString containsString:searchText.lowercaseString];
    }];
    
    self.filteredMediaTagNames = [self.mediaTagNames filteredArrayUsingPredicate:predicate];
    
    [self.tableView reloadData];
}

@end
