//
//  RecipeIndex.h
//  drinks
//
//  Created by Sean Kelley on 11/29/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecipeIndex : NSObject

@property (readonly) int fudgeFactor;
@property (readonly) NSArray *ingredients;
@property (readonly) NSArray *recipes;

+ (RecipeIndex *)instance;

- (void)save;
- (void)load;
- (NSArray *)groupByMissingIngredients:(NSArray *)ingredients;

+ (NSSet *)pluckTags:(NSArray *)ingredients;
+ (NSSet *)pluckGenericTags:(NSArray *)ingredients;

@end
