//
//  BFCusStepCell.h
//  BFHealthAction
//
//  Created by Readboy_BFAlex on 2017/9/27.
//  Copyright © 2017年 Readboy_BFAlex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BFCusStepCellModel.h"

//@protocol BFCusStepCellDelegate <NSObject>
//
//@optional
//
//@end

@class BFCusStepCell;
@protocol BFCusStepCellDelegate <NSObject>

@optional
- (void)cusStepCell:(BFCusStepCell *)cell addStepNum:(double)num;

@end

@interface BFCusStepCell : UITableViewCell
@property(nonatomic) id<BFCusStepCellDelegate> delegate;

- (void)configureCell:(BFCusStepCellModel *)model;

@end
