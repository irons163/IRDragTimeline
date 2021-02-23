//
//  IRDragTableViewController.m
//  IRDragTimeline
//
//  Created by Phil on 2020/9/8.
//  Copyright © 2020 Phil. All rights reserved.
//

#import "IRDragTableViewController.h"
#import "IRDragTableViewCell.h"

@interface IRDragTableViewController () <UITableViewDelegate, UITableViewDataSource, UITableViewDragDelegate, UITableViewDropDelegate, MonitorClientsDetailTimelineTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;


@property NSDictionary *clientJourneyData;

@end

@implementation IRDragTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
}

#pragma mark - Private
- (void)setupView {
    [_tableView registerNib:[UINib nibWithNibName:IRDragTableViewCell.identifier bundle:nil] forCellReuseIdentifier:IRDragTableViewCell.identifier];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorInset = UIEdgeInsetsZero;
    [self.view addSubview:_tableView];
}

- (void)showLoading:(BOOL)isShow
{
    dispatch_block_t block = ^{
        if (isShow) {
            self.view.userInteractionEnabled = NO;
            [self.loadingView startAnimating];
        }else{
            self.view.userInteractionEnabled = YES;
            [self.loadingView stopAnimating];
        }
    };
    
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

#pragma mark - setters && getters

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = _clientJourneyData.allValues;
    }
    return _dataSource;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IRDragTableViewCell *cell = (IRDragTableViewCell *)[tableView dequeueReusableCellWithIdentifier:IRDragTableViewCell.identifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.delegate = self;
    cell.clientJourneyData = _clientJourneyData;
    [cell layoutIfNeeded];
    
    return cell;
}

- (void)willUpdate:(NSNumber *)pos {
    [self showLoading:YES];
}

- (void)didUpdate:(NSNumber *)pos {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_tableView performBatchUpdates:^{
            
        } completion:^(BOOL finished) {
            [self showLoading:NO];
        }];
    });
}

@end
