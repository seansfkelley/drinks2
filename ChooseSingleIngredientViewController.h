//
//  ChooseSingleIngredientViewController.h
//  drinks
//
//  Created by Sean Kelley on 12/23/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecipeIndex.h"
#import "IngredientItem.h"

@interface ChooseSingleIngredientViewController : UITableViewController

@property RecipeIndex *index;
@property IngredientItem *selectedIngredient;

@end
