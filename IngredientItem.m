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
@property (readwrite) BOOL hidden;

@end

@implementation IngredientItem

- (id)initWithDisplayName:(NSString *)displayName withTag:(NSString *)tag withGenericTag:(NSString *)genericTag withHiddenFlag:(BOOL)hidden {
    self = [super init];

    if (self) {
        self.displayName = displayName;
        self.tag = tag;
        self.genericTag = genericTag;
        self.hidden = hidden;
        self.selected = false;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    NSString *displayName = [aDecoder decodeObjectForKey:@"displayName"];
    NSString *tag = [aDecoder decodeObjectForKey:@"tag"];
    NSString *genericTag = [aDecoder decodeObjectForKey:@"genericTag"];
    BOOL hidden = [aDecoder decodeBoolForKey:@"hidden"];
    BOOL generic = [aDecoder decodeBoolForKey:@"generic"];
    BOOL selected = [aDecoder decodeBoolForKey:@"selected"];
    
    self = [self initWithDisplayName:displayName withTag:tag withGenericTag:genericTag withHiddenFlag:hidden];
    self.generic = generic;
    self.selected = selected;
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.displayName forKey:@"displayName"];
    [aCoder encodeObject:self.tag forKey:@"tag"];
    [aCoder encodeObject:self.genericTag forKey:@"genericTag"];
    [aCoder encodeBool:self.hidden forKey:@"hidden"];
    [aCoder encodeBool:self.generic forKey:@"generic"];
    [aCoder encodeBool:self.selected forKey:@"selected"];
}

@end
