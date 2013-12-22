//
//  SourceSiteViewController.h
//  drinks
//
//  Created by Sean Kelley on 12/21/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecipeItem.h"

@interface SourceSiteViewController : UIViewController<UIWebViewDelegate>

@property RecipeItem *recipe;

@end
