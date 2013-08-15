//
//  TSTableViewExpandControlPanel.m
//  TSUIKit
//
//  Created by Viacheslav Radchenko on 8/12/13.
//  Copyright (c) 2013 Viacheslav Radchenko. All rights reserved.
//

#import "TSTableViewExpandControlPanel.h"
#import "TStableViewDataSource.h"
#import "TSTableViewAppearanceCoordinator.h"
#import "TSTableViewExpandRow.h"
#import "TSTableViewExpandRowButton.h"
#import "TSUtils.h"
#import "TSDefines.h"

#ifndef VerboseLog
#define VerboseLog(fmt, ...)  (void)0
#endif

@interface TSTableViewExpandControlPanel ()
{
    NSMutableArray* _rows;
    NSInteger _maxNestingLevel;
    CGFloat _totalWidth;
    CGFloat _totalHeight;
    
    UIColor *_topColor;
    UIColor *_bottomColor;
    UIColor *_topBorderColor;
    UIColor *_bottomBorderColor;
    UIColor *_leftBorderColor;
    UIColor *_rightBorderColor;
}

@end

@implementation TSTableViewExpandControlPanel

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

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    if([view isKindOfClass:[UIButton class]])
    {
        return YES;
    }
    return NO;
}

- (void)initialize
{
    VerboseLog();
    
    self.backgroundColor = [UIColor lightGrayColor];
    self.delaysContentTouches = YES;
    self.canCancelContentTouches = YES;
    self.scrollEnabled = NO;
    
    _rows = [[NSMutableArray alloc] init];
    
    _topColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
    _bottomColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    _topBorderColor = [UIColor whiteColor];
    _bottomBorderColor = [UIColor colorWithWhite:0.7f alpha:1.0f];
    _leftBorderColor = [UIColor whiteColor];
    _rightBorderColor = [UIColor colorWithWhite:0.7f alpha:1.0f];
}

#pragma mark - Draw

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [TSUtils drawLinearGradientInContext:context
                                    rect:self.bounds
                              startColor:_topColor.CGColor
                                endColor:_bottomColor.CGColor];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(self.bounds.size.width - 1, 0)
                      endPoint:CGPointMake(self.bounds.size.width - 1, self.bounds.size.height - 1)
                         color:_rightBorderColor.CGColor
                     lineWidth:0.5];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(0, 0)
                      endPoint:CGPointMake(0, self.bounds.size.height - 1)
                         color:_leftBorderColor.CGColor
                     lineWidth:0.5];
}

#pragma mark - Expand button

- (void)addExpandButtonAtPath:(NSIndexPath *)rowPath expandRowView:(TSTableViewExpandRow *)expandRow
{
    VerboseLog();
    NSInteger numberOfRows = [self.dataSource numberOfRowsAtPath:rowPath];
    if(numberOfRows)
    {
        CGFloat rowHeight = [self.dataSource heightForRowAtPath:rowPath];
        TSTableViewExpandRowButton *expandBtn = [[TSTableViewExpandRowButton alloc] initWithFrame:CGRectMake(0, 0, expandRow.frame.size.width, rowHeight)];
        expandBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [expandBtn addTarget:self action:@selector(expandBtnTouchDown:withEvent:) forControlEvents:UIControlEventTouchDown];
        [expandBtn addTarget:self action:@selector(expandBtnTouchUpInside:withEvent:) forControlEvents:UIControlEventTouchUpInside];
        [expandBtn addTarget:self action:@selector(expandBtnTouchUpOutside:withEvent:) forControlEvents:UIControlEventTouchUpOutside];
        [expandBtn addTarget:self action:@selector(expandBtnTouchUpOutside:withEvent:) forControlEvents:UIControlEventTouchCancel];
        expandBtn.expanded = YES;
        expandBtn.rowPath = rowPath;
        
        expandRow.expandButton = expandBtn;
    }
}

- (void)expandBtnTouchDown:(TSTableViewExpandRowButton *)sender withEvent:(UIEvent *)event
{
    VerboseLog();
    sender.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1];
}

- (void)expandBtnTouchUpOutside:(TSTableViewExpandRowButton *)sender withEvent:(UIEvent *)event
{
    VerboseLog();
    sender.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
}

- (void)expandBtnTouchUpInside:(TSTableViewExpandRowButton *)sender withEvent:(UIEvent *)event
{
    VerboseLog();
    sender.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    [self changeExpandStateForRow:sender.rowPath toValue:!sender.expanded animated:YES];
    if(self.controlPanelDelegate)
    {
        [self.controlPanelDelegate tableViewSideControlPanel:self expandStateDidChange:sender.expanded forRow:sender.rowPath];
    }
}

#pragma mark -

- (void)reloadData
{
    VerboseLog();
    for(TSTableViewExpandRow *row in _rows)
    {
        [row removeFromSuperview];
    }
    [_rows removeAllObjects];
    
    if(self.dataSource)
    {
        _maxNestingLevel = 0;
        _totalWidth = 0;
        _totalHeight = 0;
        [self loadSubrowsForRowAtPath:nil expandRowView:nil totalHeight:&_totalHeight totalWidth:&_totalWidth];
    }
}

- (void)loadSubrowsForRowAtPath:(NSIndexPath *)rowPath expandRowView:(TSTableViewExpandRow *)parentRowView  totalHeight:(CGFloat *)totalHeight totalWidth:(CGFloat *)totalWidth
{
    VerboseLog();
    if(_maxNestingLevel < rowPath.length)
    {
        _maxNestingLevel = rowPath.length - 1;
    }
    NSInteger numberOfRows = [self.dataSource numberOfRowsAtPath:rowPath];
    if(numberOfRows)
    {
        CGFloat controlPanelExpandButtonWidth = [self.dataSource controlPanelExpandItemWidth];
        CGFloat maxWidth = 0;
        CGFloat yOffset = *totalHeight;
        NSMutableArray *newRows = [[NSMutableArray alloc] init];
        for(int j = 0; j < numberOfRows; j++)
        {
            NSIndexPath *subrowPath;
            if(rowPath)
                subrowPath = [rowPath indexPathByAddingIndex:j];
            else
                subrowPath = [NSIndexPath indexPathWithIndex:j];
            
            CGFloat rowHeight = [self.dataSource heightForRowAtPath:subrowPath];
            CGFloat totalSubrowHeight = rowHeight;
            CGFloat totalSubrowWidth = controlPanelExpandButtonWidth;
            
            TSTableViewExpandRow *rowView = [[TSTableViewExpandRow alloc] initWithFrame:CGRectMake(*totalWidth, yOffset,controlPanelExpandButtonWidth, rowHeight)];
            rowView.rowHeight = rowHeight;
            [self addExpandButtonAtPath:subrowPath expandRowView:rowView];
            [self loadSubrowsForRowAtPath:subrowPath expandRowView:rowView totalHeight:&totalSubrowHeight totalWidth:&totalSubrowWidth];
            
            rowView.frame = CGRectMake(rowView.frame.origin.x, rowView.frame.origin.y, rowView.frame.size.width, totalSubrowHeight);
            
            if(maxWidth < totalSubrowWidth)
                maxWidth = totalSubrowWidth;
            [newRows addObject:rowView];
            yOffset += totalSubrowHeight;
        }
        
        for(int j = 0; j < numberOfRows; j++)
        {
            TSTableViewExpandRow *rowView = newRows[j];
            rowView.frame = CGRectMake(rowView.frame.origin.x, rowView.frame.origin.y, maxWidth, rowView.frame.size.height);
        }
        
        if(parentRowView)
        {
            parentRowView.subrows = [NSArray arrayWithArray:newRows];
        }
        else
        {
            [_rows addObjectsFromArray:newRows];
            for(UIView *row in _rows)
                [self addSubview:row];
        }
        
        *totalWidth += maxWidth;
        *totalHeight = yOffset;
    }
}

#pragma mark - Modify content

- (void)changeExpandStateForRow:(NSIndexPath *)rowPath toValue:(BOOL)expanded animated:(BOOL)animated
{
    VerboseLog();
    [self changeExpandStateForSubrows:_rows rowsIndexInPath:0 fullPath:rowPath toValue:(BOOL)expanded animated:animated];
}

- (void)changeExpandStateForSubrows:(NSArray *)subrows rowsIndexInPath:(NSInteger)index fullPath:(NSIndexPath *)rowPath toValue:(BOOL)expanded animated:(BOOL)animated
{
    VerboseLog();
    NSInteger subRowIndex = [rowPath indexAtPosition:index];
    TSTableViewExpandRow *subRow = subrows[subRowIndex];
    CGFloat prevHeight = subRow.frame.size.height;
    
    // calculate new size of subrows
    if(index < rowPath.length - 1)
    {
        [self changeExpandStateForSubrows:subRow.subrows rowsIndexInPath:index + 1 fullPath:rowPath toValue:expanded animated:animated];
    }
    else
    {
        subRow.expandButton.expanded = expanded;
    }
    
    if(expanded)
    {
        subRow.expandButton.expanded = YES;
    }
    
    // back to this row and update its size
    [TSUtils performViewAnimationBlock:^{
        CGRect rect = subRow.frame;
        rect.size.height = [self heightForRow:subRow includingSubrows:expanded];
        subRow.frame = rect;
    } withCompletion:nil animated:animated];
    
    // change position of rows that are follow modified row
    CGFloat delta = subRow.frame.size.height - prevHeight;
    [TSUtils performViewAnimationBlock:^{
        for(int i = subRowIndex + 1; i < subrows.count; i++)
        {
            TSTableViewExpandRow *row = subrows[i];
            CGRect rect = row.frame;
            rect.origin.y += delta;
            row.frame = rect;
        }
    } withCompletion:nil animated:animated];
}

- (CGFloat)heightForRow:(TSTableViewExpandRow *)rowView includingSubrows:(BOOL)withSubrows
{
    VerboseLog();
    CGFloat height = rowView.rowHeight;
    if(withSubrows)
    {
        for (TSTableViewExpandRow *subrow in rowView.subrows)
        {
            height += subrow.frame.size.height;
        }
    }
    return height;
}

- (TSTableViewExpandRow *)rowAtPath:(NSIndexPath *)rowPath
{
    VerboseLog();
    TSTableViewExpandRow *row;
    for(int i = 0; i < rowPath.length; i++)
    {
        NSInteger index = [rowPath indexAtPosition:i];
        if(i == 0)
            row = _rows[index];
        else
            row = row.subrows[index];
    }
    return row;
}

- (BOOL)isRowExpanded:(NSIndexPath *)rowPath
{
    VerboseLog();
    return [self rowAtPath:rowPath].expandButton.expanded;
}

- (void)expandAllRowsWithAnimation:(BOOL)animated
{
    VerboseLog();
    [self changeExpandStateForAllSubrows:_rows rowsPath:nil toValue:YES animated:animated];
}

- (void)collapseAllRowsWithAnimation:(BOOL)animated
{
    VerboseLog();
    [self changeExpandStateForAllSubrows:_rows rowsPath:nil toValue:NO animated:animated];
}

- (void)changeExpandStateForAllSubrows:(NSArray *)subrows rowsPath:(NSIndexPath *)rowsPath toValue:(BOOL)expanded animated:(BOOL)animated
{
    VerboseLog();
    for(int i = 0; i < subrows.count; i++)
    {
        TSTableViewExpandRow *subRow = subrows[i];
        NSIndexPath *subrowPath = (rowsPath ? [rowsPath indexPathByAddingIndex:i] : [NSIndexPath indexPathWithIndex:i]);
        if(subRow.subrows.count)
        {
            [self changeExpandStateForAllSubrows:subRow.subrows rowsPath:subrowPath toValue:expanded animated:animated];
        }
    }
    
    // change position and size of rows
    [TSUtils performViewAnimationBlock:^{
        CGFloat yOffset = 0;
        for(int i = 0; i < subrows.count; i++)
        {
            TSTableViewExpandRow *row = subrows[i];
            row.expandButton.expanded = expanded;
            CGRect rect = row.frame;
            rect.size.height = [self heightForRow:row includingSubrows:expanded];
            rect.origin.y = yOffset;
            row.frame = rect;
            
            yOffset += rect.size.height;
        }
    } withCompletion:nil animated:animated];
}

#pragma mark - Getters

- (CGFloat)tableHeight
{
    VerboseLog();
    CGFloat height = 0;
    for(TSTableViewExpandRow * row in _rows)
    {
        height += row.frame.size.height;
    }
    return height;
}

- (CGFloat)tableTotalHeight
{
    VerboseLog();
    return _totalHeight;//  [self heightForRows:_rows];
}

- (CGFloat)heightForRows:(NSArray *)rows
{
    VerboseLog();
    CGFloat height = 0;
    for(TSTableViewExpandRow * row in rows)
    {
        height += row.rowHeight;
        if(row.subrows.count)
        {
            height += [self heightForRows:rows];
        }
    }
    return height;
}

- (CGFloat)expandControlPanelWidth
{
    VerboseLog();
    return _totalWidth;// [self.dataSource controlPanelExpandItemWidth] * _maxNestingLevel;
}

@end
