//
//  BFHAMainVC.m
//  BFHealthAction
//
//  Created by Readboy_BFAlex on 2017/9/12.
//  Copyright © 2017年 Readboy_BFAlex. All rights reserved.
//

#import "BFHAMainVC.h"
#import "BFHealthManager.h"
#import "BFCusStepCell.h"
#import "BFCusStepView.h"

@interface BFHAMainVC () <BFHealthManagerDelegate, UITableViewDelegate, UITableViewDataSource, BFCusStepCellDelegate, BFCusStepViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *showStepLabel;
@property (weak, nonatomic) IBOutlet UITextField *addStepTF;
@property (weak, nonatomic) IBOutlet UIView *addStepTFContainer;
@property (weak, nonatomic) IBOutlet UIButton *addStepBtn;
@property (weak, nonatomic) IBOutlet UIButton *cusStepBtn;
@property (weak, nonatomic) IBOutlet UITableView *cusStepTableView;

@property (nonatomic, strong) BFHealthManager *healthManager;

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
    
    // 刷新列表
    [self.cusStepTableView reloadData];
}

- (BFHealthManager *)healthManager {
    if (!_healthManager) {
        _healthManager = [BFHealthManager shareHealthManager];
    }
    
    return _healthManager;
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
    
    // 自定义目标步数
    [self setupCustomStepTableView];
}

- (void)setupCustomStepTableView {
    self.cusStepTableView.delegate = self;
    self.cusStepTableView.dataSource = self;
}

- (void)tapOnBaseView {
    [self.view endEditing:YES];
}

- (void)loadHealthData {
    [[BFHealthManager shareHealthManager] getStepsFromHealthKit];
}

- (void)addHealthData {
    double value = [self.addStepTF.text doubleValue];
//    if (value > 20000) {
//        [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"每次添加步数大于2w很容易被其他软件视为作弊的哦" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
//        return;
//    }
    
    [self addStepNum:value];
}

- (void)addStepNum:(double)num {
//    [[BFHealthManager shareHealthManager] addStepWithStepNum:num];
    [self.healthManager addStepWithStepNum:num];
}

- (BFCusStepCellModel *)cellModelFromData:(double)steps {
    
    BFCusStepCellModel *model = [[BFCusStepCellModel alloc] init];
    model.targetNum = steps;
    
//    double curNum = [self.showStepLabel.text doubleValue];
//    double lackNum = steps - curNum;
//    model.lackNum = lackNum >= 0 ? lackNum : 0;
    [self updateCellModel:model];
    
    return model;
}

/**
 刷新预定义步数与实际步数的差距信息
 */
- (void)updateCellModel:(BFCusStepCellModel *)model {
    double curNum = [self.showStepLabel.text doubleValue];
    double lackNum = model.targetNum - curNum;
    model.lackNum = lackNum >= 0 ? lackNum : 0;
}

- (void)addNewCustomStepItem:(BFCusStepCellModel *)newModel {
//    [self.healthManager.predefinedStepDataSource addObject:[self cellModelFromData:count]];
    for (int i = 0; i < self.healthManager.predefinedStepDataSource.count; i ++) {
        BFCusStepCellModel *model = self.healthManager.predefinedStepDataSource[i];
        if (newModel.targetNum < model.targetNum) {
            [self.healthManager.predefinedStepDataSource insertObject:newModel atIndex:i];
            return;
        }
    }
    [self.healthManager.predefinedStepDataSource addObject:newModel];
}

#pragma mark - Action

- (IBAction)actionAddStepCountBtn:(UIButton *)sender {
    [self.addStepTF endEditing:YES];
    [self performSelector:@selector(addHealthData) withObject:nil afterDelay:0.5];
}
- (IBAction)actionCustomTargetStepCount:(UIButton *)sender {
    BFCusStepView *stepView = [[[NSBundle mainBundle] loadNibNamed:@"BFCusStepView" owner:nil options:nil] lastObject];
    stepView.delegate = self;
    [self.view addSubview:stepView];
    
    [self.view endEditing:YES];
}

#pragma mark - Delegate

- (void)didAccessSteps:(double)stepCount {
    self.stepCount = stepCount;
}

- (void)accessDataFail:(NSError *)error {
    NSString *errStr = [NSString stringWithFormat:@"error%@", error];
    [[[UIAlertView alloc] initWithTitle:@"操作失败" message:errStr delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
}

- (void)localSaveDataResult:(BOOL)success {
    if (!success) {
        [[[UIAlertView alloc] initWithTitle:@"操作错误" message:@"数据本地保存失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
    }
}

#pragma mark TableView
// DataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSLog(@"StepDataSource.count:%lu", (unsigned long)self.healthManager.predefinedStepDataSource.count);
    self.cusStepTableView.hidden = (self.healthManager.predefinedStepDataSource.count <= 0);
    return self.healthManager.predefinedStepDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BFCusStepCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BFCusStepCellID"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"BFCusStepCell" owner:nil options:nil] lastObject];
    }
    cell.delegate = self;
    
    BFCusStepCellModel *cellModel = self.healthManager.predefinedStepDataSource[indexPath.row];
    [self updateCellModel:cellModel];
    [cell configureCell:cellModel];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.healthManager.predefinedStepDataSource removeObjectAtIndex:indexPath.row];
        [self.cusStepTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.healthManager localSaveData];
    }
}

// BFCusStepCell Delegate
- (void)cusStepCell:(BFCusStepCell *)cell addStepNum:(double)num {
    NSLog(@"%s%d", __func__, __LINE__);
    [self addStepNum:num];
}
// BFCusStepView Delegate
- (void)view:(BFCusStepView *)stepView addTargetStepCount:(double)count {
    NSLog(@"%s%d", __func__, __LINE__);
    // 增加目标步数预设
//    [self.healthManager.predefinedStepDataSource addObject:[self cellModelFromData:count]];
    [self addNewCustomStepItem:[self cellModelFromData:count]];
    [self.healthManager localSaveData];
    [self.cusStepTableView reloadData];
}

@end
