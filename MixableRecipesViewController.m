//
//  RecipesViewController.m
//  drinks
//
//  Created by Sean Kelley on 11/28/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import "MixableRecipesViewController.h"
#import "RecipeDetailViewController.h"
#import "RecipeItem.h"
#import "RecipeIndex.h"
#import "IngredientItem.h"
#import "MeasuredIngredientItem.h"
#import "IngredientsViewController.h"
#import "RecipeSearchResultItem.h"

@interface MixableRecipesViewController ()

@property NSMutableArray *sectionTitles;
@property NSMutableArray *sectionRecipeResults;
@property RecipeIndex *index;

@property UIView *tableBackground;

@end

@implementation MixableRecipesViewController

- (IBAction)unwindToRecipes:(UIStoryboardSegue *)segue
{
    [self recomputeAvailableRecipes];
    [self.tableView reloadData];
    [self showEmptyViewIfNecessary];
}

- (void)recomputeAvailableRecipes
{
    NSArray *availableIngredientsList = [self.index.ingredients filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^ BOOL (IngredientItem *ingredient, NSDictionary *bindings) {
        return ingredient.selected;
    }]];
    
    self.sectionTitles = [[NSMutableArray alloc] init];
    self.sectionRecipeResults = [[NSMutableArray alloc] init];
    NSArray *groups = [self.index groupByMissingIngredients:availableIngredientsList];
    for (int i = 0; i < self.index.fudgeFactor; ++i) {
        NSArray *g = [groups objectAtIndex:i];
        if ([g count] > 0) {
            NSString *title;
            switch (i) {
                case 0:  title = @"Mixable Drinks"; break;
                case 1:  title = @"...With Another Ingredient"; break;
                default: title = [NSString stringWithFormat:@"...With %d More Ingredients", i];
            }
            [self.sectionTitles addObject:title];
            [self.sectionRecipeResults addObject:g];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"EmptyRecipeResultsView" owner:self options:nil];
    UIView *view = [nibs objectAtIndex:0];
    
    self.tableBackground = view;
    
    self.index = [RecipeIndex instance];
    [self recomputeAvailableRecipes];
    [self showEmptyViewIfNecessary];
}

- (void)showEmptyViewIfNecessary {
    if ([self.sectionRecipeResults count] > 0) {
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    } else {
        self.tableView.backgroundView = self.tableBackground;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sectionRecipeResults count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.sectionRecipeResults objectAtIndex:section] count];
}

- (RecipeSearchResultItem *)recipeResultForIndexPath:(NSIndexPath *)indexPath {
    NSArray *section = [self.sectionRecipeResults objectAtIndex:indexPath.section];
    return [section objectAtIndex:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RecipePrototypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [self recipeResultForIndexPath:indexPath].recipe.name;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.sectionTitles objectAtIndex:section];
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // http://stackoverflow.com/questions/15414146/uitableview-prepareforsegue-assigning-indexpath-to-sender
    UIViewController *controller;
    if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        controller = [navController.viewControllers objectAtIndex:0];
    } else {
        controller = segue.destinationViewController;
    }
    
    if ([controller isKindOfClass:[IngredientsViewController class]]) {
        IngredientsViewController *ingredients = (IngredientsViewController *)controller;
        ingredients.index = self.index;
    } else if ([controller isKindOfClass:[RecipeDetailViewController class]]) {
        RecipeDetailViewController *detail = (RecipeDetailViewController *)controller;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        detail.recipeResult = [self recipeResultForIndexPath:indexPath];
    } else {
        NSAssert(NO, @"Unknown segue. All segues must be handled.");
    }
}

@end
