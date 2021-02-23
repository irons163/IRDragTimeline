//
//  IRDragTableViewCell.m
//  IRExtanderTableView
//
//  Created by Phil on 2020/3/30.
//  Copyright © 2020 irons163. All rights reserved.
//

#import "IRDragTableViewCell.h"
#import "TimelineManager.h"

@interface IRDragTableViewCell ()<BranchDelegate>{
    Branch *branch;
}

@end

@implementation IRDragTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.timelineTableView.translatesAutoresizingMaskIntoConstraints = NO;
    _timelineTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
}

- (void)setClientJourneyData:(NSDictionary *)clientJourneyData {
    _clientJourneyData = clientJourneyData;
    
    branch = [[TimelineManager sharedInstance] branchFromClientJourneyData:_clientJourneyData];
    branch.tableView = self.timelineTableView;
    branch.delegate = self;
    
    [self.timelineTableView reloadDataWithCompletion:^{
        [self.delegate didUpdate:nil];
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (NSString*)identifier{
    return NSStringFromClass([self class]);
}

#pragma mark - BranchDelegate
- (void)willUpdate:(NSNumber *)pos {
    [self.delegate willUpdate:pos];
}

- (void)didUpdate:(NSNumber *)pos {
    [self layoutIfNeeded];
    
    [self.delegate didUpdate:pos];
}

@end
