//
//  CustomDrinkTableViewController.m
//  drinks
//
//  Created by Sean Kelley on 12/23/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import "CustomDrinkTableViewController.h"

typedef enum rowTypeEnum {
    CUSTOM_CONTENT,
    SINGLE_EDITABLE,
    ADDABLE,
    EMPTY
} RowType;

@interface RowItem : NSObject

@property RowType type;
@property NSString *text;

- (id)initWithType:(RowType)type withText:(NSString *)text;

@end

@implementation RowItem

- (id)initWithType:(RowType)type withText:(NSString *)text {
    self = [super init];
    if (self) {
        self.type = type;
        self.text = text;
    }
    return self;
}

@end

@interface CustomDrinkTableViewController ()

@property NSMutableArray *rows;

@end

@implementation CustomDrinkTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.editing = YES;

    self.rows = [[NSMutableArray alloc] initWithArray:@[
        [[RowItem alloc] initWithType:SINGLE_EDITABLE withText:@"Name"],
        [[RowItem alloc] initWithType:EMPTY withText:nil],
        [[RowItem alloc] initWithType:ADDABLE withText:@"add Ingredient"]
    ]];
    // This is goofy: this class gets tapped as a data source before viewDidLoad, so we need to
    // force a reload. Putting this in initWithStyle doesn't seem to help.
    [self.tableView reloadData];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.rows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomDrinkPrototypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    RowItem *r = [self rowItemForIndexPath:indexPath];

    cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
    cell.textLabel.text = r.text; // How to make nice blue color?
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    cell.userInteractionEnabled = NO;

    switch (r.type) {
        case ADDABLE:
//            cell.userInteractionEnabled = YES; // But no style -- don't want to flash colors.
            break;
        case CUSTOM_CONTENT:
        case SINGLE_EDITABLE:
        case EMPTY:
            break;
    }

    return cell;
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    return YES;
//}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    RowItem *r = [self rowItemForIndexPath:indexPath];
    switch (r.type) {
        case CUSTOM_CONTENT:
            NSAssert(editingStyle == UITableViewCellEditingStyleDelete, @"CUSTOM_CONTENT must have delete editing style.");
            [self.rows removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        case SINGLE_EDITABLE:
        case EMPTY:
            break;
        case ADDABLE: {
            NSAssert(editingStyle == UITableViewCellEditingStyleInsert, @"ADDABLE must have insert editing style.");
            RowItem *newRow = [[RowItem alloc] initWithType:CUSTOM_CONTENT withText:@"test"];
            [self.rows insertObject:newRow atIndex:indexPath.row];
            [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
            break;
        }
    }
}

- (RowItem *)rowItemForIndexPath:(NSIndexPath *)indexPath {
    return [self.rows objectAtIndex:indexPath.row];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([self rowItemForIndexPath:indexPath].type) {
        case CUSTOM_CONTENT:
            return UITableViewCellEditingStyleDelete;
        case SINGLE_EDITABLE:
        case EMPTY:
            return UITableViewCellEditingStyleNone;
        case ADDABLE:
            return UITableViewCellEditingStyleInsert;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

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
