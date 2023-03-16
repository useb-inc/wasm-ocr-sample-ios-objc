//
//  ReportViewController.h
//  OcrSampleObjC
//
//  Created by Alchera on 2023/03/15.
//

#import <UIKit/UIKit.h>
#import "OcrType.h"

NS_ASSUME_NONNULL_BEGIN

@interface ReportViewController : UIViewController

@property NSString *result;
@property NSString *responseJson;
@property OcrType ocrType;

@property (weak, nonatomic) IBOutlet UITextView *txtEvent;
@property (weak, nonatomic) IBOutlet UITextView *txtDetail;

@property (weak, nonatomic) IBOutlet UILabel *lblOcrType;
@property (weak, nonatomic) IBOutlet UIImageView *imgIdMasking;
@property (weak, nonatomic) IBOutlet UIImageView *imgIdOrigin;

@end

NS_ASSUME_NONNULL_END
