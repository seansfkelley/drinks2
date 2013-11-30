//
//  RecipeDetailViewController.h
//  drinks
//
//  Created by Sean Kelley on 11/29/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecipeItem.h"

@interface RecipeDetailViewController : UIViewController

@property RecipeItem *recipe;
@property NSArray *availableIngredients;

@end
