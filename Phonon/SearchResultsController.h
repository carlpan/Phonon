//
//  SearchResultsController.h
//  Phonon
//
//  Created by Carl Pan on 3/3/16.
//  Copyright © 2016 Carl Pan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchResultsControllerDelegate <NSObject>

- (void)showResultsList;

@end

@interface SearchResultsController : UITableViewController <UISearchResultsUpdating>

// Getting all tags from user
@property (strong, nonatomic) NSArray *mediaTagNames;

// Delegate property
@property (weak, nonatomic) id <SearchResultsControllerDelegate> delegate;

@end
