//
//  RecipeSearchResultItem.h
//  drinks
//
//  Created by Sean Kelley on 12/1/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RecipeItem.h"

@interface RecipeSearchResultItem : NSObject

@property RecipeItem *recipe;
@property NSArray *missingIngredients;
@property NSArray *substituteIngredients;
@property NSArray *availableIngredients;

// Psuedo-property forwarded from the recipe for sorting purposes.
@property (readonly) NSString *name;

@end
