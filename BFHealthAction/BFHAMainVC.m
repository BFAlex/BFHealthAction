//
//  BFHAMainVC.m
//  BFHealthAction
//
//  Created by Readboy_BFAlex on 2017/9/12.
//  Copyright © 2017年 Readboy_BFAlex. All rights reserved.
//

#import "BFHAMainVC.h"
#import "BFHealthManager.h"

@interface BFHAMainVC () <BFHealthManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *showStepLabel;
@property (weak, nonatomic) IBOutlet UITextField *addStepTF;
@property (weak, nonatomic) IBOutlet UIView *addStepTFContainer;
@property (weak, nonatomic) IBOutlet UIButton *addStepBtn;

@property (nonatomic, assign) double stepCount;

@end

@implementation BFHAMainVC

#pragma mark - Propery

- (void)setStepCount:(double)stepCount {
    _stepCount = stepCount;
    self.showStepLabel.text = [NSString stringWithFormat:@"%.f", _stepCount];
    
    if (self.addStepTF.text.length > 0) {
        self.addStepTF.text = @"";

        [[[UIAlertView alloc] initWithTitle:@"恭喜" message:@"成功添加数据" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
    }
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadHealthData];
}

#pragma mark - Private

- (void)setupView {
    // 设置步数输入框圆角
    self.addStepTFContainer.layer.borderWidth = 1.0;
    self.addStepTFContainer.layer.borderColor = [UIColor blackColor].CGColor;
    self.addStepTFContainer.layer.cornerRadius = self.addStepTFContainer.bounds.size.height/2;
    
    // 设置步数添加按钮圆角
    self.addStepBtn.layer.borderWidth = 1.0;
    self.addStepBtn.layer.borderColor = [UIColor clearColor].CGColor;
    self.addStepBtn.layer.cornerRadius = self.addStepBtn.bounds.size.height/2;
    
    // 增加手势事件
    UITapGestureRecognizer *tapBaseView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnBaseView)];
    [self.view addGestureRecognizer:tapBaseView];
    
    // 设置代理
    [BFHealthManager shareHealthManager].delegate = self;
}

- (void)tapOnBaseView {
    [self.view endEditing:YES];
}

- (void)loadHealthData {
    [[BFHealthManager shareHealthManager] getStepsFromHealthKit];
}

- (void)addHealthData {
    double value = [self.addStepTF.text doubleValue];
    if (value > 20000) {
        [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"每次添加步数大于2w很容易被其他软件视为作弊的哦" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
        return;
    }
    
    [[BFHealthManager shareHealthManager] addStepWithStepNum:value];
}

#pragma mark - Action

- (IBAction)actionAddStepCountBtn:(UIButton *)sender {
    [self.addStepTF endEditing:YES];
    [self performSelector:@selector(addHealthData) withObject:nil afterDelay:0.5];
}

#pragma mark - Delegate

- (void)didAccessSteps:(double)stepCount {
    self.stepCount = stepCount;
}

- (void)accessDataFail:(NSError *)error {
    NSString *errStr = [NSString stringWithFormat:@"error%@", error];
    [[[UIAlertView alloc] initWithTitle:@"操作失败" message:errStr delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
}

@end
