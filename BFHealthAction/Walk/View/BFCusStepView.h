//
//  BFCusStepView.h
//  BFHealthAction
//
//  Created by Readboy_BFAlex on 2017/9/27.
//  Copyright © 2017年 Readboy_BFAlex. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BFCusStepView;
@protocol BFCusStepViewDelegate <NSObject>

@optional
- (void)view:(BFCusStepView *)stepView addTargetStepCount:(double)count;

@end

@interface BFCusStepView : UIView
@property(nonatomic, strong) id<BFCusStepViewDelegate> delegate;

@end
