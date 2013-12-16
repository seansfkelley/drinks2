//
//  SortedTableSectionManager.h
//  drinks
//
//  Created by Sean Kelley on 12/16/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SortedTableSectionManager : NSObject

- (id)initWithArray:(NSArray *)array sortedByProperty:(NSString *)property;

@property (readonly) NSArray *sorted;

@end
