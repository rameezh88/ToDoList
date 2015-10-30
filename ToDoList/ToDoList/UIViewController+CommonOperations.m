
//
//  UIViewController+SessionOperations.m
//  HjalpHemma
//
//  Created by Rameez Hussain on 29/10/14.
//  Copyright (c) 2014 isolve. All rights reserved.
//

#import "UIViewController+CommonOperations.h"
#import <sys/utsname.h>

@implementation UIViewController (CommonOperations)

- (void) registerForKeyboardNotifications {
    // Listen for keyboard appearances and disappearances
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void) unregisterKeyboardNofifications {
    // Listen for keyboard appearances and disappearances
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (CGSize) getScreenSize {
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width, screenHeight = [[UIScreen mainScreen] bounds].size.height;
    return CGSizeMake(screenWidth, screenHeight);
}

- (void) showAlertWithText:(NSString *)text andCancelButtonTitle: (NSString *) cancelButtonTitle {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:text delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles: nil];
    [alert show];
}

- (void) goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) showLoader {
    NSLog(@"Show loader");
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    
    UIBarButtonItem *spinnerItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    [self.navigationItem setRightBarButtonItem:spinnerItem];
    
    [spinner startAnimating];
}

- (void) hideLoader {
    NSLog(@"Hide loader");
    [self.navigationItem setRightBarButtonItem:nil];
}


- (NSString *) deviceType
{
    float viewHeight = [UIScreen mainScreen].bounds.size.height;
    if (viewHeight > 480 && viewHeight <= 568) {
        return @"5";
    } else if (viewHeight > 568 && viewHeight < 768) {
        return @"6";
    } else if (viewHeight >= 768){
        return @"6plus";
    } else {
        return @"4";
    }
}

@end
