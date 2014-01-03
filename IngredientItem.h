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
@property (readonly) BOOL hidden; // Should be hidden in list views.
@property BOOL generic; // Target of another ingredient's generic tag.
@property BOOL selected;

@end
