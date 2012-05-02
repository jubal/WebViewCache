//
//  JHViewController.h
//  WebCache
//
//  Created by Jubal Hoo on 27/4/12.
//  Copyright (c) 2012 MarsLight Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JHViewController : UIViewController<UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIButton *forwardButton;

- (IBAction)goBackWeb:(id)sender;
- (IBAction)goForwardWeb:(id)sender;

@end
