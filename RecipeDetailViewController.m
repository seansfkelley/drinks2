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
#import "UIUtils.h"
#import "SourceSiteViewController.h"

@interface RecipeDetailViewController ()

@property IBOutlet UILabel *labelView;
@property IBOutlet UITableView *tableView;

@property UIBarButtonItem *nextButton;
@property UIBarButtonItem *previousButton;

@property NSMutableArray *sectionIngredients;
@property NSMutableArray *sectionTitles;

@property (readonly) RecipeSearchResultItem *recipeResult;
@property (readonly) BOOL hasInstructions;
@property (readonly) BOOL hasNotes;
@property (readonly) BOOL hasSource;
@property (readonly) BOOL shouldShowButtons;
@property (readonly) NSUInteger ingredientSectionCount;
@property (readonly) NSUInteger proseSectionCount;

@end

typedef enum rowTypeEnum {
    INGREDIENT,
    INSTRUCTIONS,
    NOTES,
    SOURCE,
    BUTTONS
} RowType;

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

- (BOOL)hasSource {
    return self.recipeResult.recipe.sourceName != nil;
}

- (BOOL)shouldShowButtons {
    return NO; // return self.recipeResult.recipe.isCustom;
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
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointMake(0.0f, -self.tableView.contentInset.top) animated:YES];
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
    if (self.hasSource) {
        [self.sectionTitles addObject:@"Source"];
    }
}

- (void) updateNextPreviousButtonState {
    self.nextButton.enabled = self.currentResultIndex < [self.allRecipeResults count] - 1;
    self.previousButton.enabled = self.currentResultIndex > 0;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.ingredientSectionCount + self.proseSectionCount + (self.shouldShowButtons ? 1 : 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section < self.ingredientSectionCount) {
        return [[self.sectionIngredients objectAtIndex:section] count];
    } else if (section < self.ingredientSectionCount + self.proseSectionCount) {
        return 1; // ingredients/notes/source
    } else {
        return 2; // buttons
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section < [self.sectionTitles count]) {
        return [self.sectionTitles objectAtIndex:section];
    } else {
        return nil;
    }
}

- (MeasuredIngredientItem *)tableView:(UITableView *)tableView ingredientAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert(indexPath.section < [self.sectionIngredients count], @"Index path inappropriate for ingredient.");
    NSArray *section = [self.sectionIngredients objectAtIndex:indexPath.section];
    return [section objectAtIndex:indexPath.row];
}

- (NSUInteger)ingredientSectionCount {
    return [self.sectionIngredients count];
}

- (NSUInteger)proseSectionCount {
    return (self.hasInstructions ? 1 : 0) + (self.hasNotes ? 1 : 0) + (self.hasSource ? 1 : 0);
}

// Wow, this is gross.
- (RowType)tableView:(UITableView *)tableView rowTypeForIndexPath:(NSIndexPath *)indexPath {
    NSInteger sectionDiff = indexPath.section - ([self numberOfSectionsInTableView:tableView] - self.proseSectionCount - (self.shouldShowButtons ? 1 : 0));
    switch (sectionDiff) {
        case 0:
            if (self.hasInstructions) return INSTRUCTIONS;
        case 1: // FALL-THROUGH
            if (self.hasNotes) return NOTES;
        case 2: // FALL-THROUGH
            if (self.hasSource) return SOURCE;
        case 3 : // FALL-THROUGH
            return BUTTONS;
        default:
            return INGREDIENT;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text;
    switch ([self tableView:tableView rowTypeForIndexPath:indexPath]) {
        case SOURCE:
        case INGREDIENT:
        case BUTTONS:
            return UIUtils.DEFAULT_CELL_HEIGHT;
        case NOTES:
            text = self.recipeResult.recipe.notes;
            break;
        case INSTRUCTIONS:
            text = self.recipeResult.recipe.instructions;
            break;
    }
    return [UIUtils cellHeightForText:text];
}

- (UITableViewCell *)tableView:(UITableView *)tableView measuredIngredientCellForIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"MeasuredIngredientPrototypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    cell.userInteractionEnabled = NO; // Disable selection.

    MeasuredIngredientItem *ingredient = [self tableView:tableView ingredientAtIndexPath:indexPath];
    if (ingredient.measurementDisplay) {
        cell.textLabel.text = ingredient.measurementDisplay;
    } else {
        cell.textLabel.text = @" "; // Trick the layout into lining up the ingredient without a measure.
    }
    cell.detailTextLabel.text = ingredient.ingredientDisplay;

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView proseTextCellForIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ProseTextPrototypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    // Configure shared values.
    cell.textLabel.text = @""; // Trick the layout into ignoring this label entirely.
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;

    // Reset some stuff.
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.userInteractionEnabled = NO;

    // Configure according to what cell it actually is.
    switch ([self tableView:tableView rowTypeForIndexPath:indexPath]) {
        case INGREDIENT:
            NSAssert(NO, @"Ingredient case should be handled elsewhere.");
            break;
        case BUTTONS:
            NSAssert(NO, @"Buttons case should be handled elsewhere.");
            break;
        case SOURCE:
            cell.detailTextLabel.text = self.recipeResult.recipe.sourceName;
            if (self.recipeResult.recipe.sourceUrl) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                cell.userInteractionEnabled = YES;
            }
            break;
        case INSTRUCTIONS:
            cell.detailTextLabel.text = self.recipeResult.recipe.instructions;
            break;
        case NOTES:
            cell.detailTextLabel.text = self.recipeResult.recipe.notes;
            break;
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView buttonCellForIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ButtonPrototypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    if (indexPath.row == 0) {
        cell.textLabel.text = @"Edit Recipe";
        cell.textLabel.textColor = [UIColor blueColor]; // Wrong color...
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"Delete Recipe";
        cell.textLabel.textColor = [UIColor redColor];
    } else {
        NSAssert(NO, @"Too many buttons in button section.");
    }

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < self.ingredientSectionCount) {
        return [self tableView:tableView measuredIngredientCellForIndexPath:indexPath];
    } else if (indexPath.section < self.ingredientSectionCount + self.proseSectionCount){
        return [self tableView:tableView proseTextCellForIndexPath:indexPath];
    } else {
        return [self tableView:tableView buttonCellForIndexPath:indexPath];
    }
}

# pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([self tableView:tableView rowTypeForIndexPath:indexPath]) {
        case SOURCE:
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            [self performSegueWithIdentifier:@"sourceSiteSegue" sender:nil];
            break;
        case BUTTONS:
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            break;
        default:
            NSAssert(NO, @"Cell type does not support selection.");
    }
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
