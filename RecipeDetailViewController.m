//
//  RecipeDetailViewController.m
//  drinks
//
//  Created by Sean Kelley on 11/29/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import "RecipeDetailViewController.h"
#import "MeasuredIngredientItem.h"
#import "RecipeIndex.h"

@interface RecipeDetailViewController ()

@property IBOutlet UILabel *labelView;
@property IBOutlet UITableView *ingredientsTableView;
@property IBOutlet UITextView *instructionsTextView;

@property UIBarButtonItem *nextButton;
@property UIBarButtonItem *previousButton;

@property NSMutableArray *sectionIngredients;
@property NSMutableArray *sectionTitles;

@property (readonly) RecipeSearchResultItem *recipeResult;

@end

@implementation RecipeDetailViewController

- (RecipeSearchResultItem *)recipeResult {
    return [self.allRecipeResults objectAtIndex:self.currentResultIndex];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.previousButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"UIButtonBarArrowUp"] style:UIBarButtonItemStylePlain target:self action:@selector(goToPrevious)];
    // TODO: These have SO MANY MUCH SPACING.
    // http://stackoverflow.com/questions/18897470/ios7-excessive-navigationbar-button-padding
    self.nextButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"UIButtonBarArrowDown"] style:UIBarButtonItemStylePlain target:self action:@selector(goToNext)];
    [self.navigationItem setRightBarButtonItems:@[self.previousButton, self.nextButton]];

    [self regenerateContents];
    [self updateNextPreviousButtonState];
}

- (void)regenerateContents {
    [self generateTableSections];
    
    self.labelView.text = self.recipeResult.recipe.name;
    self.instructionsTextView.text = [NSString stringWithFormat:@"%@\n\n%@", self.recipeResult.recipe.instructions, self.recipeResult.recipe.notes];
    [self.ingredientsTableView reloadData];
    [self.instructionsTextView sizeToFit]; // TODO: Nonideal, but better than cutting everything off.
}

- (void)generateTableSections {
    NSArray *possibleSectionIngredients = @[
        self.recipeResult.missingIngredients,
        self.recipeResult.substituteIngredients,
        self.recipeResult.availableIngredients];
    NSArray *possibleSectionTitles = @[@"Missing Ingredients", @"Ingredients (Substitutions)", @"Ingredients"];
    
    self.sectionTitles = [[NSMutableArray alloc] init];
    self.sectionIngredients = [[NSMutableArray alloc] init];
    for (int i = 0; i < [possibleSectionIngredients count]; ++i) {
        if ([[possibleSectionIngredients objectAtIndex:i] count] > 0) {
            [self.sectionTitles addObject:[possibleSectionTitles objectAtIndex:i]];
            [self.sectionIngredients addObject:[possibleSectionIngredients objectAtIndex:i]];
        }
    }
}

- (void) updateNextPreviousButtonState {
    self.nextButton.enabled = self.currentResultIndex < [self.allRecipeResults count] - 1;
    self.previousButton.enabled = self.currentResultIndex > 0;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sectionIngredients count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.sectionIngredients objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.sectionTitles objectAtIndex:section];
}

- (MeasuredIngredientItem *)tableView:(UITableView *)tableView ingredientAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *section = [self.sectionIngredients objectAtIndex:indexPath.section];
    return [section objectAtIndex:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MeasuredIngredientPrototypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    MeasuredIngredientItem *ingredient = [self tableView:tableView ingredientAtIndexPath:indexPath];
    if (ingredient.measurementDisplay) {
        cell.textLabel.text = ingredient.measurementDisplay;
    } else {
        cell.textLabel.text = @" "; // Trick the layout into lining up the ingredient without a measure.
    }
    cell.detailTextLabel.text = ingredient.ingredientDisplay;
    return cell;
}

#pragma mark - Table view delegate

#pragma mark - IBActions

- (void)goToPrevious {
    self.currentResultIndex--;
    [self regenerateContents];
    [self updateNextPreviousButtonState];
}

- (void)goToNext {
    self.currentResultIndex++;
    [self regenerateContents];
    [self updateNextPreviousButtonState];
}

@end
