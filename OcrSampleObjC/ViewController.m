//
//  ViewController.m
//  OcrSampleObjC
//
//  Created by Alchera on 2023/03/15.
//

#import "ViewController.h"
#import "WebViewController.h"
#import "OcrType.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)ocrButtonPressed:(UIButton *)sender {
    WebViewController *webVC = [self.storyboard instantiateViewControllerWithIdentifier:@"webView"];
    if (webVC == nil) return;
    
    webVC.ocrType = (OcrType)sender.tag;
    [self.navigationController pushViewController:webVC animated:YES];
}

@end
