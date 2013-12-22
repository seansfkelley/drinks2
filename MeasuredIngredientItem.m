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
@property (readwrite) NSString *measurementDisplay;
@property (readwrite) NSString *ingredientDisplay;

@end

@implementation MeasuredIngredientItem

- (id)initWithIngredient:(IngredientItem *)ingredient withMeasurementDisplay:(NSString *)measurementDisplay withIngredientDisplay:(NSString *)ingredientDisplay {
    self = [super init];
    if (self) {
        self.ingredient = ingredient;
        self.measurementDisplay = measurementDisplay;
        self.ingredientDisplay = ingredientDisplay;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    IngredientItem *ingredient = [aDecoder decodeObjectForKey:@"ingredient"];
    NSString *measurementDisplay = [aDecoder decodeObjectForKey:@"measurementDisplay"];
    NSString *ingredientDisplay = [aDecoder decodeObjectForKey:@"ingredientDisplay"];
    return [self initWithIngredient:ingredient withMeasurementDisplay:measurementDisplay withIngredientDisplay:ingredientDisplay];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.ingredient forKey:@"ingredient"];
    [aCoder encodeObject:self.measurementDisplay forKey:@"measurementDisplay"];
    [aCoder encodeObject:self.ingredientDisplay forKey:@"ingredientDisplay"];
}

@end
