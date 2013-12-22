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
#import "SourceSiteViewController.h"

@interface RecipeDetailViewController ()

@property IBOutlet UILabel *labelView;
@property IBOutlet UITableView *ingredientsTableView;
@property IBOutlet SourceSiteViewController *sourceController;

@property UIBarButtonItem *nextButton;
@property UIBarButtonItem *previousButton;

@property NSMutableArray *sectionIngredients;
@property NSMutableArray *sectionTitles;

@property (readonly) RecipeSearchResultItem *recipeResult;
@property (readonly) BOOL hasInstructions;
@property (readonly) BOOL hasNotes;

@end

typedef enum rowTypeEnum {
    INGREDIENT,
    INSTRUCTIONS,
    NOTES
} RowType;

static int DEFAULT_TABLE_CELL_HEIGHT;
static UIFont *DEFAULT_TABLE_CELL_FONT;
static int DEFAULT_TABLE_CELL_WIDTH;

@implementation RecipeDetailViewController

- (RecipeSearchResultItem *)recipeResult {
    return [self.allRecipeResults objectAtIndex:self.currentResultIndex];
}

- (BOOL)hasInstructions {
    return self.recipeResult.recipe.instructions != nil;
}

- (BOOL)hasNotes {
    return self.recipeResult.recipe.notes != nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // This is some horrific shit.
    // UITableViewCell *dummy = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    DEFAULT_TABLE_CELL_HEIGHT = 44; // dummy.frame.size.height;
    DEFAULT_TABLE_CELL_WIDTH  = 320 - 40; // iPhone width - inferred padding.
    DEFAULT_TABLE_CELL_FONT   = [UIFont systemFontOfSize:14.0f]; // dummy.detailTextLabel.font;
    
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
    [self.ingredientsTableView reloadData];
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
    
    if (self.hasInstructions) {
        [self.sectionTitles addObject:@"Instructions"];
    }
    if (self.hasNotes) {
        [self.sectionTitles addObject:@"Notes"];
    }
}

- (void) updateNextPreviousButtonState {
    self.nextButton.enabled = self.currentResultIndex < [self.allRecipeResults count] - 1;
    self.previousButton.enabled = self.currentResultIndex > 0;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sectionTitles count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section < [self.sectionIngredients count]) {
        return [[self.sectionIngredients objectAtIndex:section] count];
    } else {
        return 1; // instructions or notes!
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.sectionTitles objectAtIndex:section];
}

- (MeasuredIngredientItem *)tableView:(UITableView *)tableView ingredientAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *section = [self.sectionIngredients objectAtIndex:indexPath.section];
    return [section objectAtIndex:indexPath.row];
}

// Wow, this is gross.
- (RowType)tableView:(UITableView *)tableView rowTypeForIndexPath:(NSIndexPath *)indexPath {
    NSUInteger sections = [self numberOfSectionsInTableView:tableView];
    if (self.hasInstructions && self.hasNotes) {
        if (indexPath.section == sections - 2) {
            return INSTRUCTIONS;
        } else if (indexPath.section == sections - 1){
            return NOTES;
        }
    } else if (indexPath.section == sections - 1) {
        if (self.hasInstructions) {
            return INSTRUCTIONS;
        } else if (self.hasNotes) {
            return NOTES;
        }
    }
    return INGREDIENT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text;
    switch ([self tableView:tableView rowTypeForIndexPath:indexPath]) {
        case INGREDIENT:
            return DEFAULT_TABLE_CELL_HEIGHT;
        case NOTES:
            text = self.recipeResult.recipe.notes;
            break;
        case INSTRUCTIONS:
            text = self.recipeResult.recipe.instructions;
            break;
    }
    // Is there really no better way to do this?
    return [text boundingRectWithSize:CGSizeMake(DEFAULT_TABLE_CELL_WIDTH, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:DEFAULT_TABLE_CELL_FONT} context:nil].size.height + 20; // Padding!
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MeasuredIngredientPrototypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (indexPath.section < [self.sectionIngredients count]) {
        MeasuredIngredientItem *ingredient = [self tableView:tableView ingredientAtIndexPath:indexPath];
        if (ingredient.measurementDisplay) {
            cell.textLabel.text = ingredient.measurementDisplay;
        } else {
            cell.textLabel.text = @" "; // Trick the layout into lining up the ingredient without a measure.
        }
        cell.detailTextLabel.text = ingredient.ingredientDisplay;
        cell.detailTextLabel.numberOfLines = 1;
        cell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = NO;
    } else {
        cell.textLabel.text = @""; // DON'T trick the layout as above.
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.userInteractionEnabled = YES;
        switch ([self tableView:tableView rowTypeForIndexPath:indexPath]) {
            case INGREDIENT:
                NSAssert(NO, @"Ingredient case should already be handled.");
                break;
            case INSTRUCTIONS:
                cell.detailTextLabel.text = self.recipeResult.recipe.instructions;
                break;
            case NOTES:
                cell.detailTextLabel.text = self.recipeResult.recipe.notes;
                break;
        }
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == [self.sectionTitles count] - 1) { // Last section.
        RecipeItem *recipe = self.recipeResult.recipe;
        if (recipe.source) {
            return [NSString stringWithFormat:@"Source: %@", recipe.source.name];
        }
    }
    return nil;
}

# pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    [self performSegueWithIdentifier:@"sourceSiteSegue" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *controller;
    if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        controller = [navController.viewControllers objectAtIndex:0];
    } else {
        controller = segue.destinationViewController;
    }
    
    if ([controller isKindOfClass:[SourceSiteViewController class]]) {
        SourceSiteViewController *sourceSite = (SourceSiteViewController *)controller;
        sourceSite.recipe = self.recipeResult.recipe;
    } else {
        NSAssert(NO, @"Unknown segue. All segues must be handled.");
    }
}

#pragma mark - IBActions

- (IBAction)unwindToDetails:(UIStoryboardSegue *)segue {
    
}

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
