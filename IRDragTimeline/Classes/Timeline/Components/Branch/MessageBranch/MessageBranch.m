//
//  MessageBranch.m
//  IRExtanderTableView
//
//  Created by Phil on 2020/4/1.
//  Copyright © 2020 irons163. All rights reserved.
//

#import "MessageBranch.h"
#import "MessageBranchHeaderView.h"
#import "MessageBranchFooterView.h"
#import "MessageModel.h"
#import "BranchFooterView.h"
#import "IRScope.h"

@interface MessageBranch()<UITableViewDelegate, UITableViewDragDelegate, UITableViewDropDelegate>

@property NSMutableArray<NSNumber *> *openInformations;
@property (nonatomic, strong) NSIndexPath *dragIndexPath;

@end

@implementation MessageBranch

- (instancetype)init {
    if(self = [super init]){
        children = [NSMutableArray array];
        model = [[MessageModel alloc] initWithTableView:nil];
        [model updateWithData:self.session];
        model.delegate = self;
        self.isOpened = YES;
        _openInformations = [NSMutableArray array];
    }
    
    return self;
}

- (void)setTableView:(BranchTableIView *)tableView {
    [super setTableView:tableView];
    [self.tableView registerNib:[UINib nibWithNibName:[MessageBranchHeaderView identifier] bundle:nil] forHeaderFooterViewReuseIdentifier:[MessageBranchHeaderView identifier]];
    [self.tableView registerNib:[UINib nibWithNibName:[MessageBranchFooterView identifier] bundle:nil] forHeaderFooterViewReuseIdentifier:[MessageBranchFooterView identifier]];
    self.tableView.dragDelegate = self;
        self.tableView.dropDelegate = self;
        self.tableView.dragInteractionEnabled = YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section != 0){
        return 0;
    }
    return 140;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if(section != [model numberOfSectionsInTableView:tableView] - 1){
        return 0;
    }
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if([self tableView:tableView heightForHeaderInSection:section] == 0) {
        return nil;
    }
    
    MessageBranchHeaderView* sectionHeaderView = (MessageBranchHeaderView*)[tableView dequeueReusableHeaderFooterViewWithIdentifier:[MessageBranchHeaderView identifier]];
    
    BOOL isOpened = ![model hiddenRowsinSection:section];
    
    NSString *title = self.session.name;
    
    sectionHeaderView.titleLabel.text = title;
    sectionHeaderView.bandTagLabel.text = self.session.radio;
    sectionHeaderView.iconView.image = self.session.iconImage;
    sectionHeaderView.timeLabel.text = self.session.displayTime;
    sectionHeaderView.apToLabel.text = self.session.apTo;
    sectionHeaderView.ssidLabel.text = self.session.ssid;
    sectionHeaderView.channelLabel.text = [NSString stringWithFormat:@"CH %@",self.session.channel];
    sectionHeaderView.rssi = self.session.rssi;
    sectionHeaderView.logsTitleLabel.text = [NSString stringWithFormat:@"%@ (%ld %@)", self.session.duration, self.session.logs.count, self.session.logs.count > 1 ? @"Events" : @"Event"];
    sectionHeaderView.tag = section;
    sectionHeaderView.arrowImageView.highlighted = ![model hiddenRowsinSection:section];
    sectionHeaderView.buttonClick = ^(UIButton *button) {
        NSInteger count = [self->model numberOfSectionsInTableView:self.tableView];
        NSMutableArray *sections = [NSMutableArray array];
        for (int i = 0; i < count; i++) {
            [sections addObject:@(i)];
        }
        [self performBranchClickAtSections:sections];
    };
    @weakify(sectionHeaderView)
    sectionHeaderView.informationButtonClick = ^(UIButton *button) {
        @strongify(sectionHeaderView)
        if([self->_openInformations containsObject:@(section)])
            [self->_openInformations removeObject:@(section)];
        else
            [self->_openInformations addObject:@(section)];
            BOOL openedInformation = [self->_openInformations containsObject:@(section)];
            sectionHeaderView.openedInformation = openedInformation;
    };
    
    BOOL openedInformation = [self->_openInformations containsObject:@(section)];
    sectionHeaderView.openedInformation = openedInformation;
    
    sectionHeaderView.openedLogs = isOpened;
    sectionHeaderView.themeColor = self.session.color;
    sectionHeaderView.tagColor = self.session.tagColor;
    
    return sectionHeaderView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if([self tableView:tableView heightForFooterInSection:section] == 0) {
        return nil;
    }
    
    if (self.session.leave.length > 0) {
        BranchFooterView* sectionFooterView = (BranchFooterView*)[tableView dequeueReusableHeaderFooterViewWithIdentifier:[BranchFooterView identifier]];
        Session *session = self.session;
        
        sectionFooterView.timeLabel.text = session.displayDisTime;
        sectionFooterView.titleLabel.text = session.reason;
        sectionFooterView.leaveLabel.text = session.leave;

        sectionFooterView.tag = section;

        [self loopUpdate:self];
        return sectionFooterView;
    }
    
    MessageBranchFooterView* sectionFooterView = (MessageBranchFooterView*)[tableView dequeueReusableHeaderFooterViewWithIdentifier:[MessageBranchFooterView identifier]];
    
    if (self.session.disDateSecond == 0) {
        sectionFooterView.viewConstraintHeight.constant = 10;
        sectionFooterView.titleLabel.text = @"";
    } else {
        sectionFooterView.viewConstraintHeight.constant = 60;
        sectionFooterView.titleLabel.text = self.session.reason;
    }
    [sectionFooterView layoutIfNeeded];
    
    sectionFooterView.tag = section;
    
    sectionFooterView.themeColor = self.session.color;
    
    [self loopUpdate:self];
    return sectionFooterView;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView shouldSpringLoadRowAtIndexPath:(NSIndexPath *)indexPath withContext:(id<UISpringLoadedInteractionContext>)context {
    
    return YES;
}

#pragma mark - UITableViewDragDelegate
- (nonnull NSArray<UIDragItem *> *)tableView:(nonnull UITableView *)tableView itemsForBeginningDragSession:(nonnull id<UIDragSession>)session atIndexPath:(nonnull NSIndexPath *)indexPath {
    NSItemProvider *itemProvider = [[NSItemProvider alloc] init];
    UIDragItem *item = [[UIDragItem alloc] initWithItemProvider:itemProvider];
    item.localObject = tableView;
    self.dragIndexPath = indexPath;
    return @[item];
}

- (NSArray<UIDragItem *> *)tableView:(UITableView *)tableView itemsForAddingToDragSession:(id<UIDragSession>)session atIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point {
    
    NSItemProvider *itemProvider = [[NSItemProvider alloc] init];
    UIDragItem *item = [[UIDragItem alloc] initWithItemProvider:itemProvider];
    item.localObject = tableView;
    return @[item];
}

- (nullable UIDragPreviewParameters *)tableView:(UITableView *)tableView dragPreviewParametersForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIDragPreviewParameters *parameters = [[UIDragPreviewParameters alloc] init];
    
    CGRect rect = CGRectMake(0, 0, tableView.bounds.size.width, tableView.rowHeight);
    parameters.visiblePath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:15];
    return parameters;
}

#pragma mark - UITableViewDropDelegate
- (void)tableView:(UITableView *)tableView performDropWithCoordinator:(id<UITableViewDropCoordinator>)coordinator {
    NSIndexPath *destinationIndexPath = coordinator.destinationIndexPath;
    
    if (self.dragIndexPath.section == destinationIndexPath.section && self.dragIndexPath.row == destinationIndexPath.row) {
        return;
    }
    
    UIDragItem *item = ((id<UITableViewDropItem>)coordinator.items[0]).dragItem;
    if (item.localObject != tableView) {
        return;
    }
    
    [tableView performBatchUpdates:^{
    
        NSMutableArray *logs = [NSMutableArray arrayWithArray:self.session.logs];
        id log = [logs objectAtIndex:self.dragIndexPath.section];
        [logs removeObjectAtIndex:self.dragIndexPath.section];
        [logs insertObject:log atIndex:destinationIndexPath.section];
        [self.session setValue:logs forKey:@"logs"];
        
        id obj = [model getIteminSection:self.dragIndexPath.section];
        [model removeItemAtIndex:self.dragIndexPath.section];
        [model addItem:obj AtIndex:destinationIndexPath.section];

        NSInteger biggerIndex = MAX(self.dragIndexPath.section, destinationIndexPath.section);
        NSInteger smallerIndex = MIN(self.dragIndexPath.section, destinationIndexPath.section);
        NSIndexSet *set = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(smallerIndex, biggerIndex - smallerIndex + 1)];
        [tableView reloadSections:set withRowAnimation:UITableViewRowAnimationFade];
        
    } completion:^(BOOL finished) {
        
    }];
}

- (BOOL)tableView:(UITableView *)tableView canHandleDropSession:(id<UIDropSession>)session {
    UIDragItem *item = session.items[0];
    if (item.localObject != tableView) {
        return NO;
    }
    
    return YES;
}

- (UITableViewDropProposal *)tableView:(UITableView *)tableView dropSessionDidUpdate:(id<UIDropSession>)session withDestinationIndexPath:(nullable NSIndexPath *)destinationIndexPath {
    
    UITableViewDropProposal *dropProposal;

    if (session.localDragSession) {
        dropProposal = [[UITableViewDropProposal alloc] initWithDropOperation:UIDropOperationMove intent:UITableViewDropIntentInsertAtDestinationIndexPath];
    } else {
        dropProposal = [[UITableViewDropProposal alloc] initWithDropOperation:UIDropOperationCopy intent:UITableViewDropIntentInsertAtDestinationIndexPath];
    }
    
    return dropProposal;
}

@end
