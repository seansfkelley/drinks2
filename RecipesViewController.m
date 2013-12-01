//
//  RecipesViewController.m
//  drinks
//
//  Created by Sean Kelley on 11/28/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import "RecipesViewController.h"
#import "RecipeDetailViewController.h"
#import "RecipeItem.h"
#import "RecipeIndex.h"
#import "IngredientItem.h"
#import "MeasuredIngredientItem.h"
#import "IngredientsViewController.h"

@interface RecipesViewController ()

@property NSArray *availableIngredientsList;
@property NSArray *missingCountToAvailableRecipes;
@property RecipeIndex *index;

@end

@implementation RecipesViewController

- (IBAction)unwindToRecipes:(UIStoryboardSegue *)segue
{
    [self recomputeAvailableRecipes];
    [self.tableView reloadData];
}

- (void)recomputeAvailableRecipes
{
    self.availableIngredientsList = [self.index.ingredients filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^ BOOL (IngredientItem *ingredient, NSDictionary *bindings) {
        return ingredient.selected;
    }]];
    self.missingCountToAvailableRecipes = [self.index groupByMissingIngredients:self.availableIngredientsList];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.index = [RecipeIndex instance];
    [self recomputeAvailableRecipes];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.missingCountToAvailableRecipes count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *availableWithNMissing = [self.missingCountToAvailableRecipes objectAtIndex:section];
    return [availableWithNMissing count];
}

- (RecipeItem *)recipeForIndexPath:(NSIndexPath *)indexPath {
    NSArray *section = [self.missingCountToAvailableRecipes objectAtIndex:indexPath.section];
    return [section objectAtIndex:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RecipePrototypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [self recipeForIndexPath:indexPath].name;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Mixable Drinks";
        case 1:
            return @"...With Another Ingredient";
        default:
            return [NSString stringWithFormat:@"...With %d More Ingredients", (int) section];
    }
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
        detail.recipe = [self recipeForIndexPath:indexPath];
        detail.availableIngredients = [self.availableIngredientsList copy];
    } else {
        NSAssert(NO, @"Unknown segue. All segues must be handled.");
    }
}

@end
