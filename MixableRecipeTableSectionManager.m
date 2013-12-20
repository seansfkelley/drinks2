//
//  MixableRecipeTableSectionManager.m
//  drinks
//
//  Created by Sean Kelley on 12/19/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import "MixableRecipeTableSectionManager.h"

@interface MixableRecipeTableSectionManager ()

@property NSArray *groupedRecipes;

@property (readwrite) NSArray *sectionTitles;
@property (readwrite) NSArray *sectionRecipeResults;
@property (readwrite) NSArray *allRecipeResults;

@end

@implementation MixableRecipeTableSectionManager

- (id)initWithRecipes:(NSArray *)groupedRecipes {
    self = [super init];
    if (self) {
        self.groupedRecipes = groupedRecipes;
        [self recompute];
    }
    return self;
}

- (void)recompute {
    NSMutableArray *sectionTitles = [[NSMutableArray alloc] init];
    NSMutableArray *sectionRecipeResults = [[NSMutableArray alloc] init];
    NSMutableArray *allRecipeResults = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [self.groupedRecipes count]; ++i) {
        NSArray *g = [self.groupedRecipes objectAtIndex:i];
        if ([g count] > 0) {
            NSString *title;
            switch (i) {
                case 0:  title = @"Mixable Drinks"; break;
                case 1:  title = @"...With Another Ingredient"; break;
                default: title = [NSString stringWithFormat:@"...With %d More Ingredients", i];
            }
            [sectionTitles addObject:title];
            [sectionRecipeResults addObject:g];
            [allRecipeResults addObjectsFromArray:g];
        }
    }
    
    self.sectionTitles = sectionTitles;
    self.sectionRecipeResults = sectionRecipeResults;
    self.allRecipeResults = allRecipeResults;
}

- (NSInteger)sectionCount {
    return [self.sectionRecipeResults count];
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    return [[self.sectionRecipeResults objectAtIndex:section] count];
}

- (RecipeSearchResultItem *)recipeResultForIndexPath:(NSIndexPath *)indexPath {
    return [[self.sectionRecipeResults objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}

@end
