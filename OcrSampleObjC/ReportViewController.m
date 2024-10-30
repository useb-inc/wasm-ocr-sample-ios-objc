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
    
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    NSMutableDictionary *mutableJsonDict = [jsonDict mutableCopy];
    
    if (error == nil) {
        NSDictionary *reviewResultDict = [mutableJsonDict valueForKey: @"review_result"];
        NSMutableDictionary *mutableReviewResultDict = [reviewResultDict mutableCopy];
        
        NSString *ocrFaceImgStr = [reviewResultDict valueForKey: @"ocr_face_image"];
        NSString *ocrMaskingImgStr = [reviewResultDict valueForKey: @"ocr_masking_image"];
        NSString *ocrOriginImgStr = [reviewResultDict valueForKey: @"ocr_origin_image"];
        
        [mutableReviewResultDict setValue:[[ocrFaceImgStr substringToIndex:20] stringByAppendingString:@"...생략..."] forKey:@"ocr_face_image"];
        [mutableReviewResultDict setValue:[[ocrMaskingImgStr substringToIndex:20] stringByAppendingString:@"...생략..."] forKey:@"ocr_masking_image"];
        [mutableReviewResultDict setValue:[[ocrOriginImgStr substringToIndex:20] stringByAppendingString:@"...생략..."] forKey:@"ocr_origin_image"];
        [mutableJsonDict setValue:mutableReviewResultDict forKey:@"review_result"];
        
        NSData *prettyData = [NSJSONSerialization dataWithJSONObject:mutableJsonDict options:(NSJSONWritingOptions)(NSJSONWritingPrettyPrinted | NSJSONWritingSortedKeys) error:&error];
        if (error == nil) {
            NSString *prettyString = [[NSString alloc] initWithData:prettyData encoding:NSUTF8StringEncoding];
            return prettyString;
        } else {
            NSLog(@"Json 데이터 변환에 실패했습니다. Error: %@", error.localizedDescription);
        }
    } else {
        NSLog(@"Json 데이터 변환에 실패했습니다. Error: %@", error.localizedDescription);
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
        case idcard_ssa:    return @"주민등록증/운전면허증 + 사본판별";
        case passport_ssa:  return @"국내여권/해외여권 + 사본판별";
        case alien_ssa:     return @"외국인등록증 + 사본판별";
    }
}

@end
