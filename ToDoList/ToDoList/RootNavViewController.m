//
//  RootNavViewController.m
//  ToDoList
//
//  Created by Rameez Hussain on 28/10/15.
//  Copyright © 2015 Rameez Hussain. All rights reserved.
//

#import "RootNavViewController.h"
#import "UIColor+Hex.h"

@interface RootNavViewController ()

@end

@implementation RootNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self customiseNavBar];
}

- (void) customiseNavBar {
    [self customiseTitleText];
}

- (void) customiseTitleText {
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor],
                                               NSForegroundColorAttributeName,
                                               nil];
    [self.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
    [self customiseNavBarAppearance];
}

- (void) customiseNavBarAppearance {
    UINavigationBar* navigationBar = self.navigationBar;
    [navigationBar setBarTintColor:[UIColor colorWithHexString:@"#653165"]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
