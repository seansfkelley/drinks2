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

@interface BrowseAllRecipesViewController ()

@property RecipeIndex *index;
@property NSMutableArray *sortedRecipeResults;

@end

@implementation BrowseAllRecipesViewController

- (IBAction)unwindToRecipes:(UIStoryboardSegue *)segue
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.index = [RecipeIndex instance];
    NSArray *sortedRecipes = [self.index.recipes sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]]];
    self.sortedRecipeResults = [[NSMutableArray alloc] init];
    for (RecipeItem *r in sortedRecipes) {
        [self.sortedRecipeResults addObject:[self.index generateDummySearchResultFor:r]];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sortedRecipeResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RecipePrototypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    RecipeSearchResultItem *result = [self.sortedRecipeResults objectAtIndex:indexPath.row];
    cell.textLabel.text = result.recipe.name;
    return cell;
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
    
    if ([controller isKindOfClass:[RecipeDetailViewController class]]) {
        RecipeDetailViewController *detail = (RecipeDetailViewController *)controller;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        detail.allRecipeResults = self.sortedRecipeResults;
        detail.currentResultIndex = indexPath.row;
    } else {
        NSAssert(NO, @"Unknown segue. All segues must be handled.");
    }
}

@end
