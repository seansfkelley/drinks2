//
//  IngredientItem.h
//  drinks
//
//  Created by Sean Kelley on 11/28/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IngredientItem : NSObject

- (id)initWithDisplayName:(NSString*)displayName withTag:(NSString*)tag;
- (id)initWithDisplayName:(NSString*)displayName withTag:(NSString*)tag withGenericTag:(NSString*)genericTag;

@property (readonly) NSString *displayName;
@property (readonly) NSString *tag;
@property (readonly) NSString *genericTag;

@property BOOL selected;

@end
