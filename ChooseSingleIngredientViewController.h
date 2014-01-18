//
//  ChooseSingleIngredientViewController.h
//  drinks
//
//  Created by Sean Kelley on 12/23/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IngredientItem.h"

typedef NSString *(^NameFormatterBlock)(IngredientItem *);

@interface ChooseSingleIngredientViewController : UITableViewController

// Input
@property NSArray *ingredients;
@property (strong) NameFormatterBlock formatter; // (strong) to appease ARC.

// Output
@property (readonly) IngredientItem *selectedIngredient;

@end
