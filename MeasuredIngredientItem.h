//
//  MeasuredIngredientItem.h
//  drinks
//
//  Created by Sean Kelley on 11/29/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import "IngredientItem.h"

@interface MeasuredIngredientItem : NSObject

- (id) initWithIngredientTag:(NSString *)ingredientTag withDisplayString:(NSString *)displayString;

@property (readonly) NSString *ingredientTag;
@property (readonly) NSString *displayString;

@end
