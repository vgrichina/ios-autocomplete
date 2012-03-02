//
//  AppDelegate.m
//  Autocomplete
//
//  Created by Владимир Гричина on 02.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"

@implementation AppDelegate

@synthesize window, viewController, navController;

- (void)loadData
{
    NSString *fileContent = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fake-full-names"
                                                                                               ofType:@"txt"]
                                                      encoding:NSUTF8StringEncoding
                                                         error:NULL];
    self.viewController.listContent = [fileContent componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    [self.viewController.tableView reloadData];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
	self.navController = navigationController;

    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];

    // TODO: Make this non-blocking
    [self loadData];

    return YES;
}

@end
