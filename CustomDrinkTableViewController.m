//
//  CustomDrinkTableViewController.m
//  drinks
//
//  Created by Sean Kelley on 12/23/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import "CustomDrinkTableViewController.h"
#import "MeasuredIngredientItem.h"
#import "ChooseSingleIngredientViewController.h"

typedef enum rowTypeEnum {
    ONE_LINE_TEXT,
    LONG_FORM_TEXT,
    CUSTOM_INGREDIENT,
    ADD_INGREDIENT
} RowType;


@interface IngredientRowItem : NSObject

@property IngredientItem *ingredient;

- (id)initWithIngredient:(IngredientItem *)ingredient;

@end

@implementation IngredientRowItem

- (id)initWithIngredient:(IngredientItem *)ingredient {
    self = [super init];
    if (self) {
        self.ingredient = ingredient;
    }
    return self;
}

@end

@interface CustomDrinkTableViewController ()

@property NSArray *sectionTitles;
@property NSMutableArray *ingredientRows;

@end

@implementation CustomDrinkTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.editing = YES;

    self.sectionTitles = @[@"Name", @"Ingredients", @"Instructions", @"Notes", @"Source"];
    self.ingredientRows = [[NSMutableArray alloc] init];
    // This is goofy: this class gets tapped as a data source before viewDidLoad, so we need to
    // force a reload. Putting this in initWithStyle doesn't seem to help.
    [self.tableView reloadData];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
}

#pragma mark - Table view data source

- (RowType)rowTypeForIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return ONE_LINE_TEXT;
        case 1:
            if (indexPath.row < [self.ingredientRows count]) {
                return CUSTOM_INGREDIENT;
            } else {
                return ADD_INGREDIENT;
            }
        default:
            return LONG_FORM_TEXT;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sectionTitles count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return [self.ingredientRows count] + 1;
    } else {
        return 1;
    }
}

//- (UITableViewCell *)tableView:(UITableView *)tableView oneLineTextCellForIndexPath:(NSIndexPath *)indexPath {
//    static NSString *CellIdentifier = @"OneLineTextPrototypeCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    return cell;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView longFormTextCellForIndexPath:(NSIndexPath *)indexPath {
//    static NSString *CellIdentifier = @"LongFormTextPrototypeCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    return cell;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView customIngredientCellForIndexPath:(NSIndexPath *)indexPath {
//    static NSString *CellIdentifier = @"IngredientPrototypeCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    return cell;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView addIngredientCellForIndexPath:(NSIndexPath *)indexPath {
//    static NSString *CellIdentifier = @"AddIngredientPrototypeCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    return cell;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *OneLineText = @"OneLineTextPrototypeCell";
    static NSString *Ingredient = @"IngredientPrototypeCell";
    static NSString *AddIngredient = @"AddIngredientPrototypeCell";
    static NSString *LongFormText = @"LongFormTextPrototypeCell";

    UITableViewCell *cell;
    RowType rowType = [self rowTypeForIndexPath:indexPath];
    switch (rowType) {
        case ONE_LINE_TEXT:
            cell = [tableView dequeueReusableCellWithIdentifier:OneLineText forIndexPath:indexPath];
            break;
        case LONG_FORM_TEXT:
            cell = [tableView dequeueReusableCellWithIdentifier:LongFormText forIndexPath:indexPath];
            break;
        case CUSTOM_INGREDIENT:
            cell = [tableView dequeueReusableCellWithIdentifier:Ingredient forIndexPath:indexPath];
            break;
        case ADD_INGREDIENT:
            cell = [tableView dequeueReusableCellWithIdentifier:AddIngredient forIndexPath:indexPath];
            break;
    }

    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
    cell.textLabel.text = @"";

    switch (rowType) {
        case ONE_LINE_TEXT:
            break;
        case LONG_FORM_TEXT:
            break;
        case CUSTOM_INGREDIENT:
            cell.textLabel.text = @"placeholder";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case ADD_INGREDIENT:
            cell.textLabel.text = @"add ingredient";
            break;
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.sectionTitles objectAtIndex:section];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    RowType rowType = [self rowTypeForIndexPath:indexPath];
    return rowType == CUSTOM_INGREDIENT || rowType == ADD_INGREDIENT;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self rowTypeForIndexPath:indexPath] == CUSTOM_INGREDIENT ? indexPath : nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert([self rowTypeForIndexPath:indexPath] == CUSTOM_INGREDIENT, @"Only custom ingredients should be selectable.");
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    RowType rowType = [self rowTypeForIndexPath:indexPath];
    switch (rowType) {
        case CUSTOM_INGREDIENT:
            NSAssert(editingStyle == UITableViewCellEditingStyleDelete, @"CUSTOM_INGREDIENT must have delete editing style.");
            [self.ingredientRows removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case ADD_INGREDIENT: {
            NSAssert(editingStyle == UITableViewCellEditingStyleInsert, @"ADD_INGREDIENT must have insert editing style.");
            IngredientRowItem *newRow = [[IngredientRowItem alloc] initWithIngredient:nil];
            [self.ingredientRows insertObject:newRow atIndex:indexPath.row];
            [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
            break;
        }
        case ONE_LINE_TEXT:
        case LONG_FORM_TEXT:
            NSAssert(NO, @"Invalid row type '%d' for editing.", rowType);
    }
}

- (IngredientRowItem *)rowItemForIndexPath:(NSIndexPath *)indexPath {
    NSAssert(indexPath.section == 1, @"Cannot request the IngredientRowItem for a path in the wrong section.");
    return [self.ingredientRows objectAtIndex:indexPath.row];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([self rowTypeForIndexPath:indexPath]) {
        case CUSTOM_INGREDIENT:
            return UITableViewCellEditingStyleDelete;
        case ADD_INGREDIENT:
            return UITableViewCellEditingStyleInsert;
        default:
            break;
    }
    NSAssert(NO, @"Should not be requesting the editing type for non-ingredient sections.");
    return UITableViewCellEditingStyleNone;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender
{
    UIViewController *controller;
    if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        controller = [navController.viewControllers objectAtIndex:0];
    } else {
        controller = segue.destinationViewController;
    }

    if ([controller isKindOfClass:[ChooseSingleIngredientViewController class]]) {
        ChooseSingleIngredientViewController *ingredients = (ChooseSingleIngredientViewController *)controller;
        ingredients.index = self.index;
    } else {
        NSAssert(NO, @"Unknown segue. All segues must be handled.");
    }
}

# pragma mark - IBActions

- (IBAction)unwindToCustom:(UIStoryboardSegue *)segue {
    
}

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

/*
 #pragma mark - Navigation

 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 
 */

@end
