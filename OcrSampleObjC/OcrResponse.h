//
//  OcrResponse.h
//  OcrSampleObjC
//
//  Created by Alchera on 2023/03/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Review_result: NSObject
@property (nonatomic, copy) NSData *ocr_masking_image;
@property (nonatomic, copy) NSData *ocr_origin_image;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end

@interface OcrResponse : NSObject
@property (nonatomic, copy) NSString *result;
@property (nonatomic, strong) Review_result *review_result;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
+ (OcrResponse *)parsingJson:(NSString *)jsonString;
@end

NS_ASSUME_NONNULL_END
