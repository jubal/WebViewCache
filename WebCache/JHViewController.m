//
//  JHViewController.m
//  WebCache
//
//  Created by Jubal Hoo on 27/4/12.
//  Copyright (c) 2012 MarsLight Studio. All rights reserved.
//

// Reference: http://www.keakon.net/2011/08/14/为UIWebView实现离线浏览

#import "JHViewController.h"
#import "JHURLCache.h"

@interface JHViewController ()
{
    JHURLCache * urlCache_;
}

- (void) checkIfWebButtonShouldShow;

@end

@implementation JHViewController
@synthesize webView;
@synthesize backButton;
@synthesize forwardButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    urlCache_ = [[JHURLCache alloc] initWithMemoryCapacity:1024 * 1024 diskCapacity:0 diskPath:nil];
    [NSURLCache setSharedURLCache:urlCache_];
    NSURL * url = [NSURL URLWithString:@"http://www.baidu.com/s?wd=360buy&rsv_spt=1&issp=1&rsv_bp=0&ie=utf-8&tn=baiduhome_pg&inputT=2266"];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [self setBackButton:nil];
    [self setForwardButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Private
- (void) checkIfWebButtonShouldShow
{
    //
    // back button
    if ([self.webView canGoBack]) {
        self.backButton.hidden = NO;
    }
    else {
        self.backButton.hidden = YES;
    }
    //
    // forward button
    if ([self.webView canGoForward]) {
        self.forwardButton.hidden = NO;
    }
    else {
        self.forwardButton.hidden = YES;
    }
}// checkIfWebButtonShouldShow

#pragma mark - WebViewDelegate

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    return YES;
}

- (void) webViewDidStartLoad:(UIWebView *)webView
{
    [self checkIfWebButtonShouldShow];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    [self checkIfWebButtonShouldShow];
    [urlCache_ saveInfo];
}

#pragma mark - IBAction

- (IBAction)goBackWeb:(id)sender {
    [self.webView goBack];
}

- (IBAction)goForwardWeb:(id)sender {
    [self.webView goForward];
}

@end
