//
//  RecipesViewController.m
//  drinks
//
//  Created by Sean Kelley on 11/28/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import "RecipesViewController.h"
#import "RecipeDetailViewController.h"
#import "RecipeItem.h"
#import "RecipeIndex.h"
#import "IngredientItem.h"
#import "MeasuredIngredientItem.h"
#import "IngredientsViewController.h"

@interface RecipesViewController ()

@property NSArray *ingredientsList;
@property NSArray *availableIngredientsList;
@property NSArray *recipesList;
@property NSArray *availableRecipesList;
@property RecipeIndex *index;

@end

@implementation RecipesViewController

- (IBAction)unwindToRecipes:(UIStoryboardSegue *)segue
{
    [self recomputeAvailableRecipes];
    [self.tableView reloadData];
}

- (void)recomputeAvailableRecipes
{
    self.availableIngredientsList = [self.ingredientsList filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^ BOOL (IngredientItem *ingredient, NSDictionary *bindings) {
        return ingredient.selected;
    }]];
    self.availableRecipesList = [[self.index groupByMissingIngredients:self.availableIngredientsList] objectAtIndex:0];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    IngredientItem *grandMarnier = [[IngredientItem alloc] initWithDisplayName:@"Grand Marnier" withTag:@"grand marnier" withGenericTag:@"triple sec"];
    
    IngredientItem *tripleSec = [[IngredientItem alloc] initWithDisplayName:@"Triple Sec" withTag:@"triple sec"];
    tripleSec.selected = YES;
    
    IngredientItem *tequila = [[IngredientItem alloc] initWithDisplayName:@"Tequila" withTag:@"tequila"];
    tequila.selected = YES;
    
    IngredientItem *limeJuice = [[IngredientItem alloc] initWithDisplayName:@"Lime Juice" withTag:@"lime juice"];
    limeJuice.selected = YES;
    
    RecipeItem *margarita = [[RecipeItem alloc] initWithName:@"Margarita" withMeasuredIngredients:@[
        [[MeasuredIngredientItem alloc] initWithIngredientTag:@"triple sec" withDisplayString:@"1 oz triple sec"],
        [[MeasuredIngredientItem alloc] initWithIngredientTag:@"tequila"    withDisplayString:@"1 oz tequila"],
        [[MeasuredIngredientItem alloc] initWithIngredientTag:@"lime juice" withDisplayString:@"1 oz lime juice"]
    ]];
    
    self.ingredientsList = [NSArray arrayWithObjects:grandMarnier, tripleSec, tequila, limeJuice, nil];
    
    self.recipesList = [NSArray arrayWithObject:margarita];

    self.index = [[RecipeIndex alloc] initWithRecipes:self.recipesList withIngredients:self.ingredientsList];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.availableRecipesList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RecipePrototypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    RecipeItem *recipe = [self.availableRecipesList objectAtIndex:indexPath.row];
    cell.textLabel.text = recipe.name;
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
    
    if ([controller isKindOfClass:[IngredientsViewController class]]) {
        IngredientsViewController *ingredients = (IngredientsViewController *)controller;
        ingredients.ingredientsList = self.ingredientsList;
    } else if ([controller isKindOfClass:[RecipeDetailViewController class]]) {
        RecipeDetailViewController *detail = (RecipeDetailViewController *)controller;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        detail.recipe = [self.availableRecipesList objectAtIndex:indexPath.row];
        detail.availableIngredients = [self.availableIngredientsList copy];
    } else {
        NSAssert(NO, @"Unknown segue. All segues must be handled.");
    }
}

@end
