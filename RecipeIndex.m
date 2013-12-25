//
//  RecipeIndex.m
//  drinks
//
//  Created by Sean Kelley on 11/29/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import "RecipeIndex.h"
#import "IngredientItem.h"
#import "MeasuredIngredientItem.h"
#import "SourceItem.h"

@interface RecipeIndex ()

@property (readwrite) int fudgeFactor;
@property (readwrite) NSArray *ingredients;
@property (readwrite) NSDictionary *sources;

@property NSMutableArray *_internalRecipes;

@property NSSet *allIngredientTags;
@property NSMutableDictionary *tagToIngredient;
@property NSMutableDictionary *recipeNameToGenericTags;

@end

@implementation RecipeIndex

- (NSArray *)recipes {
    return self._internalRecipes;
}

NSString * const SELECTED_KEY = @"selected-ingredients";

+ (RecipeIndex *)instance {
    static RecipeIndex *index;
    @synchronized(self) {
        if (!index) {
            index = [RecipeIndex bootstrapIndexFromJson];
            NSArray *customRecipes = [RecipeIndex loadPermanentState];
            [index._internalRecipes addObjectsFromArray:customRecipes];

            index.fudgeFactor = 3;
            
            [index index];
        }
        return index;
    }
}

# pragma mark - Utility functions for searching

+ (NSSet *)pluckTags:(NSArray *)ingredients {
    NSMutableSet *tags = [[NSMutableSet alloc] init];
    for (IngredientItem *i in ingredients) {
        [tags addObject:i.tag];
    }
    return [[NSSet alloc] initWithSet:tags];
}

+ (NSSet *)pluckAllTags:(NSArray *)ingredients {
    NSMutableSet *tags = [[NSMutableSet alloc] init];
    for (IngredientItem *i in ingredients) {
        [tags addObject:i.tag];
        if (i.genericTag) {
            [tags addObject:i.genericTag];
        }
    }
    return [[NSSet alloc] initWithSet:tags];
}

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

# pragma mark - Initial app load from JSON

+ (RecipeIndex *)bootstrapIndexFromJson {
    RecipeIndex *index = [[RecipeIndex alloc] init];
    
    NSString *ingredientsPath = [[NSBundle mainBundle] pathForResource:@"ingredients" ofType:@".json"];
    index.ingredients = [RecipeIndex loadIngredientsFromFile:ingredientsPath];
    
    NSString *sourcesPath = [[NSBundle mainBundle] pathForResource:@"sources" ofType:@".json"];
    index.sources = [RecipeIndex loadSourcesFromFile:sourcesPath];
    
    NSString *recipesPath = [[NSBundle mainBundle] pathForResource:@"recipes" ofType:@".json"];
    index._internalRecipes = [RecipeIndex loadRecipesFromFile:recipesPath withIngredients:index.ingredients withSources:index.sources];
    
    return index;
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

+ (NSMutableArray *)loadRecipesFromFile:(NSString *)path withIngredients:(NSArray *)ingredients withSources:(NSDictionary *)sources{
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
                                             withMeasurementDisplay:[jsonIngredient objectForKey:@"displayMeasure"]
                                             withIngredientDisplay:[jsonIngredient objectForKey:@"displayIngredient"]];
                [parsedIngredients addObject:m];
            }
        }
        if (!fail) {
            RecipeItem *r = [[RecipeItem alloc]
                             initWithName:[jsonRecipe objectForKey:@"name"]
                             withMeasuredIngredients:parsedIngredients
                             withInstructions:[jsonRecipe objectForKey:@"instructions"]
                             withNotes:[jsonRecipe objectForKey:@"notes"]
                             withIsCustom:NO
                             withSource:[sources objectForKey:[jsonRecipe objectForKey:@"source"]] // May be nil.
                             withSourceOverrideUrl:[jsonRecipe objectForKey:@"url"]]; // May be nil.
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
                             withGenericTag:[jsonIngredient objectForKey:@"generic"] // May be nil.
                             withHiddenFlag:[jsonIngredient objectForKey:@"hidden"]];
        [parsedIngredients addObject:i];
    }
    return parsedIngredients;
}

+ (NSDictionary *)loadSourcesFromFile:(NSString *)path {
    NSDictionary *dict = [RecipeIndex loadJsonFromFile:path];
    if (!dict) {
        return nil;
    }
    
    NSMutableDictionary *parsedSources = [[NSMutableDictionary alloc] init];
    for (NSString *key in dict.keyEnumerator) {
        NSDictionary *jsonSource = [dict objectForKey:key];
        SourceItem *s = [[SourceItem alloc]
                         initWithName:[jsonSource objectForKey:@"name" ]
                         withUrl:[jsonSource objectForKey:@"url"]];
        [parsedSources setObject:s forKey:key];
    }
    return parsedSources;
}

# pragma mark - Public functions for searching

- (void)index {
    self.tagToIngredient = [[NSMutableDictionary alloc] init];
    for (IngredientItem *i in self.ingredients) {
        [self.tagToIngredient setObject:i forKey:i.tag];
    }
    
    self.recipeNameToGenericTags = [[NSMutableDictionary alloc] init];
    for (RecipeItem *r in self.recipes) {
        [self indexRecipe:r];
    }
    
    self.allIngredientTags = [[NSSet alloc] initWithArray:[self.tagToIngredient allKeys]];
}


- (void)addRecipe:(RecipeItem *)recipe {
    [self._internalRecipes addObject:recipe];
    [self indexRecipe:recipe];
}

- (void)indexRecipe:(RecipeItem *)recipe {
    NSMutableArray *ingredients = [[NSMutableArray alloc] init];
    for (MeasuredIngredientItem *m in recipe.measuredIngredients) {
        if (m.ingredient) {
            [ingredients addObject:m.ingredient];
        }
    }
    [self.recipeNameToGenericTags setObject:[RecipeIndex pluckGenericTags:ingredients] forKey:recipe.name];
}

- (RecipeSearchResultItem *)generateRecipeSearchResult:(RecipeItem *)recipe withIngredientTags:(NSSet *)allTags {
    NSMutableArray *missingIngredients = [[NSMutableArray alloc] init];
    NSMutableArray *substituteIngredients = [[NSMutableArray alloc] init];
    NSMutableArray *availableIngredients = [[NSMutableArray alloc] init];
    
    for (MeasuredIngredientItem *m in recipe.measuredIngredients) {
        // m.ingredient may be nil if it's something like "bitters", which we don't treat as a proper ingredient.
        if (!m.ingredient || [allTags containsObject:m.ingredient.tag]) {
            [availableIngredients addObject:m];
        } else if ([allTags containsObject:m.ingredient.genericTag]) {
            [substituteIngredients addObject:m];
        } else {
            [missingIngredients addObject:m];
        }
    }
    
    RecipeSearchResultItem *result = [[RecipeSearchResultItem alloc] init];
    result.recipe = recipe;
    result.missingIngredients = [[NSArray alloc] initWithArray:missingIngredients];
    result.substituteIngredients = [[NSArray alloc] initWithArray:substituteIngredients];
    result.availableIngredients = [[NSArray alloc] initWithArray:availableIngredients];
    return result;
}

- (RecipeSearchResultItem *)generateDummySearchResultFor:(RecipeItem *)recipe {
    return [self generateRecipeSearchResult:recipe withIngredientTags:self.allIngredientTags];
}


- (NSMutableArray *)_internalGroupByMissingIngredients:(NSArray *)ingredients {
    NSSet *genericIngredients = [RecipeIndex pluckGenericTags:ingredients];
    NSSet *allTags = [RecipeIndex pluckAllTags:ingredients];
    
    NSMutableArray *grouped = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.fudgeFactor; ++i) {
        [grouped addObject:[[NSMutableArray alloc] init]];
    }
    for (RecipeItem *r in self.recipes) {
        int missing = [RecipeIndex missingCount:genericIngredients forRecipe:[self.recipeNameToGenericTags objectForKey:r.name]];
        // Exclude recipes for which we have no significant ingredients, even if it's technically only "with two more".
        if (missing < self.fudgeFactor && missing != [[self.recipeNameToGenericTags objectForKey:r.name] count]) {
            [[grouped objectAtIndex:missing] addObject:[self generateRecipeSearchResult:r withIngredientTags:allTags]];
        }
    }
    for (int i = 0; i < self.fudgeFactor; ++i) {
        [(NSMutableArray *)[grouped objectAtIndex:i] sortUsingComparator:^NSComparisonResult(RecipeSearchResultItem *one, RecipeSearchResultItem *two) {
            return [one.recipe.name caseInsensitiveCompare:two.recipe.name];
        }];
    }
    return grouped;
}

- (NSArray *)groupByMissingIngredients:(NSArray *)ingredients {
    return [self _internalGroupByMissingIngredients:ingredients];
}

- (NSArray *)groupByMissingIngredients:(NSArray *)ingredients withSearchString:(NSString *)searchString {
    NSMutableArray *grouped = [self _internalGroupByMissingIngredients:ingredients];
    if ([searchString isEqualToString:@""]) {
        return grouped;
    } else {
        NSMutableArray *filtered = [[NSMutableArray alloc] init];
        NSPredicate *stringPredicate = [NSPredicate predicateWithFormat:@"self contains[cd] %@", searchString];
        NSPredicate *recipePredicate = [NSPredicate predicateWithBlock:^BOOL(RecipeSearchResultItem *r, NSDictionary *bindings) {
            if ([stringPredicate evaluateWithObject:r.recipe.name]) {
                return true;
            } else {
                for (MeasuredIngredientItem *i in r.recipe.measuredIngredients) {
                    if ([stringPredicate evaluateWithObject:i.ingredient.tag]) {
                        return true;
                    }
                }
                return false;
            }
        }];
        for (NSMutableArray *g in grouped) {
            NSArray *filteredGroup = [g filteredArrayUsingPredicate:recipePredicate];
            [filtered addObject:filteredGroup];
        }
        return filtered;
    }
}

# pragma mark - Save/load functions

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.ingredients = [aDecoder decodeObjectForKey:@"ingredients"];
        self.sources = [aDecoder decodeObjectForKey:@"sources"];
        self._internalRecipes = [aDecoder decodeObjectForKey:@"recipes"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.ingredients forKey:@"ingredients"];
    [aCoder encodeObject:self.sources forKey:@"sources"];
    [aCoder encodeObject:self._internalRecipes forKey:@"recipes"];
}

- (void)saveTransientState {
    NSMutableArray *selectedTags = [[NSMutableArray alloc] init];
    for (IngredientItem *i in self.ingredients) {
        if (i.selected) {
            [selectedTags addObject:i.tag];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:selectedTags forKey:SELECTED_KEY];
}

- (void)savePermanentState {
    NSArray *customRecipes = [self.recipes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isCustom == true"]];
    [NSKeyedArchiver archiveRootObject:customRecipes toFile:[RecipeIndex dataFilePath]];
}

- (void)loadTransientState {
    NSSet *selectedTags = [[NSSet alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_KEY]];
    for (IngredientItem *i in self.ingredients) {
        i.selected = [selectedTags containsObject:i.tag];
    }
}

+ (NSString *)dataDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

+ (NSString *)dataFilePath {
    return [NSString stringWithFormat:@"%@/%@", [RecipeIndex dataDirectory], @"custom-drinks.dat"];
}

+ (BOOL)createDirectoryAtPath:(NSString *)path {
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    if (!success) {
        NSLog(@"Error creating directory: %@", error.localizedDescription);
    }
    return success;
}

+ (NSArray *)loadPermanentState {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[RecipeIndex dataFilePath]];
}

@end
