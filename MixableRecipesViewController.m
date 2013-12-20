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
#import "PaddedUITableViewCell.h"
#import "MixableRecipeTableSectionManager.h"

@interface MixableRecipesViewController ()

@property NSArray *availableIngredients;

@property RecipeIndex *index;

@property MixableRecipeTableSectionManager *sections;
@property MixableRecipeTableSectionManager *searchedSections;

@property UIView *tableBackground;
@property IBOutlet UISearchDisplayController *searchController;

@end

@implementation MixableRecipesViewController

- (IBAction)unwindToRecipes:(UIStoryboardSegue *)segue
{
    [self recomputeMixableRecipes];
    [self.tableView reloadData];
    [self showEmptyViewIfNecessary];
}

# pragma mark - Search

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self recomputeSearchedRecipes:searchString];
    return YES;
}

- (void)recomputeSearchedRecipes:(NSString *)searchString {
    self.searchedSections = [[MixableRecipeTableSectionManager alloc] initWithRecipes:[self.index groupByMissingIngredients:self.availableIngredients withSearchString:searchString]];
}

# pragma mark

- (void)recomputeMixableRecipes {
    [self recomputeAvailableIngredients];
    
    self.sections = [[MixableRecipeTableSectionManager alloc] initWithRecipes:[self.index groupByMissingIngredients:self.availableIngredients]];
}

- (void)recomputeAvailableIngredients {
    self.availableIngredients = [self.index.ingredients filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^ BOOL (IngredientItem *ingredient, NSDictionary *bindings) {
        return ingredient.selected;
    }]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"EmptyRecipeResultsView" owner:self options:nil];
    UIView *view = [nibs objectAtIndex:0];
    
    self.tableBackground = view;
    
    self.index = [RecipeIndex instance];
    [self recomputeMixableRecipes];
    [self showEmptyViewIfNecessary];
}

- (void)showEmptyViewIfNecessary {
    if (self.sections && [self.sections sectionCount] > 0) {
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    } else {
        self.tableView.backgroundView = self.tableBackground;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
}

#pragma mark - Table view data source

- (MixableRecipeTableSectionManager *)managerForTableView:(UITableView *)tableView {
    if (tableView == self.tableView) {
        return self.sections;
    } else {
        return self.searchedSections;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self managerForTableView:tableView] sectionCount];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self managerForTableView:tableView] numberOfRowsInSection:section];
}

//- (NSString *)subtitleForRecipe:(RecipeItem *)recipe {
//    NSMutableArray *displayStrings = [[NSMutableArray alloc] init];
//    for (IngredientItem *i in recipe.rawIngredients) {
//        [displayStrings addObject:i.displayName];
//    }
//    NSLog(@"%@", [displayStrings componentsJoinedByString:@", "]);
//    return [displayStrings componentsJoinedByString:@", "];
//}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RecipePrototypeCell";
    PaddedUITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    RecipeItem *recipe = [[self managerForTableView:tableView] recipeResultForIndexPath:indexPath].recipe;
    cell.textLabel.text = recipe.name;
    UIImage *image = [UIImage imageNamed:recipe.normalizedName];
    if (!image) {
        image = [UIImage imageNamed:@"DefaultRecipeImage"];
    }
    cell.imageView.image = image;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu ingredients", [recipe.measuredIngredients count]];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[self managerForTableView:tableView].sectionTitles objectAtIndex:section];
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
        // herp derp, need to know who got us here in the first place (tableView, that is).
        NSArray *all = self.sections.allRecipeResults;
        detail.allRecipeResults = all; // Unconditionally everything!
        NSString *selectedName = [self.sections recipeResultForIndexPath:indexPath].recipe.name;
        // TODO: YAY LINEAR TIME
        for (int i = 0; i < [all count]; ++i) {
            RecipeSearchResultItem *r = [all objectAtIndex:i];
            if ([r.recipe.name isEqualToString:selectedName]) {
                detail.currentResultIndex = i;
                break;
            }
        }
    } else {
        NSAssert(NO, @"Unknown segue. All segues must be handled.");
    }
}

@end
