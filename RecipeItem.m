//
//  RecipeItem.m
//  drinks
//
//  Created by Sean Kelley on 11/29/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import "RecipeItem.h"

@interface RecipeItem ()

@property (readwrite) NSString *name;
@property (readwrite) NSArray *measuredIngredients;

@end

@implementation RecipeItem

- (id)initWithName:(NSString *)name withMeasuredIngredients:(NSArray *)ingredients {
    self = [super init];
    self.name = [name copy];
    self.measuredIngredients = [ingredients copy];
    return self;
}

@end
