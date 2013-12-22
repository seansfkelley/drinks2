//
//  SourceSiteViewController.m
//  drinks
//
//  Created by Sean Kelley on 12/21/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import "SourceSiteViewController.h"

@interface SourceSiteViewController ()

@property IBOutlet UIWebView *webView;

@end

@implementation SourceSiteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = self.recipe.name;
    NSString *url = self.recipe.sourceOverrideUrl;
    if (!url) {
        url = self.recipe.source.url;
    }
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

@end
