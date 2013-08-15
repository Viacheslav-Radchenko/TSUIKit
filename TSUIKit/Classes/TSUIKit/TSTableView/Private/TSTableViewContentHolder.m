//
//  TSTableViewContentHolder.m
//  TSUIKit
//
//  Created by Viacheslav Radchenko on 8/13/13.
//  Copyright (c) 2013 Viacheslav Radchenko. All rights reserved.
//

#import "TSTableViewContentHolder.h"
#import "TSTableViewDataSource.h"
#import "TSTableViewAppearanceCoordinator.h"
#import "TSTableViewRow.h"
#import "TSTableViewCell.h"
#import "TSUtils.h"
#import "TSDefines.h"

#ifndef VerboseLog
#define VerboseLog(fmt, ...)  (void)0
#endif

@implementation TSTableViewContentHolder

-(id) init
{
    if(self = [super init])
    {
        [self initialize];
    }
    return self;
}

-(id) initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        [self initialize];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        [self initialize];
    }
    return self;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    if([view isKindOfClass:[TSTableViewCell class]] || [view isKindOfClass:[TSTableViewRow class]])
    {
        return YES;
    }
    return NO;
}

- (void)initialize
{
    VerboseLog();
    self.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    self.delaysContentTouches = YES;
    self.canCancelContentTouches = YES;
    self.alwaysBounceVertical = YES;
    self.alwaysBounceHorizontal = YES;
    _rows = [[NSMutableArray alloc] init];
}


#pragma mark - Setters 

-(void)setContentOffset:(CGPoint)contentOffset
{
    VerboseLog();
    [super setContentOffset:contentOffset];
    
    if(self.contentHolderDelegate)
    {
        [self.contentHolderDelegate tableViewContentHolder:self contentOffsetDidChange:contentOffset animated:NO];
    }
}

-(void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
    VerboseLog();
    [super setContentOffset:contentOffset animated:(BOOL)animated];
    
    if(self.contentHolderDelegate)
    {
        [self.contentHolderDelegate tableViewContentHolder:self contentOffsetDidChange:contentOffset animated:animated];
    }
}

#pragma mark - Load data

- (void)reloadData
{
    VerboseLog();
    for(TSTableViewRow *row in _rows)
    {
        [row removeFromSuperview];
    }
    [_rows removeAllObjects];
    
    if(self.dataSource)
    {
        CGFloat totalHeight = 0;
        [self loadSubrowsForRowAtPath:nil rowView:nil yOffset:&totalHeight];
    }
}

- (void)loadSubrowsForRowAtPath:(NSIndexPath *)rowPath rowView:(TSTableViewRow *)parentRowView  yOffset:(CGFloat *)yOffset
{
    VerboseLog();
    NSInteger numberOfRows = [self.dataSource numberOfRowsAtPath:rowPath];
    if(numberOfRows)
    {
        NSMutableArray *subRows = [[NSMutableArray alloc] initWithCapacity:numberOfRows];
        
        CGFloat tableWidth;
        if(parentRowView)
            tableWidth = parentRowView.frame.size.width;
        else
            tableWidth = [self.dataSource tableTotalWidth];
        
        for(int j = 0; j < numberOfRows; j++)
        {
            NSIndexPath *subrowPath;
            if(rowPath)
                subrowPath = [rowPath indexPathByAddingIndex:j];
            else
                subrowPath = [NSIndexPath indexPathWithIndex:j];
            
            CGFloat totalSubrowHeight = 0;
            TSTableViewRow *rowView = [[TSTableViewRow alloc] initWithFrame:CGRectMake(0, *yOffset, tableWidth, 0)];
            [self loadCellsForRowAtPath:subrowPath rowView:rowView yOffset:&totalSubrowHeight];
            [self loadSubrowsForRowAtPath:subrowPath rowView:rowView yOffset:&totalSubrowHeight];
            
            rowView.backgroundColor = [UIColor clearColor];
            rowView.frame = CGRectMake(rowView.frame.origin.x, rowView.frame.origin.y, rowView.frame.size.width, totalSubrowHeight);
            
            [subRows addObject:rowView];
            *yOffset += totalSubrowHeight;
        }
        
        if(parentRowView)
        {
            parentRowView.subrows = [NSArray arrayWithArray:subRows];
        }
        else
        {
            [_rows addObjectsFromArray:subRows];
            for(UIView *row in _rows)
                [self addSubview:row];
        }
    }
}

- (void)loadCellsForRowAtPath:(NSIndexPath *)rowPath rowView:(TSTableViewRow *)parentRowView yOffset:(CGFloat *)yOffset
{
    VerboseLog();
    NSInteger numberOfColumns = [self.dataSource numberOfColumns];
    NSMutableArray *newCells = [[NSMutableArray alloc] initWithCapacity:numberOfColumns];
    CGFloat rowHeight = [self.dataSource heightForRowAtPath:rowPath];
    CGFloat xOffset = 0;
    for(int j = 0; j < numberOfColumns; j++)
    {
        CGFloat columnWidth = [self.dataSource widthForColumnAtIndex:j];
        TSTableViewCell *cellView = [self.dataSource cellViewForRowAtPath:rowPath cellIndex:j];
        cellView.frame = CGRectMake(xOffset, 0, columnWidth, rowHeight);
        [newCells addObject:cellView];  
        xOffset += columnWidth;
    }
    parentRowView.rowHeight = rowHeight;
    parentRowView.cells = [NSArray arrayWithArray:newCells];
    *yOffset += rowHeight;
}


#pragma mark - Modify content

- (void)changeColumnWidthOnAmount:(CGFloat)delta forColumn:(NSInteger)columnIndex animated:(BOOL)animated
{
    VerboseLog();
    [self changeColumnWidthForRows:_rows onAmount:delta forColumn:columnIndex animated:animated];
}

- (void)changeColumnWidthForRows:(NSArray *)rows onAmount:(CGFloat)delta forColumn:(NSInteger)columnIndex animated:(BOOL)animated
{
    VerboseLog();
    for (TSTableViewRow *rowView in rows)
    {
        [self changeColumnWidthForRows:rowView.subrows onAmount:delta forColumn:columnIndex animated:animated];
        [TSUtils performViewAnimationBlock:^{
            CGRect rect = rowView.frame;
            rect.size.width += delta;
            rowView.frame = rect;
            for(int i = columnIndex; i < rowView.cells.count; i++)
            {
                TSTableViewCell *cell = rowView.cells[i];
                CGRect rect = cell.frame;
                if(i == columnIndex)
                    rect.size.width += delta;
                else
                    rect.origin.x += delta;
                cell.frame = rect;
            }
        } withCompletion:nil animated:animated];
    }
}

- (void)changeExpandStateForRow:(NSIndexPath *)rowPath toValue:(BOOL)expanded animated:(BOOL)animated
{
    VerboseLog();
    [self changeExpandStateForSubrows:_rows rowsIndexInPath:0 fullPath:rowPath toValue:(BOOL)expanded animated:animated];
}

- (void)changeExpandStateForSubrows:(NSArray *)subrows rowsIndexInPath:(NSInteger)index fullPath:(NSIndexPath *)rowPath toValue:(BOOL)expanded animated:(BOOL)animated
{
    VerboseLog();
    NSInteger subRowIndex = [rowPath indexAtPosition:index];
    TSTableViewRow *subRow = subrows[subRowIndex];
    CGFloat prevHeight = subRow.frame.size.height;
    
    // move forvard and calculate new size of subrows
    if(index < rowPath.length - 1)
    {
        [self changeExpandStateForSubrows:subRow.subrows rowsIndexInPath:index + 1 fullPath:rowPath toValue:expanded animated:animated];
    }
    
    // back to this row and update its size as well
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
            TSTableViewRow *row = subrows[i];
            CGRect rect = row.frame;
            rect.origin.y += delta;
            row.frame = rect;
        }
    } withCompletion:nil animated:animated];
}

- (CGFloat)heightForRow:(TSTableViewRow *)rowView includingSubrows:(BOOL)withSubrows
{
    VerboseLog();
    CGFloat height = rowView.rowHeight;
    if(withSubrows)
    {
        for (TSTableViewRow *subrow in rowView.subrows)
        {
            height += subrow.frame.size.height;
        }
    }
    return height;
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
        TSTableViewRow *subRow = subrows[i];
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
            TSTableViewRow *row = subrows[i];
            CGRect rect = row.frame;
            rect.size.height = [self heightForRow:row includingSubrows:expanded];
            rect.origin.y = yOffset;
            row.frame = rect;
            
            yOffset += rect.size.height;
        }
    } withCompletion:nil animated:animated];
}

@end
