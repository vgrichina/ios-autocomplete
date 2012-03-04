//
//  ViewController.m
//  Autocomplete
//
//  Created by Владимир Гричина on 02.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

static BOOL IsOk(sqlite3 *db, int result) {
    if (result != SQLITE_OK) {
        NSLog(@"Database error: %s", sqlite3_errmsg(db));
        return NO;
    }

    return YES;
}

@implementation ViewController

@synthesize filteredListContent, searchWasActive, savedSearchTerm, savedScopeButtonIndex;

#pragma mark -
#pragma mark Lifecycle methods

- (void)viewDidLoad
{
    self.filteredListContent = [NSMutableArray array];

    if (sqlite3_open([[NSBundle mainBundle] pathForResource:@"names" ofType:@"sqlite"].UTF8String, &db)) {
        NSLog(@"Cannot open database: %s", sqlite3_errmsg(db));
        sqlite3_close(db);
        return;
    }

    if (!IsOk(db, sqlite3_prepare_v2(db, "SELECT name FROM names, parts, names_parts \
                        WHERE names.rowid = names_parts.name_id AND parts.rowid = names_parts.part_id AND part LIKE ? LIMIT 10", -1, &stmt, NULL))) {
        return;
    }

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
    sqlite3_finalize(stmt);
    sqlite3_close(db);
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
    }

    return 0;
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
    }

	cell.textLabel.text = name;
	return cell;
}

#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSLog(@"Start filtering: %@", searchText);

	[self.filteredListContent removeAllObjects];

    if (!IsOk(db, sqlite3_reset(stmt))) {
        return;
    }

    if (!IsOk(db, sqlite3_clear_bindings(stmt))) {
        return;
    }

    if (!IsOk(db, sqlite3_bind_text(stmt, 1, [searchText stringByAppendingString:@"%"].UTF8String, -1, SQLITE_TRANSIENT))) {
        return;
    }

    while (sqlite3_step(stmt) == SQLITE_ROW) {
        [self.filteredListContent addObject:
         [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 0)]];
    }

    [self.filteredListContent sortUsingSelector:@selector(caseInsensitiveCompare:)];

    NSLog(@"Finish filtering: %@", searchText);
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
