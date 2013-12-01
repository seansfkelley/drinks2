//
//  RecipeIndex.h
//  drinks
//
//  Created by Sean Kelley on 11/29/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecipeIndex : NSObject

@property(readonly)  int fudgeFactor;

- (id)initWithRecipes:(NSArray *)recipes withIngredients:(NSArray *)ingredients withFudgeFactor:(int)f;

- (NSArray *)groupByMissingIngredients:(NSArray *)ingredients;

+ (NSSet *)pluckTags:(NSArray *)ingredients;
+ (NSSet *)pluckGenericTags:(NSArray *)ingredients;

+ (NSArray *)loadRecipesFromFile:(NSString *)path withIngredients:(NSArray *)ingredients;
+ (NSArray *)loadIngredientsFromFile:(NSString *)path;

@end
