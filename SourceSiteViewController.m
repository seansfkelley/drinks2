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
@property UIActivityIndicatorView *activityIndicator;

@property NSTimer *timer;
@property volatile int loadCount;

@end

@implementation SourceSiteViewController

const NSTimeInterval LOAD_INDICATOR_DELAY = 0.1;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.hidesWhenStopped = YES;
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.loadCount = 0;
    [self.timer invalidate];
    [self updateSpinners];

    self.navigationItem.title = self.recipe.name;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.recipe.sourceUrl]]];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    self.loadCount = 0;
    [self.timer invalidate];
    [self updateSpinners];
}

- (void)updateSpinners {
    if (self.loadCount) { // This is out of sync (and more correct) than self.webView.loading, for whatever reason.
        [self.activityIndicator startAnimating];
//        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    } else {
        [self.activityIndicator stopAnimating];
//        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

- (void)loadTimerFired:(NSTimer *)timer {
    [self updateSpinners];
}

- (void)requestSpinnerUpdate {
    [self.timer invalidate]; // TODO: Do I need to be picky about which thread these timer functions are called on?
    self.timer = [NSTimer scheduledTimerWithTimeInterval:LOAD_INDICATOR_DELAY target:self selector:@selector(loadTimerFired:) userInfo:nil repeats:NO];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.loadCount++;
    [self requestSpinnerUpdate];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.loadCount--;
    [self requestSpinnerUpdate];
}

@end
