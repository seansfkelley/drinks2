//
//  IngredientsViewController.m
//  drinks
//
//  Created by Sean Kelley on 11/28/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import "IngredientsViewController.h"
#import "IngredientItem.h"
#import "RecipeIndex.h"
#import "SortedTableSectionManager.h"

@interface IngredientsViewController () <UIActionSheetDelegate>

@property SortedTableSectionManager *sections;

@end

@implementation IngredientsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSMutableArray *ingredients = [[NSMutableArray alloc] init];
    for (IngredientItem *i in self.index.ingredients) {
        if (!i.hidden) {
            [ingredients addObject:i];
        }
    }
    self.sections = [[SortedTableSectionManager alloc] initWithArray:ingredients sortedByProperty:@"displayName"];
}

#pragma mark - Reset ingredients button delegate

- (IBAction)resetIngredients:(id)sender {
    UIActionSheet *confirm = [[UIActionSheet alloc]
                              initWithTitle:nil
                              delegate:self
                              cancelButtonTitle:@"Cancel"
                              destructiveButtonTitle:@"Reset Ingredients"
                              otherButtonTitles:nil];
    [confirm showInView:self.tableView];
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [actionSheet cancelButtonIndex]) {
        [self deselectAll];
    }
}

- (void) deselectAll {
    // Note that this uses the index, not the section manager. It will deselect invisible things.
    for (IngredientItem *i in self.index.ingredients) {
        i.selected = NO;
    }
    [self.tableView reloadData];
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
    static NSString *CellIdentifier = @"IngredientPrototypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    IngredientItem *ingredient = [self.sections objectForIndexPath:indexPath];
    cell.textLabel.text = ingredient.displayName;
    if (ingredient.selected) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sections.indexToTitle objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.sections.sectionIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [self.sections sectionForSectionIndexTitle:title];
}


#pragma mark - Table view delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    IngredientItem *ingredient = [self.sections objectForIndexPath:indexPath];
    ingredient.selected = !ingredient.selected;
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

@end
