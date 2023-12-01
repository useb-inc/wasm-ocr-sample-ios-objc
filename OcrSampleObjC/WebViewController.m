//
//  WebViewController.m
//  OcrSampleObjC
//
//  Created by Alchera on 2023/03/15.
//

#import "WebViewController.h"
#import "ReportViewController.h"
#import "OcrResponse.h"

@interface WebViewController ()

@property NSString *responseName;
@property NSString *result;
@property NSString *responseJson;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"OCR";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkCameraPermission];
    [self.navigationController setNavigationBarHidden:NO];
}

/* View 불러오기 */
- (void)loadView {
    WKWebViewConfiguration *webConfiguration = [WKWebViewConfiguration new];
    [webConfiguration setAllowsInlineMediaPlayback:YES];
    webConfiguration.preferences.javaScriptEnabled = YES;
    
    // OCR 정보를 담은 postMessage 설정
    NSString *requestData = [self encodedPostMessage];
    if (requestData != nil) {
        NSString *jsScript = [NSString stringWithFormat:@"setTimeout(function() { usebwasmocrreceive('%@'); }, 500);", requestData];
        WKUserScript *userScript = [[WKUserScript alloc] initWithSource:jsScript
                                                          injectionTime: WKUserScriptInjectionTimeAtDocumentEnd
                                                       forMainFrameOnly:YES];
        [webConfiguration.userContentController addUserScript:userScript];
    }
    // 메시지 수신할 핸들러 등록
    // web에서 호출할 펑션이름 webkit.messageHandlers.{AppFunction}.postMessage("원하는 데이터")
    self.responseName = @"usebwasmocr";
    [webConfiguration.userContentController addScriptMessageHandler:self name:self.responseName];
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:webConfiguration];
    [self.webView setUIDelegate:self];
    
#ifdef DEBUG
    self.webView.inspectable = YES;
#endif
    
    self.view = self.webView;
}

/* WebView 불러오기 */
- (void)loadWebView {
    NSURL *url = [NSURL URLWithString:@"https://ocr.useb.co.kr/ocr.html"];
    if (url == nil) return;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [self.webView loadRequest:request];
}

/* OCR 결과 창으로 이동 */
- (void)loadReportView {
    ReportViewController *reportVC = [self.storyboard instantiateViewControllerWithIdentifier:@"reportView"];
    if (reportVC == nil) return;

    reportVC.ocrType = self.ocrType;
    reportVC.result = self.result;
    reportVC.responseJson = self.responseJson;
    [self.navigationController pushViewController:reportVC animated:YES];
}

/* webView Javascript Alert 처리 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }];
    
    [alertController addAction:cancelAction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

/* WebView 메시지 핸들러 */
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if (message.name != self.responseName || message.body == nil) return;

    NSString *decodedMessage = [self decodedPostMessage:message.body];
    if (decodedMessage == nil) {
        NSLog(@"OCR 응답 메시지 분석에 실패했습니다.");
        return;
    }
    OcrResponse *ocrResponse = [OcrResponse parsingJson:decodedMessage];
    if (ocrResponse == nil) {
        NSLog(@"OCR 응답 메시지 변환에 실패했습니다.");
        return;
    }

    self.result = ocrResponse.result;
    if ([ocrResponse.result isEqualToString:@"success"]) {
        NSLog(@"OCR 작업이 성공했습니다.");
        self.responseJson = decodedMessage;
    } else if ([ocrResponse.result isEqualToString:@"failed"]) {
        NSLog(@"OCR 작업이 실패했습니다.");
        self.responseJson = decodedMessage;
    } else {
        NSLog(@"유효하지 않은 결과입니다. %@", ocrResponse.result);
        self.result = nil;
        self.responseJson = nil;
    }
    
    [self loadReportView];

}

/* Camera 권한 체크 */
- (void)checkCameraPermission {
    AVAuthorizationStatus permission = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (permission) {
        case AVAuthorizationStatusAuthorized: {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loadWebView];
            });
            break;
        }
        case AVAuthorizationStatusDenied: {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"카메라 권한 필요"
                                                                           message:@"설정 > 개인 정보 보호 > 카메라에서 권한을 변경하실 수 있습니다."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:okAction];
            [self presentViewController:alert animated:NO completion:nil];
            break;
        }
        case AVAuthorizationStatusNotDetermined: {
            // 권한 요청
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self loadWebView];
                    });
                } else {
                    NSLog(@"권한이 거부되었습니다.");
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
            break;
        }
        default:
            NSLog(@"Permission = %ld", permission);
            break;
    }
}

/* PostMessage로 보낼 OCR 정보를 생성합니다. */
- (nullable NSString *)encodedPostMessage {
    NSDictionary *jsonDictionary = @{
        @"ocrType": [self ocrTypeToString],
        @"settings": @{@"licenseKey": @"FPkTB6QsFFW5YwiqAa2zk5yy0ylLfYSryPM1fnVJKLgWBk6FgEPMBP9RJiCd24ldGurGnkAUPatzrf9Km90ADqjlTF/FHFyculQP21k4pxkfbSRs="}
    };
    
    // JSON -> encodeURIComponent -> Base64Encoding
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingWithoutEscapingSlashes error:&error];
    if (error != nil) {
        NSLog(@"OCR 정보 생성에 실패했습니다. Error: %@", error.localizedDescription);
        return nil;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (jsonString != nil) {
        NSString *uriEncoded = [jsonString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        return [[uriEncoded dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    }
    
    return nil;
}

/* OCR 수행 결과를 분석합니다. */
- (nullable NSString *)decodedPostMessage:(nonnull NSString *)encodedMessage {
    // Base64Decoding -> decodeURIComponent -> JSON
    NSData *base64DecodedData = [[NSData alloc] initWithBase64EncodedString:encodedMessage options:NSDataBase64DecodingIgnoreUnknownCharacters];
    if (base64DecodedData != nil) {
        NSString *base64DecodedString = [[NSString alloc] initWithData:base64DecodedData encoding:NSUTF8StringEncoding];
        if (base64DecodedData != nil) {
            NSString *jsonString = [base64DecodedString stringByRemovingPercentEncoding];
            return jsonString;
        }
    }
    
    return nil;
}

/* OCR 종류를 NSString으로 변환 */
- (NSString *)ocrTypeToString {
    switch (self.ocrType) {
        case idcard:    return @"idcard";
        case passport:  return @"passport";
        case alien:     return @"alien";
        case credit:    return @"credit";
        case idcard_ssa: return @"idcard-ssa";
        case passport_ssa: return @"passport-ssa";
        case alien_ssa: return @"alien-ssa";
    }
}

@end
