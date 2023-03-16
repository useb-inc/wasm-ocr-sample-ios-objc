//
//  OcrResponse.m
//  OcrSampleObjC
//
//  Created by Alchera on 2023/03/15.
//

#import "OcrResponse.h"

@implementation Review_result
- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        if ([dictionary isKindOfClass:NSDictionary.class]) {
            NSString *ocr_origin_image_string = [dictionary objectForKey:@"ocr_origin_image"];
            if ([ocr_origin_image_string isKindOfClass:NSString.class]) {
                self.ocr_origin_image = [[NSData alloc] initWithBase64EncodedString:ocr_origin_image_string options:kNilOptions];
            }
            
            NSString *ocr_masking_image_string = [dictionary objectForKey:@"ocr_masking_image"];
            if ([ocr_masking_image_string isKindOfClass:NSString.class]) {
                self.ocr_masking_image = [[NSData alloc] initWithBase64EncodedString:ocr_masking_image_string options:kNilOptions];
            }
        }
    }
    return self;
}
@end

@implementation OcrResponse
- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        if ([dictionary isKindOfClass:NSDictionary.class]) {
            self.result = [dictionary objectForKey:@"result"];
            self.review_result = [[Review_result alloc] initWithDictionary:[dictionary objectForKey:@"review_result"]];
        }
    }
    return self;
}

/* Json을 OcrResponse로 변환합니다. */
+ (OcrResponse *)parsingJson:(NSString *)jsonString {
    NSData *uriDecodedData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    
    if (uriDecodedData != nil) {
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:uriDecodedData options:NSJSONReadingMutableContainers error:&error];
        if (error == nil) {
            OcrResponse *response = [[OcrResponse alloc] initWithDictionary:jsonDictionary];
            return response;
        } else {
            NSLog(@"OCR 결과 정보 분석중 오류가 발생했습니다. Error: %@", error.localizedDescription);
        }
    }
    
    return nil;
}
@end
