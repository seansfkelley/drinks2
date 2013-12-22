//
//  RecipeIndex.h
//  drinks
//
//  Created by Sean Kelley on 11/29/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RecipeSearchResultItem.h"
#import "RecipeItem.h"

@interface RecipeIndex : NSObject

@property (readonly) int fudgeFactor;
@property (readonly) NSArray *ingredients;
@property (readonly) NSArray *recipes;
@property (readonly) NSDictionary *sources;

+ (RecipeIndex *)instance;

- (void)save;
- (void)load;
- (NSArray *)groupByMissingIngredients:(NSArray *)ingredients;
- (NSArray *)groupByMissingIngredients:(NSArray *)ingredients withSearchString:(NSString *)searchString;
- (RecipeSearchResultItem *)generateDummySearchResultFor:(RecipeItem *)recipe;

+ (NSSet *)pluckTags:(NSArray *)ingredients;
+ (NSSet *)pluckAllTags:(NSArray *)ingredients;
+ (NSSet *)pluckGenericTags:(NSArray *)ingredients;

@end
