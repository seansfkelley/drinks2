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

@property IBOutlet UITableView *ingredientsTableView;
@property IBOutlet UITextView *instructionsTextView;

@property NSMutableArray *missingIngredients;
@property NSMutableArray *haveIngredients;

@end

@implementation RecipeDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self groupIngredientsByType];
    
    self.navigationItem.title = self.recipe.name;
    self.instructionsTextView.text = [NSString stringWithFormat:@"%@\n\n%@", self.recipe.instructions, self.recipe.notes];
    [self.instructionsTextView sizeToFit]; // TODO: Nonideal, but better than cutting everything off.
}

- (void)groupIngredientsByType {
    NSSet *available = [RecipeIndex pluckGenericTags:self.availableIngredients];
    
    self.missingIngredients = [[NSMutableArray alloc] init];
    self.haveIngredients = [[NSMutableArray alloc] init];
    
    for (MeasuredIngredientItem *m in self.recipe.measuredIngredients) {
        // m.ingredient may be nil if it's something like "bitters", which we don't treat as a proper ingredient.
        if (!m.ingredient || [available containsObject:m.ingredient.tag] || [available containsObject:m.ingredient.genericTag]) {
            [self.haveIngredients addObject:m];
        } else {
            [self.missingIngredients addObject:m];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self.missingIngredients count] != 0) { // Assume: we always have at least one ingredient in haveIngredients.
        return 2;
    } else {
        return 1; // Assume: we can't have zero ingredients.
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self numberOfSectionsInTableView:tableView] == 2 && section == 0) {
        return [self.missingIngredients count];
    } else {
        return [self.haveIngredients count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self numberOfSectionsInTableView:tableView] == 2) {
        if (section == 0) {
            return @"You Need";
        } else {
            return @"You Have";
        }
    } else {
        return nil;
    }
}

- (MeasuredIngredientItem *)tableView:(UITableView *)tableView ingredientAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *section;
    if ([self numberOfSectionsInTableView:tableView] == 2 && indexPath.section == 0) {
        section = self.missingIngredients;
    } else {
        section = self.haveIngredients;
    }
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

@end
