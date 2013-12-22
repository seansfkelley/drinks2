//
//  PoppingTabBarControllerDelegate.m
//  drinks
//
//  Created by Sean Kelley on 12/22/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import "PoppingTabBarControllerDelegate.h"
#import "RecipeDetailViewController.h"

@implementation PoppingTabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)viewController;
        for (UIViewController *c in navigationController.viewControllers) {
            // Pop back to the nearest recipe if we have one.
            // Testing required: it might be more desirable to not pop at all, or pop all the way.
            if ([c isKindOfClass:[RecipeDetailViewController class]]) {
                [navigationController popToViewController:c animated:NO];
                break;
            }
        }
    }
    return YES;
}

@end
