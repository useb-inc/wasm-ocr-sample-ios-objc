//
//  WebViewController.h
//  OcrSampleObjC
//
//  Created by Alchera on 2023/03/15.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <AVFoundation/AVFoundation.h>
#import "OcrType.h"

NS_ASSUME_NONNULL_BEGIN

@interface WebViewController : UIViewController <WKUIDelegate, WKScriptMessageHandler>

@property WKWebView *webView;
@property OcrType ocrType;

@end

NS_ASSUME_NONNULL_END
