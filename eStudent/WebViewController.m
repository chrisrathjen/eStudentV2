//
//  ViewController.m
//  eStudent
//
//  Created by Christian Rathjen on 09.12.12.
//  Copyright (c) 2012 eStudent. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadIndicator;

@end

@implementation WebViewController
@synthesize url;
- (void)viewWillAppear:(BOOL)animated
{
    NSURLRequest *aRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [self.webView loadRequest:aRequest];
}

- (IBAction)refreshButtonClicked:(id)sender {
    
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.loadIndicator.hidden = NO;
    [self.loadIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.loadIndicator.hidden = YES;
    [self.loadIndicator stopAnimating];
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [self setLoadIndicator:nil];
    [super viewDidUnload];
}
@end
