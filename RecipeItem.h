//
//  RecipeItem.h
//  drinks
//
//  Created by Sean Kelley on 11/29/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SourceItem.h"

@interface RecipeItem : NSObject

- (id)initWithName:(NSString*)name withMeasuredIngredients:(NSArray*)measuredIngredients withInstructions:(NSString *)instructions withNotes:(NSString *)notes withSource:(SourceItem *)source withSourceOverrideUrl:(NSString *)sourceOverrideUrl;

@property (readonly) NSString *name;
@property (readonly) NSString *normalizedName;
@property (readonly) NSArray *measuredIngredients;
@property (readonly) NSArray *rawIngredients;
@property (readonly) NSString *instructions;
@property (readonly) NSString *notes;
@property (readonly) SourceItem *source;
@property (readonly) NSString *sourceOverrideUrl;

@end
