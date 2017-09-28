//
//  BFHealthManager.h
//  BFHealthAction
//
//  Created by Readboy_BFAlex on 2017/9/12.
//  Copyright © 2017年 Readboy_BFAlex. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BFHealthManagerDelegate <NSObject>

@optional
- (void)didAccessSteps:(double)stepCount;
- (void)accessDataFail:(NSError *)error;
// 本地保存数据结果
- (void)localSaveDataResult:(BOOL)success;

@end

@interface BFHealthManager : NSObject

@property (nonatomic, strong) id<BFHealthManagerDelegate> delegate;
// predefinedStepDataSource保存对象是BFCusStepCellModel
@property (nonatomic, strong) NSMutableArray *predefinedStepDataSource;

+ (instancetype)shareHealthManager;
/**
 获取健康权限
 */
- (void)isHealthDataAvailable;
/**
 获取步数
 */
- (void)getStepsFromHealthKit;
/**
 添加步数
 */
- (void)addStepWithStepNum:(double)stepNum;

/**
 本地保存数据
 */
- (void)localSaveData;

@end
