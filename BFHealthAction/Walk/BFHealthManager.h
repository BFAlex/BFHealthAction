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

@end

@interface BFHealthManager : NSObject

@property (nonatomic, strong) id<BFHealthManagerDelegate> delegate;

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

@end
