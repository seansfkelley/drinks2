//
//  RecipeItem.h
//  drinks
//
//  Created by Sean Kelley on 11/29/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecipeItem : NSObject

- (id)initWithName:(NSString*)name withMeasuredIngredients:(NSArray*)ingredients;

@property (readonly) NSString *name;
@property (readonly) NSArray *measuredIngredients;

@end
