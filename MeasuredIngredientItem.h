//
//  MeasuredIngredientItem.h
//  drinks
//
//  Created by Sean Kelley on 11/29/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import "IngredientItem.h"

@interface MeasuredIngredientItem : NSObject

- (id) initWithIngredient:(IngredientItem *)ingredient withDisplayString:(NSString *)displayString;

@property (readonly) IngredientItem *ingredient;
@property (readonly) NSString *displayString;

@end
