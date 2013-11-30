//
//  MeasuredIngredientItem.m
//  drinks
//
//  Created by Sean Kelley on 11/29/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import "MeasuredIngredientItem.h"

@interface MeasuredIngredientItem ()

@property (readwrite) NSString *ingredientTag;
@property (readwrite) NSString *displayString;

@end

@implementation MeasuredIngredientItem

- (id)initWithIngredientTag:(NSString *)ingredientTag withDisplayString:(NSString *)displayString {
    self = [super init];
    
    self.ingredientTag = ingredientTag;
    self.displayString = displayString;
    
    return self;
}

@end
