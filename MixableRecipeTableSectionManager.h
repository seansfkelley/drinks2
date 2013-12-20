//
//  MixableRecipeTableSectionManager.h
//  drinks
//
//  Created by Sean Kelley on 12/19/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RecipeSearchResultItem.h"

@interface MixableRecipeTableSectionManager : NSObject

@property (readonly) NSInteger sectionCount;
@property (readonly) NSArray *sectionTitles;
@property (readonly) NSArray *sectionRecipeResults;
@property (readonly) NSArray *allRecipeResults;

- (id)initWithRecipes:(NSArray *)groupedRecipes;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (RecipeSearchResultItem *)recipeResultForIndexPath:(NSIndexPath *)indexPath;

@end
