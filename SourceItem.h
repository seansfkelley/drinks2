//
//  SourceItem.h
//  drinks
//
//  Created by Sean Kelley on 12/21/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SourceItem : NSObject

@property (readonly) NSString *name;
@property (readonly) NSString *url;

- (id)initWithName:(NSString *)name withUrl:(NSString *)url;

@end
