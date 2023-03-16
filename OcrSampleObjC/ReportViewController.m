//
//  ReportViewController.m
//  OcrSampleObjC
//
//  Created by Alchera on 2023/03/15.
//

#import "ReportViewController.h"
#import "OcrResponse.h"

@interface ReportViewController ()

@property NSString *NOTAVAILABLE;
@property UIColor *alcheraColor;

@end

@implementation ReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"OCR Report";
    self.NOTAVAILABLE = @"N/A";
    self.alcheraColor = [UIColor colorNamed:@"alcheraColor"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidLayoutSubviews {
    self.txtEvent.layer.borderWidth = 1;
    self.txtEvent.layer.borderColor = [self.alcheraColor CGColor];
    self.txtEvent.text = [NSString stringWithFormat:@"result: %@", self.result];
    
    if (self.responseJson != nil) {
        self.txtDetail.text = [self prettyPrintedJson:self.responseJson];
        self.txtDetail.layer.borderWidth = 1;
        self.txtDetail.layer.borderColor = [self.alcheraColor CGColor];
    }
    self.lblOcrType.text = [self ocrTypeToString];
    
    [self drawResponse];
}

/* 완료 버튼 클릭 */
- (IBAction)doneButtonPressed:(UIBarButtonItem *)sender {
    [self.navigationController popToRootViewControllerAnimated:NO];
}

/* KYC 응답 Message 결과에 따라 표시 */
- (void)drawResponse {
    if (self.responseJson == nil) return;
    OcrResponse *response = [OcrResponse parsingJson:self.responseJson];
    if (response == nil) return;
    Review_result *detail = response.review_result;
    if (detail == nil) return;
    
    self.imgIdMasking.image = [UIImage imageWithData:detail.ocr_masking_image];
    self.imgIdOrigin.image = [UIImage imageWithData:detail.ocr_origin_image];
}

/* 줄간격 적용된 JSON */
- (NSString *)prettyPrintedJson:(NSString *)jsonString {
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    
    if (jsonData != nil) {
        id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        if (error == nil) {
            NSData *prettyData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:&error];
            if (error == nil) {
                NSString *prettyString = [[NSString alloc] initWithData:prettyData encoding:NSUTF8StringEncoding];
                return prettyString;
            } else {
                NSLog(@"Json 데이터 변환에 실패했습니다. Error: %@", error.localizedDescription);
            }
        } else {
            NSLog(@"Json 데이터 변환에 실패했습니다. Error: %@", error.localizedDescription);
        }
    }
    
    return jsonString;
}

/* OCR 종류를 NSString으로 변환 */
- (NSString *)ocrTypeToString {
    switch (self.ocrType) {
        case idcard:    return @"주민등록증/운전면허증";
        case passport:  return @"국내여권/해외여권";
        case alien:     return @"외국인등록증";
        case credit:    return @"신용카드";
    }
}

@end
