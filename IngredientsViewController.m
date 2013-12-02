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

@interface IngredientsViewController () <UIActionSheetDelegate>

@property NSMutableArray *ingredientListSections;

@end

@implementation IngredientsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSMutableDictionary *sections = [[NSMutableDictionary alloc] init];
    for (IngredientItem *i in self.index.ingredients) {
        if (i.hidden) {
            continue;
        }
        NSString *first = [NSString stringWithFormat:@"%C", [i.displayName characterAtIndex:0]];
        NSMutableArray *s = [sections objectForKey:first];
        if (!s) {
            s = [[NSMutableArray alloc] init];
            [sections setObject:s forKey:first];
        }
        [s addObject:i];
    }
    for (NSMutableArray *s in [sections objectEnumerator]) {
        [s sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES]]];
    }
    
    self.ingredientListSections = [[NSMutableArray alloc] init];
    for (NSString *title in [[UILocalizedIndexedCollation currentCollation] sectionTitles]) {
        NSArray *s = [sections objectForKey:title];
        if (!s) {
            s = [[NSArray alloc] init];
        }
        [self.ingredientListSections addObject:s];
    }
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
    for (IngredientItem *i in self.index.ingredients) {
        i.selected = NO;
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.ingredientListSections count];
}

- (IngredientItem *)ingredientForIndexPath:(NSIndexPath *)indexPath {
    NSArray *section = [self.ingredientListSections objectAtIndex:indexPath.section];
    return [section objectAtIndex:indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *s = [self.ingredientListSections objectAtIndex:section];
    return [s count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"IngredientPrototypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    IngredientItem *ingredient = [self ingredientForIndexPath:indexPath];
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
    if ([[self.ingredientListSections objectAtIndex:section] count] > 0) {
        return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
    } else {
        return nil;
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}


#pragma mark - Table view delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    IngredientItem *ingredient = [self ingredientForIndexPath:indexPath];
    ingredient.selected = !ingredient.selected;
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

@end
