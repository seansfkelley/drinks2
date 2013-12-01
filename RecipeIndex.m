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

@property (readwrite) int fudgeFactor;

@end

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

+ (id)loadJsonFromFile:(NSString *)path {
    NSError *error;
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    
    id object = [NSJSONSerialization
                 JSONObjectWithData:data
                 options:0
                 error:&error];
    
    if (error) {
        NSLog(@"Error loading '%@': %@", path, error);
        return nil;
    } else {
        return object;
    }
}

+ (NSArray *)loadRecipesFromFile:(NSString *)path withIngredients:(NSArray *)ingredients {
    NSArray *list = [RecipeIndex loadJsonFromFile:path];
    if (!list) {
        return nil;
    }
    
    NSMutableDictionary *tagToIngredient = [[NSMutableDictionary alloc] init];
    for (IngredientItem *i in ingredients) {
        [tagToIngredient setObject:i forKey:i.tag];
    }
    
    NSMutableArray *parsedRecipes = [[NSMutableArray alloc] init];
    for (NSDictionary *jsonRecipe in list) {
        
        NSMutableArray *parsedIngredients = [[NSMutableArray alloc] init];
        BOOL fail = NO;
        for (NSDictionary *jsonIngredient in [jsonRecipe objectForKey:@"ingredients"]) {
            NSString *tag = [jsonIngredient objectForKey:@"tag"];
            // nil is a valid tag (for display-only ingredients), but not missing references.
            if (tag && ![tagToIngredient objectForKey:tag]) {
                NSLog(@"Unknown ingredient tag '%@' for recipe '%@', skipping recipe.", tag, [jsonRecipe objectForKey:@"name"]);
                fail = YES;
                break;
            } else {
                MeasuredIngredientItem *m = [[MeasuredIngredientItem alloc]
                                             initWithIngredient:[tagToIngredient objectForKey:tag]
                                             withDisplayString:[jsonIngredient objectForKey:@"display"]];
                [parsedIngredients addObject:m];
            }
        }
        if (!fail) {
            RecipeItem *r = [[RecipeItem alloc]
                             initWithName:[jsonRecipe objectForKey:@"name"]
                             withMeasuredIngredients:parsedIngredients
                             withInstructions:[jsonRecipe objectForKey:@"instructions"]];
            [parsedRecipes addObject:r];
        }
    }
    return parsedRecipes;
}

+ (NSArray *)loadIngredientsFromFile:(NSString *)path {
    NSArray *list = [RecipeIndex loadJsonFromFile:path];
    if (!list) {
        return nil;
    }
    
    NSMutableArray *parsedIngredients = [[NSMutableArray alloc] init];
    for (NSDictionary *jsonIngredient in list) {
        NSString *tag = [jsonIngredient objectForKey:@"tag"];
        if (!tag) {
            tag = [[jsonIngredient objectForKey:@"display"] lowercaseString];
        }
        IngredientItem *i = [[IngredientItem alloc]
                             initWithDisplayName:[jsonIngredient objectForKey:@"display"]
                             withTag:tag
                             withGenericTag:[jsonIngredient objectForKey:@"generic"]]; // May be nil.
        [parsedIngredients addObject:i];
    }
    return parsedIngredients;
}

- (id)initWithRecipes:(NSArray *)recipes withIngredients:(NSArray *)ingredients withFudgeFactor:(int)f {
    self = [super init];
    
    self.fudgeFactor = f;
    
    self.tagToIngredient = [[NSMutableDictionary alloc] init];
    for (IngredientItem *i in ingredients) {
        [self.tagToIngredient setObject:i forKey:i.tag];
    }
    
    self.recipeNameToGenericTags = [[NSMutableDictionary alloc] init];
    for (RecipeItem *r in recipes) {
        NSMutableArray *ingredients = [[NSMutableArray alloc] init];
        for (MeasuredIngredientItem *m in r.measuredIngredients) {
            if (m.ingredient) {
                [ingredients addObject:m.ingredient];
            }
        }
        [self.recipeNameToGenericTags setObject:[RecipeIndex pluckGenericTags:ingredients] forKey:r.name];
    }
    self.recipes = [recipes copy];
    
    return self;
}

- (NSArray *)groupByMissingIngredients:(NSArray *)ingredients {
    NSSet *genericIngredients = [RecipeIndex pluckGenericTags:ingredients];
    NSMutableArray *grouped = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.fudgeFactor; ++i) {
        [grouped addObject:[[NSMutableArray alloc] init]];
    }
    for (RecipeItem *r in self.recipes) {
        int missing = [RecipeIndex missingCount:genericIngredients forRecipe:[self.recipeNameToGenericTags objectForKey:r.name]];
        if (missing < self.fudgeFactor) {
            [[grouped objectAtIndex:missing] addObject:r];
        }
    }
    for (int i = 0; i < self.fudgeFactor; ++i) {
        [(NSMutableArray *)[grouped objectAtIndex:i] sortUsingComparator:^NSComparisonResult(RecipeItem *one, RecipeItem *two) {
            return [one.name compare:two.name];
        }];
    }
    return grouped;
}

@end
