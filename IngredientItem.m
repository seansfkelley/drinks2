//
//  IngredientItem.m
//  drinks
//
//  Created by Sean Kelley on 11/28/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import "IngredientItem.h"

@interface IngredientItem ()

@property (readwrite) NSString *displayName;
@property (readwrite) NSString *tag;
@property (readwrite) NSString *genericTag;

@end

@implementation IngredientItem

- (id)initWithDisplayName:(NSString *)displayName withTag:(NSString *)tag {
    return [self initWithDisplayName:displayName withTag:tag withGenericTag:nil];
}

- (id)initWithDisplayName:(NSString *)displayName withTag:(NSString *)tag withGenericTag:(NSString *)genericTag {
    self = [super init];
    
    self.displayName = [displayName copy];
    self.tag = [tag copy];
    self.genericTag = [genericTag copy];
    self.selected = false;
    
    return self;
}

@end
