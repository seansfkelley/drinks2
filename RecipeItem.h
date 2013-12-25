//
//  RecipeItem.h
//  drinks
//
//  Created by Sean Kelley on 11/29/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecipeItem : NSObject<NSCoding>

- (id)initWithName:(NSString*)name withMeasuredIngredients:(NSArray*)measuredIngredients withInstructions:(NSString *)instructions withNotes:(NSString *)notes withSourceName:(NSString *)sourceName withSourceUrl:(NSString *)sourceUrl withIsCustom:(BOOL)isCustom;

@property (readonly) NSString *name;
@property (readonly) NSString *normalizedName;
@property (readonly) NSArray *measuredIngredients;
@property (readonly) NSArray *rawIngredients;
@property (readonly) NSString *instructions;
@property (readonly) NSString *notes;
@property (readonly) NSString *sourceName;
@property (readonly) NSString *sourceUrl;
@property (readonly) BOOL isCustom;

@end
