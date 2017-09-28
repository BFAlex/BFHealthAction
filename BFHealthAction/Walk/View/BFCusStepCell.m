//
//  BFCusStepCell.m
//  BFHealthAction
//
//  Created by Readboy_BFAlex on 2017/9/27.
//  Copyright © 2017年 Readboy_BFAlex. All rights reserved.
//

#import "BFCusStepCell.h"
#import <Foundation/Foundation.h>

@interface BFCusStepCell ()
@property (weak, nonatomic) IBOutlet UILabel *targetStepLabel;
@property (weak, nonatomic) IBOutlet UILabel *lackStepLabel;
@property (weak, nonatomic) IBOutlet UIButton *addStepBtn;

@end

@implementation BFCusStepCell

#pragma mark - Public

- (void)configureCell:(BFCusStepCellModel *)model {
    self.targetStepLabel.text = [NSString stringWithFormat:@"%.f", model.targetNum];
    self.lackStepLabel.text = [NSString stringWithFormat:@"%.f", model.lackNum];
    self.addStepBtn.enabled = (model.lackNum > 0);
    UIColor *btnBGColor = self.addStepBtn.enabled ? [UIColor blueColor] : [UIColor lightGrayColor];
    [self.addStepBtn setBackgroundColor:btnBGColor];
}

#pragma mark - Action

- (IBAction)actionAddToTargetStep:(UIButton *)sender {
    NSLog(@"%s%d", __func__, __LINE__);
//    self.layer.cornerRadius
//    self.layer.borderColor
//    self.layer.borderWidth
    if ([self.delegate respondsToSelector:@selector(cusStepCell:addStepNum:)]) {
        [self.delegate cusStepCell:self addStepNum:[self.lackStepLabel.text intValue]];
    }
}

@end
