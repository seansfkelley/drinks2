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

@property NSMutableArray *sectionIngredients;
@property NSMutableArray *sectionTitles;

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
    
    NSMutableArray *missingIngredients = [[NSMutableArray alloc] init];
    NSMutableArray *haveIngredients = [[NSMutableArray alloc] init];
    
    for (MeasuredIngredientItem *m in self.recipe.measuredIngredients) {
        // m.ingredient may be nil if it's something like "bitters", which we don't treat as a proper ingredient.
        if (!m.ingredient || [available containsObject:m.ingredient.tag] || [available containsObject:m.ingredient.genericTag]) {
            [haveIngredients addObject:m];
        } else {
            [missingIngredients addObject:m];
        }
    }
    
    NSArray *possibleSectionIngredients = @[missingIngredients, @[], haveIngredients];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
