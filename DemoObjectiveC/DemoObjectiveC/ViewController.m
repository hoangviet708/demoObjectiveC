//
//  ViewController.m
//  DemoObjectiveC
//
//  Created by Hoang Viet on 12/07/2024.
//

#import "ViewController.h"

@interface ViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtDate1;
@property (weak, nonatomic) IBOutlet UITextField *txtDate2;
@property (weak, nonatomic) IBOutlet UITextField *txtDate3;
@property (weak, nonatomic) IBOutlet UITextField *txtDate4;

@property (weak, nonatomic) IBOutlet UIView *contentViewTest;


@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _txtDate1.text = @"20240101";
    _txtDate2.text = @"20250101";
    _txtDate3.text = @"20260101";
    _txtDate4.text = @"20210101";
    _txtDate1.delegate = self;
    _txtDate2.delegate = self;
    _txtDate3.delegate = self;
    _txtDate4.delegate = self;
    
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentViewTest.frame.size.width, self.contentViewTest.frame.size.height)];
    view1.backgroundColor = [UIColor redColor];
    [_contentViewTest addSubview:view1];
    
    UITapGestureRecognizer *tapSubview =
      [[UITapGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(handleSingleTapSubView:)];
    tapSubview.delegate = self;
    [view1 addGestureRecognizer:tapSubview];
    
    UITapGestureRecognizer *singleFingerTap =
      [[UITapGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(handleSingleTap:)];
    singleFingerTap.delegate = self;
    [self.contentViewTest addGestureRecognizer:singleFingerTap];
    
    
/*
    Init View ->
 
    dateOfSigned = @"";
    isClear = false
    isBlankSignature = false

    1. Action clear
      isClear = true
    2. Drawing : isClear = false;
    3. Action Save:
        if (isClear = true) => isBlankSignature = true;
        else -> isBlankSignature = false
    4. Action back
 
    if isBlankSignature -> date = "";
    else
        if isDateString(dateOfSigned) -> date = dateOfSigned
        else date = systemDate
    
*/
 
}

//The event handling method
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    NSLog(@"contentViewTest");
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return true;
}

//The event handling method
- (void)handleSingleTapSubView:(UITapGestureRecognizer *)recognizer
{
    NSLog(@"TapSubView");
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    // Only validate 4 textField
    [self validateSignatureDateInSequence];
}

- (IBAction)actionBtn:(id)sender {
///    2. Validate data
    BOOL result = [self validateSignatureDateInSequence];
    NSLog(@"Result: %s", result ? "1" : "0"); // Output: 1 (true)
}

- (BOOL)isDateString:(NSString *)dateString inFormat:(NSString *)dateFormat {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    NSDate *date = [dateFormatter dateFromString:dateString];
    if (date != nil) {
        NSString *formattedString = [dateFormatter stringFromDate:date];
        return [formattedString isEqualToString:dateString];
    }
    return NO;
}



- (BOOL)validateSignatureDateInSequence {
    if ([_txtDate2.text isEqualToString:@""] && [_txtDate3.text isEqualToString:@""] && [_txtDate4.text isEqualToString:@""]) {
        return true;
    }
    
    ///    1. Check invalid format date in DidEndEditing
    if ((![_txtDate2.text isEqualToString:@""]) && (![self isDateString:_txtDate2.text inFormat:@"yyyyMMdd"])) {
        [self showErrorFormatDateAlertForField:_txtDate2];
        return false;
    }
    
    if ((![_txtDate3.text isEqualToString:@""]) && (![self isDateString:_txtDate3.text inFormat:@"yyyyMMdd"])) {
        [self showErrorFormatDateAlertForField:_txtDate3];
        return false;
    }
    
    if ((![_txtDate4.text isEqualToString:@""]) && (![self isDateString:_txtDate4.text inFormat:@"yyyyMMdd"])) {
        [self showErrorFormatDateAlertForField:_txtDate4];
        return false;
    }
     
    /// 3. Check invalid data date
    NSArray<UITextField *> *textFields = @[_txtDate1, _txtDate2, _txtDate3, _txtDate4];
    NSMutableArray<NSString *> *dateArray = [[NSMutableArray alloc] init];
    NSMutableArray<UITextField *> *validTextFields = [[NSMutableArray alloc] init];

    for (UITextField *textField in textFields) {
        if (![textField.text isEqualToString:@""]) {
            [dateArray addObject:textField.text];
            [validTextFields addObject:textField];
        }
    }
    
    for (NSUInteger i = 1; i < [dateArray count]; i++) {
        if (![self isDateEarlierOrSameAsDate:dateArray[i - 1] withDate:dateArray[i]]) {
            [self showErrorAlertForField:validTextFields[i]];
            return NO;
        }
    }
    return YES;
}

- (BOOL)isDateEarlierOrSameAsDate:(NSString *)date1 withDate:(NSString *)date2 {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    
    NSDate *dateObj1 = [dateFormatter dateFromString:date1];
    NSDate *dateObj2 = [dateFormatter dateFromString:date2];
    
    NSComparisonResult result = [dateObj1 compare:dateObj2];
    // return true if date1 <= date2
    return result != NSOrderedDescending;
}

- (void)showErrorAlertForField:(UITextField *)textField {
    NSString *message = [NSString stringWithFormat:@"Ngày trong trường %@ không đúng thứ tự tăng dần.", textField.placeholder];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Lỗi" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showErrorFormatDateAlertForField:(UITextField *)textField {
    NSString *message = [NSString stringWithFormat:@"Format %@ date sai.", textField.placeholder];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Lỗi" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
@end
