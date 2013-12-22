//
//  IngredientItem.h
//  drinks
//
//  Created by Sean Kelley on 11/28/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IngredientItem : NSObject<NSCoding>

- (id)initWithDisplayName:(NSString*)displayName withTag:(NSString*)tag withGenericTag:(NSString*)genericTag withHiddenFlag:(BOOL)hidden;

@property (readonly) NSString *displayName;
@property (readonly) NSString *tag;
@property (readonly) NSString *genericTag;
@property (readonly) BOOL hidden;
@property BOOL selected;

@end
