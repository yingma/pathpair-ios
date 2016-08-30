//
//  FacebookAuthViewController.m
//  SocialTracker
//
//  Created by Admin on 6/3/16.
//  Copyright © 2016 Flash Software Solution Inc. All rights reserved.
//

#import "FacebookAuthViewController.h"


NSString *kFacebookErrorDomain = @"FacebookERROR";
NSString *kFacebookDeniedByUser = @"the+user+denied+your+request";


@interface FacebookAuthViewController ()

@property(nonatomic, copy) FacebookAuthCodeSuccessCallback successCallback;
@property(nonatomic, copy) FacebookAuthCodeCancelCallback cancelCallback;
@property(nonatomic, copy) FacebookAuthCodeFailureCallback failureCallback;

@property (strong, nonatomic) UIWebView *webView;

@property (strong, nonatomic) UIBarButtonItem *stopLoadingButton;
@property (strong, nonatomic) UIBarButtonItem *reloadButton;
@property (strong, nonatomic) UIBarButtonItem *backButton;
@property (strong, nonatomic) UIBarButtonItem *forwardButton;

@end


@implementation FacebookAuthViewController

BOOL handlingRedirectURL;

- (id)initWithURL:(NSURL *)url
              success:(FacebookAuthCodeSuccessCallback)success
               cancel:(FacebookAuthCodeCancelCallback)cancel
              failure:(FacebookAuthCodeFailureCallback)failure{
    
    self.URL = url;
    if (self) {
        self.successCallback = success;
        self.cancelCallback = cancel;
        self.failureCallback = failure;
        

    }
    
    return self;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View controller lifecycle

- (void)loadView {
    
    self.webView = [[UIWebView alloc] init];
    self.webView.scalesPageToFit = YES;
    self.view = self.webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupToolBarItems];
    [self.navigationController setToolbarHidden:NO];

    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithImage:[self backButtonImage]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(popup)];
    self.navigationItem.leftBarButtonItem = customBarItem;

}

- (void)popup {
    self.cancelCallback();
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.webView.delegate = self;
    if (self.URL) {
        [self load];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [self.webView stopLoading];
    self.webView.delegate = nil;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - URL setter/getter

- (void)setURL:(NSURL *)URL {
    self.URLRequest = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
}

- (NSURL *)URL {
    return self.URLRequest.URL;
}

#pragma mark - Helpers

- (void)load {
    [self.webView loadRequest:self.URLRequest];
    if (self.navigationController.toolbarHidden) {
        [self.navigationController setToolbarHidden:NO animated:YES];
        
    }

}

- (void)clear {
    [self.webView loadHTMLString:@"" baseURL:nil];
    self.title = @"";
}

- (UIImage *)backButtonImage {
    
    static UIImage *image;
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        CGSize size = CGSizeMake(12.0, 21.0);
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        path.lineWidth = 1.5;
        path.lineCapStyle = kCGLineCapButt;
        path.lineJoinStyle = kCGLineJoinMiter;
        [path moveToPoint:CGPointMake(11.0, 1.0)];
        [path addLineToPoint:CGPointMake(1.0, 11.0)];
        [path addLineToPoint:CGPointMake(11.0, 20.0)];
        [path stroke];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    return image;
}

- (UIImage *)forwardButtonImage {
    
    static UIImage *image;
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        UIImage *backButtonImage = [self backButtonImage];
        
        CGSize size = backButtonImage.size;
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGFloat midX = size.width / 2.0;
        CGFloat midY = size.height / 2.0;
        
        CGContextTranslateCTM(context, midX, midY);
        CGContextRotateCTM(context, M_PI);
        
        [backButtonImage drawAtPoint:CGPointMake(-midX, -midY)];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    return image;
}

- (void)setupToolBarItems {
    
    self.stopLoadingButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self.webView action:@selector(stopLoading)];
    self.reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self.webView action:@selector(reload)];
    self.backButton = [[UIBarButtonItem alloc] initWithImage:[self backButtonImage] style:UIBarButtonItemStylePlain target:self.webView action:@selector(goBack)];
    self.forwardButton = [[UIBarButtonItem alloc] initWithImage:[self forwardButtonImage] style:UIBarButtonItemStylePlain target:self.webView action:@selector(goForward)];
    
    self.backButton.enabled = NO;
    self.forwardButton.enabled = NO;
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *space_ = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    space_.width = 60.0;
    
    self.toolbarItems = @[self.stopLoadingButton, space, self.backButton, space_, self.forwardButton];
}

- (void)toggleState {
    
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
    
    NSMutableArray *toolbarItems = [self.toolbarItems mutableCopy];
    
    if (self.webView.loading) {
        toolbarItems[0] = self.stopLoadingButton;
    } else {
        toolbarItems[0] = self.reloadButton;
    }
    
    self.toolbarItems = [toolbarItems copy];
}

- (void)finishLoad {
    
    [self toggleState];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *URLString = [request.URL absoluteString];
    if ([URLString hasPrefix:[[ServiceEngine sharedEngine] appRedirectURL]]) {
        
        if ([URLString rangeOfString:@"error"].location != NSNotFound) {
            BOOL accessDenied = [URLString rangeOfString:kFacebookDeniedByUser].location != NSNotFound;
            if (accessDenied) {
                self.cancelCallback();
            } else {
                NSError *error = [[NSError alloc] initWithDomain:kFacebookErrorDomain code:1 userInfo:[[NSMutableDictionary alloc] init]];
                self.failureCallback(error);
            }
            
        } else {
            
            NSString *delimiter = @"access_token=";
            NSArray *components = [URLString componentsSeparatedByString:delimiter];
            if (components.count > 1) {
                NSString *accessToken = [components lastObject];
                NSLog(@"ACCESS TOKEN = %@",accessToken);
                if ([accessToken hasSuffix:@"#_=_"])
                    accessToken = [accessToken substringToIndex:[accessToken length] - 4];
                [[ServiceEngine sharedEngine] setAccessToken:accessToken];
                
                self.successCallback(accessToken);
                
            }
        }
        
        handlingRedirectURL = YES;
        
        return NO;
    }
    
    return YES;
    
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    // Turn off network activity indicator upon failure to load web view
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [self finishLoad];
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.URL = self.webView.request.URL;
    
    if (!handlingRedirectURL)
        self.failureCallback(error);
    

}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    // Turn off network activity indicator upon finishing web view load
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [self finishLoad];
    
}


@end

