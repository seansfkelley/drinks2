//
//  ChooseSingleIngredientViewController.m
//  drinks
//
//  Created by Sean Kelley on 12/23/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import "ChooseSingleIngredientViewController.h"
#import "IngredientItem.h"
#import "SortedTableSectionManager.h"

@interface ChooseSingleIngredientViewController ()

@property SortedTableSectionManager *sections;

@end

@implementation ChooseSingleIngredientViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // filteredArrayWithPredicate
    NSMutableArray *ingredients = [[NSMutableArray alloc] init];
    for (IngredientItem *i in self.index.ingredients) {
        if (!i.hidden) {
            [ingredients addObject:i];
        }
    }
    self.sections = [[SortedTableSectionManager alloc] initWithArray:ingredients sortedByProperty:@"displayName"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sections.indexToSection count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.sections.indexToSection objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"IngredientPrototypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    IngredientItem *ingredient = [self.sections objectForIndexPath:indexPath];
    cell.textLabel.text = ingredient.displayName;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sections.indexToTitle objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.sections.sectionIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [self.sections sectionForSectionIndexTitle:title];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender {
    // Get which ingredient was selected and send it back somehow.
}

@end
