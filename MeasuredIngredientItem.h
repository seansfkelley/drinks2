//
//  MeasuredIngredientItem.h
//  drinks
//
//  Created by Sean Kelley on 11/29/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import "IngredientItem.h"

@interface MeasuredIngredientItem : NSObject<NSCoding>

@property (readonly) IngredientItem *ingredient;
@property (readonly) NSString *measurementDisplay;
@property (readonly) NSString *ingredientDisplay;

- (id)initWithIngredient:(IngredientItem *)ingredient withMeasurementDisplay:(NSString *)measurementDisplay withIngredientDisplay:(NSString *)ingredientDisplay;

@end
