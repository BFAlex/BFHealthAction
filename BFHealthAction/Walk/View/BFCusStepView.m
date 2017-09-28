//
//  BFCusStepView.m
//  BFHealthAction
//
//  Created by Readboy_BFAlex on 2017/9/27.
//  Copyright © 2017年 Readboy_BFAlex. All rights reserved.
//

#import "BFCusStepView.h"

@interface BFCusStepView()
@property (weak, nonatomic) IBOutlet UITextField *targetCountTF;

@end

@implementation BFCusStepView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.frame = [UIScreen mainScreen].bounds;
    
    // 添加点击事件
    UITapGestureRecognizer *tapBaseView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnBaseView:)];
    [self addGestureRecognizer:tapBaseView];
}

#pragma mark _ Private

- (void)tapOnBaseView:(UIGestureRecognizer *)gesture {
    [self endEditing:YES];
}

#pragma mark - Action

- (IBAction)actionAddStepCount:(UIButton *)sender {
    // 文本为nil
    if (self.targetCountTF.text.length <= 0) { return; }
    // 输入步数<1
    double count = [self.targetCountTF.text doubleValue];
    if (count <= 0) { return; }
    
    if ([self.delegate respondsToSelector:@selector(view:addTargetStepCount:)]) {
        [self.delegate view:self addTargetStepCount:count];
    }
    
    [self removeFromSuperview];
}

- (IBAction)actionCancel:(UIButton *)sender {
    [self removeFromSuperview];
}

@end
