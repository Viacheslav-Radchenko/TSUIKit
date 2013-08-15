//
//  TSTableView.m
//  TSUIKit
//
//  Created by Viacheslav Radchenko on 8/9/13.
//  Copyright (c) 2013 Viacheslav Radchenko. All rights reserved.
//

#import "TSTableView.h"
#import "TSTableViewHeaderPanel.h"
#import "TSTableViewExpandControlPanel.h"
#import "TSTableViewContentHolder.h"
#import "TSTableViewDataSource.h"
#import "TSTableViewAppearanceCoordinator.h"
#import "TSUtils.h"

#define DEF_TABLE_CONTENT_ADDITIONAL_SIZE   32

#ifndef VerboseLog
#define VerboseLog(fmt, ...)  (void)0
#endif

@interface TSTableView () <TSTableViewHeaderPanelDelegate, TSTableViewExpandControlPanelDelegate, TSTableViewContentHolderDelegate, TSTableViewAppearanceCoordinator>

@property (nonatomic, strong) TSTableViewHeaderPanel *tableHeader;
@property (nonatomic, strong) TSTableViewExpandControlPanel *tableControlPanel;
@property (nonatomic, strong) TSTableViewContentHolder *tableContentHolder;

@end

@implementation TSTableView

- (id)init
{
    if(self = [super init])
    {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    VerboseLog();
    self.backgroundColor = [UIColor lightGrayColor];
    
    _contentAdditionalSize = DEF_TABLE_CONTENT_ADDITIONAL_SIZE;
   
    CGRect headerRect = CGRectMake(0, 0, self.frame.size.width, 0);
    _tableHeader = [[TSTableViewHeaderPanel alloc] initWithFrame: headerRect];
    _tableHeader.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _tableHeader.headerDelegate = self;
    [self addSubview:_tableHeader];
    
    CGRect controlPanelRect = CGRectMake(0, 0, 0, self.frame.size.height);
    _tableControlPanel = [[TSTableViewExpandControlPanel alloc] initWithFrame:controlPanelRect];
    _tableControlPanel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _tableControlPanel.controlPanelDelegate = self;
    [self addSubview: _tableControlPanel];
    
    CGRect contentRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _tableContentHolder = [[TSTableViewContentHolder alloc] initWithFrame:contentRect];
    _tableContentHolder.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _tableContentHolder.contentHolderDelegate = self;
    [self addSubview: _tableContentHolder];
}

- (void)setDataSource:(id<TSTableViewDataSource>)dSource
{
    VerboseLog();
    _dataSource = dSource;
    _tableHeader.dataSource = (id)self;
    _tableControlPanel.dataSource = (id)self;
    _tableContentHolder.dataSource = (id)self;
}

#pragma mark - Setters

- (void)setMinColumnWidth:(CGFloat)minColumnWidth
{
    _tableHeader.minColumnWidth = minColumnWidth;
}

- (CGFloat)minColumnWidth
{
    return _tableHeader.minColumnWidth;
}

- (void)setMaxColumnWidth:(CGFloat)maxColumnWidth
{
    _tableHeader.maxColumnWidth = maxColumnWidth;
}

- (CGFloat)maxColumnWidth
{
    return _tableHeader.maxColumnWidth;
}

#pragma mark - Layout

- (void)updateLayout
{
    VerboseLog();
    CGFloat headerHeight = [_tableHeader headerHeight];
    CGFloat controlPanleWidth = [_tableControlPanel expandControlPanelWidth];
    CGFloat tableWidth = [_tableHeader tableTotalWidth];
    CGFloat tableHeight = [_tableControlPanel tableHeight];
    
    CGRect headerRect = CGRectMake(controlPanleWidth, 0, self.frame.size.width - controlPanleWidth, headerHeight);
    _tableHeader.frame =  headerRect;
    _tableHeader.contentSize = CGSizeMake(tableWidth + _contentAdditionalSize , headerHeight);
    
    CGRect controlPanelRect = CGRectMake(0, headerHeight, controlPanleWidth, self.frame.size.height - headerHeight);
    _tableControlPanel.frame = controlPanelRect;
    _tableControlPanel.contentSize = CGSizeMake(controlPanleWidth, tableHeight + _contentAdditionalSize );
    
    CGRect contentRect = CGRectMake(controlPanleWidth, headerHeight, self.frame.size.width - controlPanleWidth, self.frame.size.height - headerHeight);
    _tableContentHolder.frame = contentRect;
    _tableContentHolder.contentSize = CGSizeMake(tableWidth + _contentAdditionalSize, tableHeight + _contentAdditionalSize);
}

- (void)updateContentOffset
{
    VerboseLog();
#warning change on something more smarter
    _tableHeader.contentOffset = CGPointZero;
    _tableControlPanel.contentOffset = CGPointZero;
    _tableContentHolder.contentOffset = CGPointZero;
}

- (void)reloadData
{
    VerboseLog();
    [self.tableHeader reloadData];
    [self.tableControlPanel reloadData];
    [self.tableContentHolder reloadData];
    [self updateLayout];
    [self updateContentOffset];
}

#pragma mark - TSTableViewHeaderPanelDelegate 

- (void)tableViewHeader:(TSTableViewHeaderPanel *)header columnWidthDidChange:(NSInteger)columnIndex oldWidth:(CGFloat)oldWidth newWidth:(CGFloat)newWidth
{
    VerboseLog();
    CGFloat delta = newWidth - oldWidth;
    [_tableContentHolder changeColumnWidthOnAmount:delta forColumn:columnIndex animated:NO];
    [self updateLayout];
}

#pragma mark - TSTableViewExpandControlPanelDelegate

- (void)tableViewSideControlPanel:(TSTableViewExpandControlPanel *)controlPanel expandStateDidChange:(BOOL)expand forRow:(NSIndexPath *)rowPath
{
    VerboseLog();
    [_tableContentHolder changeExpandStateForRow:rowPath toValue:expand animated:YES];
    [self updateLayout];
}

#pragma mark - TSTableViewContentHolderDelegate

- (void)tableViewContentHolder:(TSTableViewContentHolder *)contentHolder contentOffsetDidChange:(CGPoint)contentOffset animated:(BOOL)animated
{
    VerboseLog();
    [_tableControlPanel setContentOffset:CGPointMake(self.tableControlPanel.contentOffset.x, contentOffset.y) animated:animated];
    [_tableHeader setContentOffset:CGPointMake(contentOffset.x, self.tableHeader.contentOffset.y) animated:animated];
}

#pragma mark - Provide DataSource functionality

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    if(!signature)
        signature = [(id)self.dataSource methodSignatureForSelector:aSelector];
    
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if ([self.dataSource respondsToSelector:[anInvocation selector]])
        [anInvocation invokeWithTarget:self.dataSource];
    else
        [super forwardInvocation:anInvocation];
}

#pragma mark - 

- (void)changeExpandStateForRow:(NSIndexPath *)rowPath toValue:(BOOL)expanded animated:(BOOL)animated
{
    VerboseLog();
    [_tableContentHolder changeExpandStateForRow:rowPath toValue:expanded animated:YES];
    [self updateLayout];
}

- (void)expandAllRowsWithAnimation:(BOOL)animated
{
    VerboseLog();
    [_tableControlPanel expandAllRowsWithAnimation:animated];
    [_tableContentHolder  expandAllRowsWithAnimation:animated];
    [self updateLayout];
}

- (void)collapseAllRowsWithAnimation:(BOOL)animated
{
    VerboseLog();
    [_tableControlPanel collapseAllRowsWithAnimation:animated];
    [_tableContentHolder  collapseAllRowsWithAnimation:animated];
    [self updateLayout];
}

#pragma mark - TSTableViewAppearanceCoordinator

/**
 *  @abstract Return YES if subrows of row at specified path should be visible
 */
- (BOOL)isRowExpanded:(NSIndexPath *)indexPath
{
    VerboseLog();
    return [_tableControlPanel isRowExpanded:indexPath];
}

- (CGFloat)controlPanelExpandItemWidth
{
    VerboseLog();
    return 20;
}

/**
 *  @abstract Return total width of all columns
 */
- (CGFloat)tableTotalWidth
{
    VerboseLog();
    return [_tableHeader tableTotalWidth];
}

- (CGFloat)tableTotalHeight
{
    VerboseLog();
    return [_tableControlPanel tableTotalHeight];
}

/**
 *  @abstract Return width for column at specified path
 */
- (CGFloat)widthForColumnAtIndex:(NSInteger)columnIndex
{
    VerboseLog();
    return [_tableHeader widthForColumnAtIndex:columnIndex];
}

- (CGFloat)widthForColumnAtPath:(NSIndexPath *)columnPath
{
    VerboseLog();
    return [_tableHeader widthForColumnAtPath:columnPath];
}

- (CGFloat)defaultWidthForColumnAtPath:(NSIndexPath *)columnPath
{
    VerboseLog();
    return 128;
}

- (TSTableViewCell *)cellViewForRowAtPath:(NSIndexPath *)indexPath cellIndex:(NSInteger)index
{
    return [self.dataSource tableView:self cellViewForRowAtPath:indexPath cellIndex:index];
}

- (TSTableViewHeaderSectionView *)headerSectionViewForColumnAtPath:(NSIndexPath *)indexPath
{
    return [self.dataSource tableView:self headerSectionViewForColumnAtPath:indexPath];
}

@end