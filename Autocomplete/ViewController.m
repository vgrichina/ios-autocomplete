//
//  ViewController.m
//  Autocomplete
//
//  Created by Владимир Гричина on 02.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize listContent, filteredListContent, searchWasActive, savedSearchTerm, savedScopeButtonIndex;

#pragma mark -
#pragma mark Lifecycle methods

- (void)viewDidLoad
{
    self.filteredListContent = [NSMutableArray array];

    // restore search settings if they were saved in didReceiveMemoryWarning.
    if (self.savedSearchTerm) {
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [self.searchDisplayController.searchBar setText:self.savedSearchTerm];

        self.savedSearchTerm = nil;
    }

	[self.tableView reloadData];
	self.tableView.scrollEnabled = YES;
}

- (void)viewDidUnload
{
    self.filteredListContent = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    // save the state of the search UI so that it can be restored if the view is re-created
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
}

#pragma mark -
#pragma mark UITableView data source and delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredListContent count];
    } else {
        return [self.listContent count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCellID = @"cellID";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}

	NSString *name = nil;
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        name = [self.filteredListContent objectAtIndex:indexPath.row];
    } else {
        name = [self.listContent objectAtIndex:indexPath.row];
    }

	cell.textLabel.text = name;
	return cell;
}

#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	[self.filteredListContent removeAllObjects];

    for (NSString *name in self.listContent) {
        NSRange range = NSMakeRange(0, [searchText length]);

        // Iterate through name parts separated by space
        while (range.location != NSNotFound) {
            NSComparisonResult result = [name compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)
                                                range:range];
            if (result == NSOrderedSame) {
                [self.filteredListContent addObject:name];
            }

            range.location = [name rangeOfString:@" " options:NSLiteralSearch
                                           range:NSMakeRange(range.location, [name length] - range.location)].location;
            range.location += (range.location == NSNotFound) ? 0 : 1;
        }
	}
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];

    return YES;
}

@end
