//
//  TSTableViewContentHolder.m
//  TSUIKit
//
//  Created by Viacheslav Radchenko on 8/13/13.
//
//  The MIT License (MIT)
//  Copyright © 2013 Viacheslav Radchenko
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

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

/**
 *  @abstract Selection rectangle view
 */

@interface TSTableViewSelection : UIView

@property (nonatomic, strong) NSIndexPath *selectedItem;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIColor *selectionColor;

@end

@implementation TSTableViewSelection

-(id)init
{
    if(self = [super init])
    {
        [self initialize];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.backgroundColor = [UIColor clearColor];
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    
    _imageView.backgroundColor = [UIColor clearColor];
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:_imageView];
    
    self.selectionColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.25f];
}

- (void)setSelectionColor:(UIColor *)selectionColor
{
    _selectionColor = selectionColor;
    UIImage *img = [TSUtils imageWithInnerShadow:_selectionColor.CGColor blurSize:16 andSize:CGSizeMake(32,32)];
    _imageView.image = [img resizableImageWithCapInsets:UIEdgeInsetsMake(img.size.height/2, img.size.width/2, img.size.height/2, img.size.width/2)];
}

@end

/**************************************************************************************************************************************/

@interface  TSTableViewContentHolder ()

@property (nonatomic, strong) TSTableViewSelection *rowSelectionView;
@property (nonatomic, strong) TSTableViewSelection *columnSelectionView;

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation TSTableViewContentHolder

@dynamic rowSelectionColor;
@dynamic columnSelectionColor;

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
    if([view isKindOfClass:[TSTableViewCell class]] ||
       [view isKindOfClass:[TSTableViewRow class]] ||
       [view isKindOfClass:[TSTableViewSelection class]])
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
    
    _allowRowSelection = YES;
    _rows = [[NSMutableArray alloc] init];
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureDidRecognized:)];
    [self addGestureRecognizer:_tapGestureRecognizer];
}

- (TSTableViewSelection *)rowSelectionView
{
    if(!_rowSelectionView)
    {
        _rowSelectionView = [[TSTableViewSelection alloc] init];
        _rowSelectionView.alpha = 0;
        _rowSelectionView.hidden = YES;
        _rowSelectionView.selectionColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.25f];;
        [self addSubview:_rowSelectionView];
    }
    return _rowSelectionView;
}

- (TSTableViewSelection *)columnSelectionView
{
    if(!_columnSelectionView)
    {
        _columnSelectionView = [[TSTableViewSelection alloc] init];
        _columnSelectionView.alpha = 0;
        _columnSelectionView.hidden = YES;
        _columnSelectionView.selectionColor = [UIColor colorWithRed:1 green:1 blue:0 alpha:0.25f];;
        [self addSubview:_columnSelectionView];
    }
    return _columnSelectionView;
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

- (void)setRowSelectionColor:(UIColor *)color
{
    _rowSelectionView.selectionColor = color;
}

- (UIColor *)rowSelectionColor
{
    return _rowSelectionView.selectionColor;
}

- (void)setColumnSelectionColor:(UIColor *)color
{
    _columnSelectionView.selectionColor = color;
}

- (UIColor *)columnSelectionColor
{
    return _columnSelectionView.selectionColor;
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
    
    [self resetColumnSelectionWithAnimtaion:NO];
    [self resetRowSelectionWithAnimtaion:NO];
    
    if(self.dataSource)
    {
        [self loadSubrowsForRowAtPath:nil rowView:nil];
        [self updateLayout];
    }
    
    if(_rowSelectionView)
    {
        [self bringSubviewToFront:_rowSelectionView];
    }
}

- (void)loadSubrowsForRowAtPath:(NSIndexPath *)rowPath rowView:(TSTableViewRow *)parentRowView
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
            
            CGFloat rowHeight = [self.dataSource heightForRowAtPath:rowPath];
            TSTableViewRow *rowView = [[TSTableViewRow alloc] initWithFrame:CGRectMake(0, 0, tableWidth, rowHeight)];
            rowView.rowHeight = rowHeight;
            [self loadCellsForRowAtPath:subrowPath rowView:rowView];
            [self loadSubrowsForRowAtPath:subrowPath rowView:rowView];
        
            [subRows addObject:rowView];
        }
        
        if(parentRowView)
        {
            parentRowView.subrows = subRows;
        }
        else
        {
            [_rows addObjectsFromArray:subRows];
            for(UIView *row in _rows)
                [self addSubview:row];
        }
    }
}

- (void)loadCellsForRowAtPath:(NSIndexPath *)rowPath rowView:(TSTableViewRow *)parentRowView
{
    VerboseLog();
    NSInteger numberOfColumns = [self.dataSource numberOfColumns];
    NSMutableArray *newCells = [[NSMutableArray alloc] initWithCapacity:numberOfColumns];
    CGFloat xOffset = 0;
    for(int j = 0; j < numberOfColumns; j++)
    {
        CGFloat columnWidth = [self.dataSource widthForColumnAtIndex:j];
        TSTableViewCell *cellView = [self.dataSource cellViewForRowAtPath:rowPath cellIndex:j];
        cellView.frame = CGRectMake(xOffset, 0, columnWidth, parentRowView.rowHeight);
        [newCells addObject:cellView];  
        xOffset += columnWidth;
    }
    parentRowView.cells = [NSArray arrayWithArray:newCells];
}

#pragma mark -

- (void)updateLayout
{
    CGFloat totalHeight = 0;
    CGFloat tableWidth = [self.dataSource tableTotalWidth];
    [self updateLayoutForRows:_rows atPath:nil tableWidth:tableWidth yOffset:&totalHeight];
}

- (void)updateLayoutForRows:(NSArray *)rows atPath:(NSIndexPath *)path tableWidth:(CGFloat)tableWidth yOffset:(CGFloat *)yOffset
{
    for(int i = 0; i < rows.count; i++)
    {
        NSIndexPath *rowPath;
        if(path)
            rowPath = [path indexPathByAddingIndex:i];
        else
            rowPath = [NSIndexPath indexPathWithIndex:i];
        
        TSTableViewRow *row = rows[i];
        CGFloat totalRowHeight = row.rowHeight;
        CGFloat offset = *yOffset;

        if(row.subrows.count)
        {
            [self updateLayoutForRows:row.subrows atPath:rowPath tableWidth:tableWidth yOffset:&totalRowHeight];
        }
        CGFloat visibleHeight = [self heightForRow:row includingSubrows:[self.dataSource isRowExpanded:rowPath]];
        row.frame = CGRectMake(row.frame.origin.x, offset, tableWidth, visibleHeight);
        *yOffset += visibleHeight;
    }
}

#pragma mark - Modify content

- (void)changeColumnWidthOnAmount:(CGFloat)delta forColumn:(NSInteger)columnIndex animated:(BOOL)animated
{
    VerboseLog();
    [self changeColumnWidthForRows:_rows onAmount:delta forColumn:columnIndex animated:animated];
    [self updateRowSelectionWithAnimation:animated];
    [self updateColumnSelectionWithAnimation:animated];
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
    [self changeExpandStateForSubrows:_rows rowsIndexInPath:0 fullPath:rowPath toValue:expanded animated:animated];
    [self updateRowSelectionWithAnimation:animated];
    [self updateColumnSelectionWithAnimation:animated];
}

- (void)changeExpandStateForSubrows:(NSArray *)subrows rowsIndexInPath:(NSInteger)index fullPath:(NSIndexPath *)rowPath toValue:(BOOL)expanded animated:(BOOL)animated
{
    VerboseLog();
    NSInteger subRowIndex = [rowPath indexAtPosition:index];
    NSUInteger indexes[index + 1];
    [rowPath getIndexes:indexes];
    NSIndexPath *subRowIndexPath = [[NSIndexPath alloc] initWithIndexes:indexes length:index + 1];
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
        rect.size.height = [self heightForRow:subRow includingSubrows:[self.dataSource isRowExpanded:subRowIndexPath]];
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
    [self updateRowSelectionWithAnimation:animated];
    [self updateColumnSelectionWithAnimation:animated];
}

- (void)collapseAllRowsWithAnimation:(BOOL)animated
{
    VerboseLog();
    [self changeExpandStateForAllSubrows:_rows rowsPath:nil toValue:NO animated:animated];
    [self updateRowSelectionWithAnimation:animated];
    [self updateColumnSelectionWithAnimation:animated];
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
            // first row in group may have offset that is not equal to 0
            if(i == 0)
                yOffset = row.frame.origin.y;
            CGRect rect = row.frame;
            rect.size.height = [self heightForRow:row includingSubrows:expanded];
            rect.origin.y = yOffset;
            row.frame = rect;
            
            yOffset += rect.size.height;
        }
    } withCompletion:nil animated:animated];
}

- (TSTableViewRow *)rowAtPath:(NSIndexPath *)rowPath
{
    TSTableViewRow *row;
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

- (void)selectRowAtPath:(NSIndexPath *)rowPath animated:(BOOL)animated
{
    VerboseLog();
    [self selectRowAtPath:rowPath animated:animated internal:NO];
}

- (void)selectRowAtPath:(NSIndexPath *)rowPath animated:(BOOL)animated internal:(BOOL)internal
{
    VerboseLog();
    if(![self.dataSource isRowVisible:rowPath])
    {
        [TSUtils performViewAnimationBlock:^{
            self.rowSelectionView.alpha = 0;
        } withCompletion:^{
            self.rowSelectionView.hidden = YES;
        } animated:animated];
        return;
    }
    
    if(internal && self.contentHolderDelegate)
    {
        [self.contentHolderDelegate tableViewContentHolder:self willSelectRowAtPath:rowPath animated:animated];
    }
    
    TSTableViewRow *row = [self rowAtPath:rowPath];
    CGRect rect = row.frame;
    UIView *rowView = row;
    while(rowView.superview && rowView.superview != self)
    {
        rect.origin.x += rowView.superview.frame.origin.x;
        rect.origin.y += rowView.superview.frame.origin.y;
        rowView = rowView.superview;
    }
    
    self.rowSelectionView.selectedItem = rowPath;
    
    self.rowSelectionView.hidden = NO;
    [TSUtils performViewAnimationBlock:^{
        self.rowSelectionView.frame = rect;
        self.rowSelectionView.alpha = 1;
    } withCompletion:^{
        if(internal && self.contentHolderDelegate)
        {
            [self.contentHolderDelegate tableViewContentHolder:self didSelectRowAtPath:rowPath];
        }
    } animated:animated];
}

- (void)selectColumnAtPath:(NSIndexPath *)columnPath animated:(BOOL)animated
{
    VerboseLog();
    [self selectColumnAtPath:columnPath animated:animated internal:NO];
}

- (void)selectColumnAtPath:(NSIndexPath *)columnPath animated:(BOOL)animated internal:(BOOL)internal
{
    VerboseLog();
    if(internal && self.contentHolderDelegate)
    {
        [self.contentHolderDelegate tableViewContentHolder:self willSelectColumnAtPath:columnPath animated:animated];
    }
    
    CGFloat width = [self.dataSource widthForColumnAtPath:columnPath];
    CGFloat offset = [self.dataSource offsetForColumnAtPath:columnPath];
    CGFloat height = [self.dataSource tableHeight];
   
    self.columnSelectionView.selectedItem = columnPath;

    self.columnSelectionView.hidden = NO;
    [TSUtils performViewAnimationBlock:^{
        self.columnSelectionView.frame = CGRectMake(offset, 0, width, height);
        self.columnSelectionView.alpha = 1;
    } withCompletion:^{
        if(internal && self.contentHolderDelegate)
        {
            [self.contentHolderDelegate tableViewContentHolder:self didSelectColumnAtPath:columnPath];
        }
    } animated:animated];
}

- (void)resetRowSelectionWithAnimtaion:(BOOL)animated
{
    if(_rowSelectionView)
    {
        self.rowSelectionView.selectedItem = nil;
        [TSUtils performViewAnimationBlock:^{
            self.rowSelectionView.alpha = 0;
        } withCompletion:^{
            self.rowSelectionView.hidden = YES;
        } animated:animated];
    }
}

- (void)resetColumnSelectionWithAnimtaion:(BOOL)animated
{
    if(_columnSelectionView)
    {
        self.columnSelectionView.selectedItem = nil;
        [TSUtils performViewAnimationBlock:^{
            self.columnSelectionView.alpha = 0;
        } withCompletion:^{
            self.columnSelectionView.hidden = YES;
        } animated:animated];
    }
}

- (void)updateRowSelectionWithAnimation:(BOOL)animated
{
    if(_rowSelectionView && _rowSelectionView.selectedItem)
        [self selectRowAtPath:self.rowSelectionView.selectedItem animated:animated];
}

- (void)updateColumnSelectionWithAnimation:(BOOL)animated
{
    if(_columnSelectionView && _columnSelectionView.selectedItem)
        [self selectColumnAtPath:self.columnSelectionView.selectedItem animated:animated];
}

- (NSIndexPath *)pathToSelectedRow
{
    return _rowSelectionView.selectedItem;
}

- (NSIndexPath *)pathToSelectedColumn
{
    return _columnSelectionView.selectedItem;
}

#pragma mark - Selection 

- (void)tapGestureDidRecognized:(UITapGestureRecognizer *)recognizer
{
    if(_allowRowSelection)
    {
        CGPoint pos = [recognizer locationInView:self];
        NSIndexPath *rowIndexPath = [self findRowAtPosition:pos parentRow:nil parentPowPath:nil];
        if(rowIndexPath)
        {
            [self selectRowAtPath:rowIndexPath animated:YES internal:YES];
        }
    }
}

- (NSIndexPath *)findRowAtPosition:(CGPoint)pos parentRow:(TSTableViewRow *)parentRow parentPowPath:(NSIndexPath *)parentRowPath
{
    NSArray *rows = (parentRow ? parentRow.subrows : _rows);
    for(int i = 0; i < rows.count; i++)
    {
        TSTableViewRow *row = rows[i];
        if(CGRectContainsPoint(row.frame, pos))
        {
            NSIndexPath *rowIndexPath = (parentRowPath ? [parentRowPath indexPathByAddingIndex:i] : [NSIndexPath indexPathWithIndex:i]);
            return [self findRowAtPosition:CGPointMake(pos.x - row.frame.origin.x, pos.y - row.frame.origin.y) parentRow:row parentPowPath:rowIndexPath];
        }
    }
    return parentRowPath;
}

#pragma mark - Modify content


- (void)insertRowAtPath:(NSIndexPath *)path animated:(BOOL)animated
{
    // Find subrows where new row should be inserted
    TSTableViewRow *row;
    NSMutableArray *rows = _rows;
    for(int i = 0; i < path.length - 1; i++)
    {
        NSInteger index = [path indexAtPosition:i];
        row = rows[index];
        rows = row.subrows;
    }
    
    // Find position where new row should be inserted
    //    NSInteger lastIndex = [path indexAtPosition:path.length - 1];
    //    UIImage *controlPanelExpandBackImage = [self.dataSource controlPanelExpandSectionBackgroundImage];
    //    CGFloat rowHeight = [self.dataSource heightForRowAtPath:path];
    //    CGFloat expandItemWidth = [self.dataSource  widthForExpandItem];
    //    CGFloat totalSubrowHeight = rowHeight;
    //    CGFloat totalSubrowWidth = expandItemWidth;
    //    CGFloat yOffset = 0;
    //
    //    TSTableViewExpandSection *rowView = [[TSTableViewExpandSection alloc] initWithFrame:CGRectMake(totalSubrowWidth, yOffset,expandItemWidth, rowHeight)];
    //    rowView.rowPath = path;
    //    rowView.rowHeight = rowHeight;
    //    if(controlPanelExpandBackImage)
    //    {
    //        rowView.backgroundImage.image = controlPanelExpandBackImage;
    //    }
    //    if(![self.dataSource lineNumbersAreHidden])
    //    {
    //        [rowView setLineNumber:lastIndex + 1];
    //        rowView.lineLabel.textColor = [self.dataSource lineNumbersColor];
    //    }
    //    [self addExpandButtonAtPath:path expandRowView:rowView];
    //    [self loadSubrowsForRowAtPath:path expandRowView:rowView totalHeight:&totalSubrowHeight totalWidth:&totalSubrowWidth];
    //
    //    rowView.frame = CGRectMake(rowView.frame.origin.x, rowView.frame.origin.y, rowView.frame.size.width, totalSubrowHeight);
    //
    //    if(maxWidth < totalSubrowWidth)
    //        maxWidth = totalSubrowWidth;
    //    [newRows addObject:rowView];
    //    yOffset += totalSubrowHeight;
    //
    //
    //    [rows insertObject:rowInfo atIndex:lastIndex];
}

- (void)updateRowAtPath:(NSIndexPath *)path animated:(BOOL)animated
{
    
}

- (void)removeRowAtPath:(NSIndexPath *)path animated:(BOOL)animated
{
    // Find subrows where row should be removed
    TSTableViewRow *row;
    NSMutableArray *rows = _rows;
    for(int i = 0; i < path.length - 1; i++)
    {
        NSInteger index = [path indexAtPosition:i];
        row = rows[index];
        rows = row.subrows;
    }
    
    // Find position where new row should be inserted
    NSInteger lastIndex = [path indexAtPosition:path.length - 1];
    TSTableViewRow *removedRow = rows[lastIndex];
    [removedRow removeFromSuperview];
    [rows removeObject:removedRow];
    
    [self updateCurrectSelectionOnRemoveRowAtPath:path animated:animated];
    
    [TSUtils performViewAnimationBlock:^{
        [self updateLayout];
    } withCompletion:nil animated:animated];
}

- (void)updateCurrectSelectionOnRemoveRowAtPath:(NSIndexPath *)path animated:(BOOL)animated
{
    // update selection
    if(_rowSelectionView.selectedItem)
    {
        // if selected row is removed then just reset selection
        if([_rowSelectionView.selectedItem isEqual:path])
        {
            [self resetRowSelectionWithAnimtaion:animated];
        }
        else if(_rowSelectionView.selectedItem.length > path.length)
        {
            //is selection path is deeper it might be affected due to row deletion
            BOOL equal = YES;
            // compare both pathes to find equal range in the beginning
            NSIndexPath *newSelectionPath;
            for(int i = 0; i < _rowSelectionView.selectedItem.length; i++)
            {
                NSInteger selectionIndex = [_rowSelectionView.selectedItem indexAtPosition:i];
                if(equal && i < path.length)
                {
                    NSInteger removeIndex = [path indexAtPosition:i];
                    if(path.length == i - 1) // end of the removed roew path
                    {
                        if(selectionIndex == removeIndex) // if selection is subrow in removed row hierarchy then reset selection
                        {
                            [self resetRowSelectionWithAnimtaion:animated];
                            newSelectionPath = nil;
                            break;
                        }
                        else if(selectionIndex > removeIndex) // correct selection index if it greater the removed row
                        {
                            selectionIndex--;
                            equal = NO;
                        }
                    }
                    else if(removeIndex != selectionIndex) // if found first difference in pathes, remove path still have inner subrows so it wouldn't affect selection row
                    {
                        equal = NO;
                    }
                }
                
                if(newSelectionPath)
                    newSelectionPath = [newSelectionPath indexPathByAddingIndex:i];
                else
                    newSelectionPath = [NSIndexPath indexPathWithIndex:i];
            }
            
            if(newSelectionPath)
            {
                [self selectRowAtPath:newSelectionPath animated:animated];
            }
            else
            {
                [self updateRowSelectionWithAnimation:animated];
            }
        }
    }
    [self updateColumnSelectionWithAnimation:animated];
}

@end
