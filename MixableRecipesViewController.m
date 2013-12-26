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
#import "CustomDrinkTableViewController.h"
#import "UIUtils.h"

@interface MixableRecipesViewController ()

@property NSArray *availableIngredients;

@property RecipeIndex *index;

@property MixableRecipeTableSectionManager *sections;
@property MixableRecipeTableSectionManager *searchedSections;

@property UIView *tableBackground;
@property IBOutlet UISearchDisplayController *searchController;

@end

const CGFloat ROW_HEIGHT = 88.0f;

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
    [self scrollToHideSearch];
}

- (void)showEmptyViewIfNecessary {
    if (self.sections && [self.sections sectionCount] > 0) {
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.searchController.searchBar.hidden = NO;
    } else {
        self.tableView.backgroundView = self.tableBackground;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.searchController.searchBar.hidden = YES;
    }
}

- (void)scrollToHideSearch {
    if (self.sections && [self.sections sectionCount] > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

#pragma mark - UITableViewDataSource

- (MixableRecipeTableSectionManager *)managerForTableView:(UITableView *)tableView {
    if (tableView == self.tableView) {
        return self.sections;
    } else {
        return self.searchedSections;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        return [[self managerForTableView:tableView] recipeResultForIndexPath:indexPath].recipe.isCustom;
    } else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert(editingStyle == UITableViewCellEditingStyleDelete, @"Mixable view only allows deletion of rows.");
    NSAssert(tableView == self.tableView, @"Can only delete from the primary table view (not search).");
    RecipeItem *r = [[self managerForTableView:tableView] recipeResultForIndexPath:indexPath].recipe;
    NSAssert(r.isCustom, @"Only custom drinks are deletable.");
    [self.index removeRecipe:r];
    [self recomputeMixableRecipes];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    tableView.rowHeight = ROW_HEIGHT;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender
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
        UITableView *currentTableView = [UIUtils nearestSuperview:sender ofType:[UITableView class]];
        NSIndexPath *indexPath = [currentTableView indexPathForSelectedRow];
        
        MixableRecipeTableSectionManager *manager = [self managerForTableView:currentTableView];
        NSArray *all = manager.allRecipeResults;
        detail.allRecipeResults = all;
        NSString *selectedName = [manager recipeResultForIndexPath:indexPath].recipe.name;
        // TODO: YAY LINEAR TIME
        for (int i = 0; i < [all count]; ++i) {
            RecipeSearchResultItem *r = [all objectAtIndex:i];
            if ([r.recipe.name isEqualToString:selectedName]) {
                detail.currentResultIndex = i;
                break;
            }
        }
    } else if ([controller isKindOfClass:[CustomDrinkTableViewController class]]) {
        CustomDrinkTableViewController *custom = (CustomDrinkTableViewController *)controller;
        custom.index = self.index;
    } else {
        NSAssert(NO, @"Unknown segue. All segues must be handled.");
    }
}

@end
