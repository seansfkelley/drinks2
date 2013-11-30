//
//  RecipesViewController.m
//  drinks
//
//  Created by Sean Kelley on 11/28/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import "RecipesViewController.h"
#import "RecipeItem.h"
#import "RecipeIndex.h"
#import "IngredientItem.h"
#import "IngredientsViewController.h"

@interface RecipesViewController ()

@property NSArray *ingredientsList;
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
    NSArray *availableIngredients = [self.ingredientsList filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^ BOOL (IngredientItem *ingredient, NSDictionary *bindings) {
        return ingredient.selected;
    }]];
    self.availableRecipesList = [[self.index groupByMissingIngredients:availableIngredients] objectAtIndex:0];
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
    
    IngredientItem *tequila = [[IngredientItem alloc] initWithDisplayName:@"Tequila" withTag:@"tequila"];
    
    IngredientItem *limeJuice = [[IngredientItem alloc] initWithDisplayName:@"Lime Juice" withTag:@"lime juice"];
    
    RecipeItem *margarita = [[RecipeItem alloc] initWithName:@"Margarita" withIngredients:@[tripleSec, tequila, limeJuice]];
    
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
    if ([segue.identifier isEqualToString:@"openIngredientNavigation"]) {
        UINavigationController *navigation = [segue destinationViewController];
        // TODO: This is ultra-sketchy; there's got to be a more correct way to grab the actual destination controller
        // or otherwise share data between two controllers.
        // http://stackoverflow.com/questions/10858939/segue-destination-view-controller-weirdness
        IngredientsViewController *ingredients = [[navigation viewControllers] objectAtIndex:0];
        ingredients.ingredientsList = self.ingredientsList;
    }
}

@end
