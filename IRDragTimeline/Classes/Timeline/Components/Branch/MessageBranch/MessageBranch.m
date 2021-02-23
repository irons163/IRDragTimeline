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
//    [self.tableView registerClass:MessageBranchHeaderView.class forHeaderFooterViewReuseIdentifier:[MessageBranchHeaderView identifier]];
    [self.tableView registerNib:[UINib nibWithNibName:[MessageBranchFooterView identifier] bundle:nil] forHeaderFooterViewReuseIdentifier:[MessageBranchFooterView identifier]];
//    [self.tableView registerClass:MessageBranchFooterView.class forHeaderFooterViewReuseIdentifier:[MessageBranchFooterView identifier]];
    self.tableView.dragDelegate = self;
        self.tableView.dropDelegate = self;
        self.tableView.dragInteractionEnabled = YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section != 0){
        return 0;
    }
//    return UITableViewAutomaticDimension;
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
/**
 开始拖拽 添加了 UIDragInteraction 的控件 会调用这个方法，从而获取可供拖拽的 item
 如果返回 nil，则不会发生任何拖拽事件
 */
- (nonnull NSArray<UIDragItem *> *)tableView:(nonnull UITableView *)tableView itemsForBeginningDragSession:(nonnull id<UIDragSession>)session atIndexPath:(nonnull NSIndexPath *)indexPath {
    
//    NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithObject:nil];
    NSItemProvider *itemProvider = [[NSItemProvider alloc] init];
    UIDragItem *item = [[UIDragItem alloc] initWithItemProvider:itemProvider];
    item.localObject = tableView;
//    UIDragItem *item = [[UIDragItem alloc] initWithItemProvider:[[NSItemProvider alloc] init]];
    self.dragIndexPath = indexPath;
    return @[item];
}

- (NSArray<UIDragItem *> *)tableView:(UITableView *)tableView itemsForAddingToDragSession:(id<UIDragSession>)session atIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point {
    
    NSItemProvider *itemProvider = [[NSItemProvider alloc] init];
    UIDragItem *item = [[UIDragItem alloc] initWithItemProvider:itemProvider];
    item.localObject = tableView;
//    NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithObject:[model getIteminSection:indexPath.section]];
//    UIDragItem *item = [[UIDragItem alloc] initWithItemProvider:itemProvider];
//    item.localObject = tableView;
    return @[item];
}

- (nullable UIDragPreviewParameters *)tableView:(UITableView *)tableView dragPreviewParametersForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIDragPreviewParameters *parameters = [[UIDragPreviewParameters alloc] init];
    
    CGRect rect = CGRectMake(0, 0, tableView.bounds.size.width, tableView.rowHeight);
    parameters.visiblePath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:15];
    return parameters;
}

#pragma mark - UITableViewDropDelegate
// 当用户开始初始化 drop 手势的时候会调用该方法
- (void)tableView:(UITableView *)tableView performDropWithCoordinator:(id<UITableViewDropCoordinator>)coordinator {
    NSIndexPath *destinationIndexPath = coordinator.destinationIndexPath;
    
    // 如果开始拖拽的 indexPath 和 要释放的目标 indexPath 一致，就不做处理
    if (self.dragIndexPath.section == destinationIndexPath.section && self.dragIndexPath.row == destinationIndexPath.row) {
        return;
    }
    
    UIDragItem *item = ((id<UITableViewDropItem>)coordinator.items[0]).dragItem;
    if (item.localObject != tableView) {
        return;
    }
    
    [tableView performBatchUpdates:^{
        // 目标 cell 换位置
//        id obj = self.dataSource[self.dragIndexPath.row];
        NSMutableArray *a = [NSMutableArray arrayWithArray:self.session.logs];
        id log = [a objectAtIndex:self.dragIndexPath.section];
        [a removeObjectAtIndex:self.dragIndexPath.section];
        [a insertObject:log atIndex:destinationIndexPath.section];
        [self.session setValue:a forKey:@"logs"];
        
        id obj = [model getIteminSection:self.dragIndexPath.section];
//        [self.dataSource removeObjectAtIndex:self.dragIndexPath.row];
        [model removeItemAtIndex:self.dragIndexPath.section];
//        [self.dataSource insertObject:obj atIndex:destinationIndexPath.row];
        [model addItem:obj AtIndex:destinationIndexPath.section];
//        [tableView deleteRowsAtIndexPaths:@[self.dragIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//        [tableView insertRowsAtIndexPaths:@[destinationIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//        [tableView insertSections:[NSIndexSet indexSetWithIndex:destinationIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
//        [tableView deleteSections:[NSIndexSet indexSetWithIndex:self.dragIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
//        NSMutableIndexSet *mutableIndexSet = [[NSMutableIndexSet alloc] init];
//        [mutableIndexSet addIndex:destinationIndexPath.section];
//        [mutableIndexSet addIndex:self.dragIndexPath.section];
        NSInteger biggerIndex = MAX(self.dragIndexPath.section, destinationIndexPath.section);
        NSInteger smallerIndex = MIN(self.dragIndexPath.section, destinationIndexPath.section);
        NSIndexSet *set = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(smallerIndex, biggerIndex - smallerIndex + 1)];
        [tableView reloadSections:set withRowAnimation:UITableViewRowAnimationFade];
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [tableView performBatchUpdates:^{
//                [tableView insertSections:[NSIndexSet indexSetWithIndex:destinationIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
//            } completion:^(BOOL finished) {
//
//            }];
//        });
        
        
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

// 该方法是提供释放方案的方法，虽然是optional，但是最好实现
// 当 跟踪 drop 行为在 tableView 空间坐标区域内部时会频繁调用
// 当drop手势在某个section末端的时候，传递的目标索引路径还不存在（此时 indexPath 等于 该 section 的行数），这时候会追加到该section 的末尾
// 在某些情况下，目标索引路径可能为空（比如拖到一个没有cell的空白区域）
// 请注意，在某些情况下，你的建议可能不被系统所允许，此时系统将执行不同的建议
// 你可以通过 -[session locationInView:] 做你自己的命中测试
- (UITableViewDropProposal *)tableView:(UITableView *)tableView dropSessionDidUpdate:(id<UIDropSession>)session withDestinationIndexPath:(nullable NSIndexPath *)destinationIndexPath {
    
    /**
     // TableView江湖接受drop，但是具体的位置还要稍后才能确定T
     // 不会打开一个缺口，也许你可以提供一些视觉上的处理来给用户传达这一信息
     UITableViewDropIntentUnspecified,
     
     // drop 将会插入到目标索引路径
     // 将会打开一个缺口，模拟最后释放后的布局
     UITableViewDropIntentInsertAtDestinationIndexPath,
     
     drop 将会释放在目标索引路径，比如该cell是一个容器（集合），此时不会像 👆 那个属性一样打开缺口，但是该条目标索引对应的cell会高亮显示
     UITableViewDropIntentInsertIntoDestinationIndexPath,
     
     tableView 会根据dro 手势的位置在 .insertAtDestinationIndexPath 和 .insertIntoDestinationIndexPath 自动选择，
     UITableViewDropIntentAutomatic
     */
    UITableViewDropProposal *dropProposal;
    // 如果是另外一个app，localDragSession为nil，此时就要执行copy，通过这个属性判断是否是在当前app中释放，当然只有 iPad 才需要这个适配
    if (session.localDragSession) {
        dropProposal = [[UITableViewDropProposal alloc] initWithDropOperation:UIDropOperationMove intent:UITableViewDropIntentInsertAtDestinationIndexPath];
    } else {
        dropProposal = [[UITableViewDropProposal alloc] initWithDropOperation:UIDropOperationCopy intent:UITableViewDropIntentInsertAtDestinationIndexPath];
    }
    
    return dropProposal;
}

@end
