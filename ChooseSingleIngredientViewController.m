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

@property (readwrite) IngredientItem *selectedIngredient;

@property SortedTableSectionManager *sections;

@end

const NameFormatterBlock DEFAULT_NAME_FORMATTER = ^NSString *(IngredientItem *ingredient){
    return ingredient.displayName;
};

@implementation ChooseSingleIngredientViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.sections = [[SortedTableSectionManager alloc] initWithArray:self.ingredients sortedByProperty:@"displayName"];
}

- (NameFormatterBlock)resolveFormatter {
    return self.formatter ? self.formatter : DEFAULT_NAME_FORMATTER;
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
    cell.textLabel.text = [self resolveFormatter](ingredient);
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

#pragma mark - UIViewController overrides

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        self.selectedIngredient = [self.sections objectForIndexPath:indexPath];
    } else {
        self.selectedIngredient = nil;
    }
}

@end
