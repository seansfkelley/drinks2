//
//  CustomDrinkTableViewController.h
//  drinks
//
//  Created by Sean Kelley on 12/23/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecipeIndex.h"

@interface CustomDrinkTableViewController : UITableViewController<UITextViewDelegate>

@property RecipeIndex *index;

@end
