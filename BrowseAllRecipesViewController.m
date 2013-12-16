//
//  BrowseAllRecipesViewController.m
//  drinks
//
//  Created by Sean Kelley on 12/1/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import "BrowseAllRecipesViewController.h"
#import "RecipeItem.h"
#import "RecipeIndex.h"
#import "RecipeDetailViewController.h"
#import "SortedTableSectionManager.h"

@interface BrowseAllRecipesViewController ()

@property RecipeIndex *index;
@property SortedTableSectionManager *sections;

@end

@implementation BrowseAllRecipesViewController

- (IBAction)unwindToRecipes:(UIStoryboardSegue *)segue
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.index = [RecipeIndex instance];
    NSMutableArray *recipeResults = [[NSMutableArray alloc] init];
    for (RecipeItem *r in self.index.recipes) {
        [recipeResults addObject:[self.index generateDummySearchResultFor:r]];
    }
    self.sections = [[SortedTableSectionManager alloc] initWithArray:recipeResults sortedByProperty:@"name"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sections.indexToSection count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.sections.indexToSection objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RecipePrototypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    RecipeSearchResultItem *result = [self.sections objectForIndexPath:indexPath];
    RecipeItem *recipe = result.recipe;
    cell.textLabel.text = recipe.name;
    UIImage *image = [UIImage imageNamed:recipe.normalizedName];
    if (!image) {
        image = [UIImage imageNamed:@"DefaultRecipeImage"];
    }
    cell.imageView.image = image;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu ingredients", [recipe.measuredIngredients count]];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sections.indexToTitle objectAtIndex:section];
}

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
//}

//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
//{
//    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
//}

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
    
    if ([controller isKindOfClass:[RecipeDetailViewController class]]) {
        RecipeDetailViewController *detail = (RecipeDetailViewController *)controller;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        detail.allRecipeResults = self.sections.sorted;
        detail.currentResultIndex = [self.sections sortedIndexForIndexPath:indexPath];
    } else {
        NSAssert(NO, @"Unknown segue. All segues must be handled.");
    }
}

@end
