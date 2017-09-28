//
//  BFHealthManager.m
//  BFHealthAction
//
//  Created by Readboy_BFAlex on 2017/9/12.
//  Copyright © 2017年 Readboy_BFAlex. All rights reserved.
//

#import "BFHealthManager.h"
#import <HealthKit/HealthKit.h>
#import <UIKit/UIKit.h>
#import "BFCusStepCellModel.h"

#define kPredefinedStepKey @"PreSDS"
#define kArchiverFileName    @"BFHealthArchiverFile.archiver"

@interface BFHealthManager ()
@property (nonatomic, strong) HKHealthStore *healthStore;

@end

@implementation BFHealthManager

#pragma mark - Property

- (NSMutableArray *)predefinedStepDataSource {
    if (!_predefinedStepDataSource) {
        [self localLoadData];
        if (!_predefinedStepDataSource) {
            _predefinedStepDataSource = [[NSMutableArray alloc] init];
        }
    }
    
    return _predefinedStepDataSource;
}

#pragma mark - Public

- (instancetype)init {
    self = [super init];
    if (self) {
        self.healthStore = [[HKHealthStore alloc] init];
    }
    
    return self;
}

+ (instancetype)shareHealthManager {
    static BFHealthManager *hm = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        hm = [[BFHealthManager alloc] init];
    });
    
    return hm;
}

- (void)isHealthDataAvailable {
    if ([HKHealthStore isHealthDataAvailable]) {
        HKHealthStore *healthStore = [[HKHealthStore alloc] init];
        NSSet *writeDataTypes = [self dataTypesToWrite];
        NSSet *readDataTypes = [self dataTypesToRead];
        [healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:readDataTypes completion:^(BOOL success, NSError * _Nullable error) {
            if (!success) {
                NSLog(@"未授权访问读/写数据类型\n[error:%@]", error);
                if ([self.delegate respondsToSelector:@selector(accessDataFail:)]) {
                    [self.delegate accessDataFail:error];
                }
                return ;
            }
        }];
    }
}

- (void)getStepsFromHealthKit {
    HKQuantityType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    [self fetchSumofSamplesTodayForType:stepType unit:[HKUnit countUnit] completion:^(double stepCount, NSError * error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"读取到的步数: %.f", stepCount);
            if ([self.delegate respondsToSelector:@selector(didAccessSteps:)]) {
                [self.delegate didAccessSteps:stepCount];
            }
        });
    }];
}

- (void)addStepWithStepNum:(double)stepNum {
    HKQuantitySample *steptCorrelationItem = [self stepCorrelationWithStepNum:stepNum];
    
    [self.healthStore saveObject:steptCorrelationItem withCompletion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                NSLog(@"添加成功");
                // 刷新数据 重新获取步数
                [self getStepsFromHealthKit];
            } else {
                NSLog(@"添加失败\nerror:%@", error);
                if ([self.delegate respondsToSelector:@selector(accessDataFail:)]) {
                    [self.delegate accessDataFail:error];
                }
                return ;
            }
        });
    }];
}

- (void)localSaveData {
    if (!self.predefinedStepDataSource) { return; }
//    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)
    NSString *path = [self localSaveDataPath];
    
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self.predefinedStepDataSource forKey:kPredefinedStepKey];
    [archiver finishEncoding];
    BOOL result = [data writeToFile:path atomically:YES];
    if ([self.delegate respondsToSelector:@selector(localSaveDataResult:)]) {
        [self.delegate localSaveDataResult:result];
    }
}

/**
 从本地解档数据
 */
- (void)localLoadData {
    // 归档
    NSString *path = [self localSaveDataPath];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    self.predefinedStepDataSource = [unarchiver decodeObjectForKey:kPredefinedStepKey];
    [unarchiver finishDecoding];
}

- (NSString *)localSaveDataPath {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    path = [path stringByAppendingPathComponent:kArchiverFileName];
    
    return path;
}

#pragma mark - Private

/**
 设置写入权限
 */
- (NSSet *)dataTypesToWrite {
    HKQuantityType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    return [NSSet setWithObjects:stepType, nil];
}
/**
 设置读取权限
 */
- (NSSet *)dataTypesToRead {
    HKQuantityType *stepType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    return [NSSet setWithObjects:stepType, nil];
}

/**
 读取HealthKit数据
 */
#pragma mark
- (void)fetchSumofSamplesTodayForType:(HKQuantityType *)quantityType unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler {
    NSPredicate *predicate = [self predicateForSamplesToday];
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:quantityType quantitySamplePredicate:predicate options:HKStatisticsOptionCumulativeSum completionHandler:^(HKStatisticsQuery * _Nonnull query, HKStatistics * _Nullable result, NSError * _Nullable error) {
        HKQuantity *sum = [result sumQuantity];
        if (completionHandler) {
            double value = [sum doubleValueForUnit:unit];
            completionHandler(value, error);
        }
    }];
    [self.healthStore executeQuery:query];
}

/**
 NSPredicate数据模型
 */
- (NSPredicate *)predicateForSamplesToday {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSDate *startDate = [calendar startOfDayForDate:now];
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    
    return [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
}

/**
 获取HKQuantitySample数据模型
 */
- (HKQuantitySample *)stepCorrelationWithStepNum:(double)stepNum {
    NSDate *endDate = [NSDate date];
    NSDate *startDate = [NSDate dateWithTimeInterval:-300 sinceDate:endDate];
    
    HKQuantity *stepQuantityConsumed = [HKQuantity quantityWithUnit:[HKUnit countUnit] doubleValue:stepNum];
    HKQuantityType *stepConsumedType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    NSString *strName = [[UIDevice currentDevice] name];
    NSString *strModel = [[UIDevice currentDevice] model];
    NSString *strSysVersion = [[UIDevice currentDevice] systemVersion];
    NSString *localeIdentifier = [[NSLocale currentLocale] localeIdentifier];
    
    HKDevice *device = [[HKDevice alloc] initWithName:strName manufacturer:@"Apple" model:strModel hardwareVersion:strModel firmwareVersion:strModel softwareVersion:strSysVersion localIdentifier:localeIdentifier UDIDeviceIdentifier:localeIdentifier];
    
    HKQuantitySample *stepConsumedSample = [HKQuantitySample quantitySampleWithType:stepConsumedType quantity:stepQuantityConsumed startDate:startDate endDate:endDate device:device metadata:nil];
    
    
    return stepConsumedSample;
}

@end
