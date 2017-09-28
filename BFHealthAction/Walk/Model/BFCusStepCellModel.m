//
//  BFCusStepCellModel.m
//  BFHealthAction
//
//  Created by Readboy_BFAlex on 2017/9/27.
//  Copyright © 2017年 Readboy_BFAlex. All rights reserved.
//

#import "BFCusStepCellModel.h"

@implementation BFCusStepCellModel

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.targetNum = [aDecoder decodeDoubleForKey:@"CSCMTargetCount"];
        self.lackNum = [aDecoder decodeDoubleForKey:@"CSCMLackCount"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    double target = self.targetNum > 0 ? self.targetNum : 0;
    double lack = self.lackNum > 0 ? self.lackNum : 0;
    [aCoder encodeDouble:target forKey:@"CSCMTargetCount"];
    [aCoder encodeDouble:lack forKey:@"CSCMLackCount"];
}

@end
