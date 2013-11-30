//
//  RecipeIndex.m
//  drinks
//
//  Created by Sean Kelley on 11/29/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import "RecipeIndex.h"
#import "RecipeItem.h"
#import "IngredientItem.h"
#import "MeasuredIngredientItem.h"

@interface RecipeIndex ()

@property NSArray *recipes;
@property NSMutableDictionary *tagToIngredient;
@property NSMutableDictionary *recipeNameToGenericTags;

@end

#define FUDGE_FACTOR 3

@implementation RecipeIndex

+ (NSSet *)pluckGenericTags:(NSArray *)ingredients {
    NSMutableSet *genericTags = [[NSMutableSet alloc] init];
    for (IngredientItem *i in ingredients) {
        if (i.genericTag != nil) {
            [genericTags addObject:i.genericTag];
        } else {
            [genericTags addObject:i.tag];
        }
    }
    return [[NSSet alloc] initWithSet:genericTags];
}

+ (int)missingCount:(NSSet *)availableGenericTags forRecipe:(NSSet *)recipeGenericTags {
    int missing = 0;
    for (NSString *t in recipeGenericTags) {
        if (![availableGenericTags containsObject:t]) {
            missing++;
        }
    }
    return missing;
}

- (NSArray *)resolveMeasuredIngredients:(RecipeItem *)recipe {
    NSMutableArray *resolved = [[NSMutableArray alloc] init];
    for (MeasuredIngredientItem *m in recipe.ingredients) {
        [resolved addObject:[self.tagToIngredient objectForKey:m.ingredientTag]];
    }
    return resolved;
}

- (id)initWithRecipes:(NSArray *)recipes withIngredients:(NSArray *)ingredients {
    self = [super init];
    
    self.recipes = [recipes copy];
    
    self.tagToIngredient = [[NSMutableDictionary alloc] init];
    for (IngredientItem *i in ingredients) {
        [self.tagToIngredient setObject:i forKey:i.tag];
    }
    
    self.recipeNameToGenericTags = [[NSMutableDictionary alloc] init];
    for (RecipeItem *r in self.recipes) {
        [self.recipeNameToGenericTags setObject:[RecipeIndex pluckGenericTags:[self resolveMeasuredIngredients:r]] forKey:r.name];
    }
    
    return self;
}

- (NSArray *)groupByMissingIngredients:(NSArray *)ingredients {
    NSSet *genericIngredients = [RecipeIndex pluckGenericTags:ingredients];
    NSMutableArray *grouped = [[NSMutableArray alloc] init];
    for (int i = 0; i < FUDGE_FACTOR; ++i) {
        [grouped addObject:[[NSMutableArray alloc] init]];
    }
    for (RecipeItem *r in self.recipes) {
        int missing = [RecipeIndex missingCount:genericIngredients forRecipe:[self.recipeNameToGenericTags objectForKey:r.name]];
        [[grouped objectAtIndex:missing] addObject:r];
    }
    return grouped;
}

@end
