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
#import "EditableIngredientTableViewCell.h"
#import "LongFormTextTableViewCell.h"
#import "OneLineTextTableViewCell.h"
#import "UIUtils.h"

typedef enum rowTypeEnum {
    ONE_LINE_TEXT,
    LONG_FORM_TEXT,
    CUSTOM_INGREDIENT,
    ADD_INGREDIENT
} RowType;

@interface CustomDrinkTableViewController ()

@property NSArray *sectionTitles;
@property NSMutableArray *ingredientRows;
@property NSMutableDictionary *sectionToComputedHeight;

@property NSIndexPath *currentIngredientRowItemIndex;

@property IBOutlet UIBarButtonItem *cancelButton;
@property IBOutlet UIBarButtonItem *doneButton;

@property UITextField *nameTextField;
@property UITextView *instructionsTextView;
@property UITextView *notesTextView;

@end

@implementation CustomDrinkTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.editing = YES;
    [self updateDoneButtonState];

    self.sectionTitles = @[@"Name", @"Ingredients", @"Instructions", @"Notes"];
    self.ingredientRows = [[NSMutableArray alloc] init];
    self.sectionToComputedHeight = [[NSMutableDictionary alloc] init];
    // This is goofy: this class gets tapped as a data source before viewDidLoad, so we need to
    // force a reload. Putting this in initWithStyle doesn't seem to help.
    [self.tableView reloadData];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([self rowTypeForIndexPath:indexPath]) {
        case LONG_FORM_TEXT: {
            NSNumber *h = [self.sectionToComputedHeight objectForKey:[NSNumber numberWithInteger:indexPath.section]];
            if (h) {
                return h.floatValue;
            } else {
                return UIUtils.DEFAULT_CELL_HEIGHT;
            }
        }
        case ONE_LINE_TEXT:
        case CUSTOM_INGREDIENT:
        case ADD_INGREDIENT:
            return UIUtils.DEFAULT_CELL_HEIGHT;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView oneLineTextCellForIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"OneLineTextPrototypeCell";
    OneLineTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    self.nameTextField = cell.textField;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView longFormTextCellForIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"LongFormTextPrototypeCell";
    LongFormTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    switch (indexPath.section) {
        case 2: self.instructionsTextView = cell.textView; break;
        case 3: self.notesTextView = cell.textView; break;
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView customIngredientCellForIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"IngredientPrototypeCell";
    EditableIngredientTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    id i = [self.ingredientRows objectAtIndex:indexPath.row];
    NSString *text;
    if (i != [NSNull null]) {
        text = ((IngredientItem *)i).displayName;
    } else {
        text = @"choose ingredient...";
    }
    [cell.ingredientButton setTitle:text forState:UIControlStateNormal];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView addIngredientCellForIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"AddIngredientPrototypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    RowType rowType = [self rowTypeForIndexPath:indexPath];
    switch (rowType) {
        case ONE_LINE_TEXT:     cell = [self tableView:tableView oneLineTextCellForIndexPath:indexPath];      break;
        case LONG_FORM_TEXT:    cell = [self tableView:tableView longFormTextCellForIndexPath:indexPath];     break;
        case CUSTOM_INGREDIENT: cell = [self tableView:tableView customIngredientCellForIndexPath:indexPath]; break;
        case ADD_INGREDIENT:    cell = [self tableView:tableView addIngredientCellForIndexPath:indexPath];    break;
    }

    cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
    cell.textLabel.text = @"";

    switch (rowType) {
        case ONE_LINE_TEXT:
            break;
        case LONG_FORM_TEXT:
            break;
        case CUSTOM_INGREDIENT:
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
            [self.ingredientRows insertObject:[NSNull null] atIndex:indexPath.row];
            [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
            break;
        }
        default:
            NSAssert(NO, @"Invalid row type '%d' for editing.", rowType);
    }
    [self updateDoneButtonState];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *controller;
    if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        controller = [navController.viewControllers objectAtIndex:0];
    } else {
        controller = segue.destinationViewController;
    }

    if (sender == self.cancelButton) {
        // nop
    } else if (sender == self.doneButton) {
        // TODO: Make a real recipe.
        MeasuredIngredientItem *m = [[MeasuredIngredientItem alloc] initWithIngredient:[self.index.ingredients objectAtIndex:0] withMeasurementDisplay:@"test ingredient" withIngredientDisplay:@"ingredient display"];
        RecipeItem *r = [[RecipeItem alloc] initWithName:@"test" withMeasuredIngredients:@[m] withInstructions:@"test instructions" withNotes:Nil withIsCustom:YES withSource:nil withSourceOverrideUrl:nil];
        [self.index addRecipe:r];
    } else if ([controller isKindOfClass:[ChooseSingleIngredientViewController class]]) {
        ChooseSingleIngredientViewController *choose = (ChooseSingleIngredientViewController *)controller;
        choose.index = self.index;

        UITableViewCell *cell = [UIUtils nearestSuperview:sender ofType:[UITableViewCell class]];
        self.currentIngredientRowItemIndex = [self.tableView indexPathForCell:cell];
    } else {
        NSAssert(NO, @"Unknown segue. All segues must be handled.");
    }
}

# pragma mark - IBActions

- (IBAction)unwindToCustom:(UIStoryboardSegue *)segue {
    if ([segue.sourceViewController isKindOfClass:[ChooseSingleIngredientViewController class]]) {
        ChooseSingleIngredientViewController *choose = (ChooseSingleIngredientViewController *)segue.sourceViewController;
        if (choose.selectedIngredient) {
            [self.ingredientRows replaceObjectAtIndex:self.currentIngredientRowItemIndex.row withObject:choose.selectedIngredient];
            [self.tableView reloadData];
    //        [self.tableView reloadRowsAtIndexPaths:@[self.currentIngredientRowItemIndex] withRowAnimation:UITableViewRowAnimationNone];
        }
        [self updateDoneButtonState];
    }
}

# pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    UITableViewCell *cell = [UIUtils nearestSuperview:textView ofType:[UITableViewCell class]];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    NSAssert([self rowTypeForIndexPath:indexPath] == LONG_FORM_TEXT, @"Cannot have text view outside of table.");

    NSNumber *key = [NSNumber numberWithInteger:indexPath.section];
    NSNumber *previousHeight = [self.sectionToComputedHeight objectForKey:key];
    // -10 magic constant because this is for some reason just a little too wide.
    CGFloat width = textView.frame.size.width - textView.contentInset.left - textView.contentInset.right - 10;
    NSNumber *newHeight = [NSNumber numberWithFloat:[UIUtils cellHeightForText:textView.text withWidth:width]];
    [self.sectionToComputedHeight setObject:newHeight forKey:key];

    [self.tableView beginUpdates];
    [self.tableView endUpdates];

    if (previousHeight && previousHeight.floatValue != newHeight.floatValue) {
        CGRect r = cell.frame;
        CGRect scrollTarget = CGRectMake(r.origin.x, r.origin.y, r.size.width, r.size.height + 10); // 10 -> bottom padding.
        // This is bad, because it doesn't work immediately while typing until a few characters into the new line have been typed.
        [self.tableView scrollRectToVisible:scrollTarget animated:YES];
    }

    [self updateDoneButtonState];
}

# pragma mark - UITextField actions

- (IBAction)textFieldDidChange:(UITextField *)textField {
    [self updateDoneButtonState];
}

# pragma mark - Miscellaneous

+ (BOOL)isStringBlank:(NSString *)string {
    if(!string.length) {
        return YES;
    } else if(![string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length) {
        return YES;
    }
    return NO;
}

- (void)updateDoneButtonState {
    BOOL enabled = YES;
    if ([CustomDrinkTableViewController isStringBlank:self.nameTextField.text]) {
        enabled = NO;
    } else if ([CustomDrinkTableViewController isStringBlank:self.instructionsTextView.text]) {
        enabled = NO;
    } else if ([self.ingredientRows count] == 0) {
        enabled = NO;
    } else {
        for (id i in self.ingredientRows) {
            if (i == [NSNull null]) {
                enabled = NO;
                break;
            }
        }
    }
    self.doneButton.enabled = enabled;
}

@end
