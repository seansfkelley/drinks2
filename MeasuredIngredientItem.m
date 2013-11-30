//
//  MeasuredIngredientItem.m
//  drinks
//
//  Created by Sean Kelley on 11/29/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import "MeasuredIngredientItem.h"

@interface MeasuredIngredientItem ()

@property (readwrite) IngredientItem *ingredient;
@property (readwrite) NSString *displayString;

@end

@implementation MeasuredIngredientItem

- (id)initWithIngredient:(IngredientItem *)ingredient withDisplayString:(NSString *)displayString {
    self = [super init];
    
    self.ingredient = ingredient;
    self.displayString = displayString;
    
    return self;
}

@end
