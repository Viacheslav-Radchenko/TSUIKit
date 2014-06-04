//
//  TSTableView.m
//  TSUIKit
//
//  Created by Viacheslav Radchenko on 8/9/13.
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

#import "TSTableView.h"
#import "TSTableViewHeaderPanel.h"
#import "TSTableViewExpandControlPanel.h"
#import "TSTableViewContentHolder.h"
#import "TSTableViewDataSource.h"
#import "TSTableViewAppearanceCoordinator.h"
#import "TSUtils.h"
#import "TSDefines.h"

#import "TSTableViewCell.h"
#import "TSTableViewHeaderSectionView.h"

#import <QuartzCore/QuartzCore.h>

#define MIN_COLUMN_WIDTH          64
#define MAX_COLUMN_WIDTH          512
#define DEF_COLUMN_WIDTH          128
#define DEF_COLUMN_HEADER_HEIGHT  32
#define DEF_ROW_HEIGHT            28
#define DEF_EXPAND_ITEM_WIDTH     34

#define DEF_TABLE_CONTENT_ADDITIONAL_SIZE   32
#define DEF_TABLE_MIN_COLUMN_WIDTH          64
#define DEF_TABLE_MAX_COLUMN_WIDTH          512
#define DEF_TABLE_DEF_COLUMN_WIDTH          128

// Add private API in TSTableViewContentHolder to TSTableView scope
@interface TSTableViewContentHolder (Private)

- (void)selectColumnAtPath:(NSIndexPath *)columnPath animated:(BOOL)animated internal:(BOOL)internal;

@end

@interface TSTableView () <TSTableViewHeaderPanelDelegate, TSTableViewExpandControlPanelDelegate, TSTableViewContentHolderDelegate, TSTableViewAppearanceCoordinator,TSTableViewDataSource>
{
    NSMutableDictionary *_cachedHeaderSectionBackgroundImages;
    NSMutableDictionary *_cachedCellBackgroundImages;
    UIImage *_cachedGeneralBackgroundImage;
    UIImage *_cachedExpandSectionBackgroundImage;
    UIImage *_cachedExpandItemNormalBackgroundImage;
    UIImage *_cachedExpandItemSelectedBackgroundImage;
    NSMutableArray *_columns;
    NSMutableArray *_bottomEndColumns;
    NSMutableArray *_rows;
}

@property (nonatomic, strong) TSTableViewHeaderPanel *tableHeader;
@property (nonatomic, strong) TSTableViewExpandControlPanel *tableControlPanel;
@property (nonatomic, strong) TSTableViewContentHolder *tableContentHolder;
@property (nonatomic, strong) UIImageView *headerBackgroundImageView;
@property (nonatomic, strong) UIImageView *expandPanelBackgroundImageView;
@property (nonatomic, strong) UIImageView *topLeftCornerBackgroundImageView;

@end

@implementation TSTableView

@dynamic allowRowSelection;
@dynamic allowColumnSelection;
@dynamic maxNestingLevel;
@dynamic expandPanelBackgroundImage;
@dynamic headerBackgroundImage;
@dynamic topLeftCornerBackgroundImage;
@dynamic headerBackgroundColor;
@dynamic expandPanelBackgroundColor;

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

//mark: add init with style
- (id)initWithFrame:(CGRect)frame andStyle:(TSTableViewStyle)style
{
    if(self = [super initWithFrame:frame])
    {
        [self initialize];
        _tableStyle = style;
        if(_tableStyle == kTSTableViewStyleLight)
        {
            self.lineNumbersColor = [UIColor blackColor];
            self.backgroundColor = [UIColor grayColor];
        }
        else
        {
            self.lineNumbersColor = [UIColor lightGrayColor];
            self.backgroundColor = [UIColor colorWithWhite:0.12 alpha:1];
        }
        
        _heightForRow = DEF_ROW_HEIGHT;
        _widthForExpandItem = DEF_EXPAND_ITEM_WIDTH;
        
        _rows = [[NSMutableArray alloc] init];
        _columns = [[NSMutableArray alloc] init];
        _bottomEndColumns = [[NSMutableArray alloc] init];
        _cachedHeaderSectionBackgroundImages = [[NSMutableDictionary alloc] init];
        _cachedCellBackgroundImages = [[NSMutableDictionary alloc] init];
        
        self.headerBackgroundImage = [self generalBackgroundImage];
        self.expandPanelBackgroundImage = [self generalBackgroundImage];
        self.topLeftCornerBackgroundImage = [self generalBackgroundImage];
        self.expandItemNormalBackgroundImage = [self expandItemNormalBackgroundImage];
        self.expandItemSelectedBackgroundImage = [self expandItemSelectedBackgroundImage];
        self.expandSectionBackgroundImage = [self expandSectionBackgroundImage];
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
    self.backgroundColor = [UIColor blackColor];
    
    _lineNumbersColor = [UIColor blackColor];
    _contentAdditionalSize = DEF_TABLE_CONTENT_ADDITIONAL_SIZE;
   
    CGRect headerRect = CGRectMake(0, 0, self.frame.size.width, 0);
    _tableHeader = [[TSTableViewHeaderPanel alloc] initWithFrame: headerRect];
    _tableHeader.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _tableHeader.backgroundColor = [UIColor clearColor];
    _tableHeader.headerDelegate = self;
    [self addSubview:_tableHeader];
    
    CGRect controlPanelRect = CGRectMake(0, 0, 0, self.frame.size.height);
    _tableControlPanel = [[TSTableViewExpandControlPanel alloc] initWithFrame:controlPanelRect];
    _tableControlPanel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _tableControlPanel.controlPanelDelegate = self;
    _tableControlPanel.backgroundColor = [UIColor clearColor];
    [self addSubview: _tableControlPanel];
    
    CGRect contentRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _tableContentHolder = [[TSTableViewContentHolder alloc] initWithFrame:contentRect];
    _tableContentHolder.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _tableContentHolder.contentHolderDelegate = self;
    [self addSubview: _tableContentHolder];
    
    //mark: 给左侧的ExpandControlPanel添加点击事件。让其响应为选中某一行。代替原来点击TSTableViewContentHolder的事件响应。
    UITapGestureRecognizer *tapExpandPanel = [[UITapGestureRecognizer alloc] initWithTarget:_tableContentHolder action:@selector(tapExpandPanelRecognized:)];
    [_tableControlPanel addGestureRecognizer:tapExpandPanel];
    
    _tableHeader.dataSource = (id)self;
    _tableControlPanel.dataSource = (id)self;
    _tableContentHolder.dataSource = (id)self;
}


#pragma mark - Getters & Setters

- (NSInteger)maxNestingLevel
{
    return _tableControlPanel.maxNestingLevel;
}

- (BOOL)allowRowSelection
{
    return _tableContentHolder.allowRowSelection;
}

- (void)setAllowRowSelection:(BOOL)val
{
    _tableContentHolder.allowRowSelection = val;
}

- (BOOL)allowColumnSelection
{
    return _tableHeader.allowColumnSelection;
}

- (void)setAllowColumnSelection:(BOOL)val
{
    _tableHeader.allowColumnSelection = val;
}

- (BOOL)headerPanelHidden
{
    return _tableHeader.hidden;
}

- (void)setHeaderPanelHidden:(BOOL)hidden
{
    _tableHeader.hidden = hidden;
    [self updateLayout];
}

- (BOOL)expandPanelHidden
{
    return _tableControlPanel.hidden;
}

- (void)setExpandPanelHidden:(BOOL)hidden
{
    _tableControlPanel.hidden = hidden;
    [self updateLayout];
}

- (UIImage *)headerBackgroundImage
{
    return self.headerBackgroundImageView.image;
}

- (void)setHeaderBackgroundImage:(UIImage *)image
{
    self.headerBackgroundImageView.image = image;
}

- (UIImage *)expandPanelBackgroundImage
{
    return self.expandPanelBackgroundImageView.image;
}

- (void)setExpandPanelBackgroundImage:(UIImage *)image
{
    self.expandPanelBackgroundImageView.image = image;
}

- (UIImage *)topLeftCornerBackgroundImage
{
    return self.topLeftCornerBackgroundImageView.image;
}

- (void)setTopLeftCornerBackgroundImage:(UIImage *)image
{
    self.topLeftCornerBackgroundImageView.image = image;
}

- (UIColor *)headerBackgroundColor
{
    return _tableHeader.backgroundColor;
}

- (void)setHeaderBackgroundColor:(UIColor *)color
{
    _tableHeader.backgroundColor = color;
}

- (UIColor *)expandPanelBackgroundColor
{
    return _tableControlPanel.backgroundColor;
}

- (void)setExpandPanelBackgroundColor:(UIColor *)color
{
    _tableControlPanel.backgroundColor = color;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    _tableContentHolder.backgroundColor = backgroundColor;
}

- (UIImageView *)headerBackgroundImageView
{
    if(!_headerBackgroundImageView)
    {
        _headerBackgroundImageView = [[UIImageView alloc] initWithFrame:_tableHeader.frame];
        _headerBackgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self insertSubview:_headerBackgroundImageView belowSubview:_tableHeader];
    }
    return _headerBackgroundImageView;
}

- (UIImageView *)expandPanelBackgroundImageView
{
    if(!_expandPanelBackgroundImageView)
    {
        _expandPanelBackgroundImageView = [[UIImageView alloc] initWithFrame:_tableControlPanel.frame];
        _expandPanelBackgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self insertSubview:_expandPanelBackgroundImageView belowSubview:_tableControlPanel];
    }
    return _expandPanelBackgroundImageView;
}

- (UIImageView *)topLeftCornerBackgroundImageView
{
    if(!_topLeftCornerBackgroundImageView)
    {
        _topLeftCornerBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _tableControlPanel.frame.size.width, _tableHeader.frame.size.height)];
        [self addSubview:_topLeftCornerBackgroundImageView];
    }
    return _topLeftCornerBackgroundImageView;
}


#pragma mark - Layout

- (void)updateLayout
{
    VerboseLog();
    CGFloat headerHeight = (_tableHeader.hidden ? 0 : [_tableHeader headerHeight]);
    CGFloat controlPanleWidth = (_tableControlPanel.hidden ? 0 : [_tableControlPanel panelWidth]);//mark: controlPanleWidth需要重新计算！
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
    
    if(_headerBackgroundImageView)
    {
        _headerBackgroundImageView.hidden = _tableHeader.hidden;
        _headerBackgroundImageView.frame = _tableHeader.frame;
    }
    
    if(_expandPanelBackgroundImageView)
    {
        _expandPanelBackgroundImageView.hidden = _tableControlPanel.hidden;
        _expandPanelBackgroundImageView.frame = _tableControlPanel.frame;
    }

    if(_topLeftCornerBackgroundImageView)
    {
        _topLeftCornerBackgroundImageView.hidden = _tableControlPanel.hidden || _tableHeader.hidden;
        _topLeftCornerBackgroundImageView.frame = CGRectMake(0, 0, _tableControlPanel.frame.size.width, _tableHeader.frame.size.height);
    }
}

- (void)reloadData
{
    VerboseLog();
    [self clearCachedData];
    [self.tableHeader reloadData];
    [self.tableControlPanel reloadData];
    [self.tableContentHolder reloadData];
    [self updateLayout];
}

- (void)reloadRowsData
{
    VerboseLog();
    [self.tableControlPanel reloadData];
    [self.tableContentHolder reloadData];
    [self updateLayout];
}

- (TSTableViewCell *)dequeueReusableCellViewWithIdentifier:(NSString *)identifier
{
    return [_tableContentHolder dequeueReusableCellViewWithIdentifier:identifier];
}

- (void)clearCachedData
{
    [_tableContentHolder clearCachedData];
}

#pragma mark - TSTableViewHeaderPanelDelegate 

- (void)tableViewHeader:(TSTableViewHeaderPanel *)header columnWidthDidChange:(NSInteger)columnIndex oldWidth:(CGFloat)oldWidth newWidth:(CGFloat)newWidth
{
    VerboseLog();
    CGFloat delta = newWidth - oldWidth;
    [_tableContentHolder changeColumnWidthOnAmount:delta forColumn:columnIndex animated:NO];
    [self updateLayout];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(tableView:widthDidChangeForColumnAtIndex:)])
    {
        [self.delegate tableView:self widthDidChangeForColumnAtIndex:columnIndex];
    }
}

- (void)tableViewHeader:(TSTableViewHeaderPanel *)header didSelectColumnAtPath:(NSIndexPath *)columnPath
{
    VerboseLog();
    [_tableContentHolder selectColumnAtPath:columnPath animated:YES internal:YES];
}

#pragma mark - TSTableViewExpandControlPanelDelegate

- (void)tableViewSideControlPanel:(TSTableViewExpandControlPanel *)controlPanel expandStateDidChange:(BOOL)expand forRow:(NSIndexPath *)rowPath
{
    VerboseLog();
    [self updateLayout];
    [_tableContentHolder changeExpandStateForRow:rowPath toValue:expand animated:YES];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(tableView:expandStateDidChange:forRowAtPath:)])
    {
        [self.delegate tableView:self expandStateDidChange:expand forRowAtPath:rowPath];
    }
}

#pragma mark - TSTableViewContentHolderDelegate

- (void)tableViewContentHolder:(TSTableViewContentHolder *)contentHolder contentOffsetDidChange:(CGPoint)contentOffset animated:(BOOL)animated
{
    VerboseLog();
    [_tableControlPanel setContentOffset:CGPointMake(self.tableControlPanel.contentOffset.x, contentOffset.y) animated:animated];
    [_tableHeader setContentOffset:CGPointMake(contentOffset.x, self.tableHeader.contentOffset.y) animated:animated];
}

- (void)tableViewContentHolder:(TSTableViewContentHolder *)contentHolder willSelectRowAtPath:(NSIndexPath *)rowPath selectedCell:(NSInteger)cellIndex animated:(BOOL)animated
{
    VerboseLog();
    if(self.delegate && [self.delegate respondsToSelector:@selector(tableView:willSelectRowAtPath:selectedCell:animated:)])
    {
        [self.delegate tableView:self willSelectRowAtPath:rowPath selectedCell:cellIndex animated:animated];
    }
}

- (void)tableViewContentHolder:(TSTableViewContentHolder *)contentHolder didSelectRowAtPath:(NSIndexPath *)rowPath selectedCell:(NSInteger)cellIndex
{
    VerboseLog();
    if(self.delegate)
    {
        [self.delegate tableView:self didSelectRowAtPath:rowPath selectedCell:cellIndex];
    }
}

- (void)tableViewContentHolder:(TSTableViewContentHolder *)contentHolder willSelectColumnAtPath:(NSIndexPath *)columnPath animated:(BOOL)animated
{
    VerboseLog();
    if(self.delegate && [self.delegate respondsToSelector:@selector(tableView:willSelectColumnAtPath:animated:)])
    {
        [self.delegate tableView:self willSelectColumnAtPath:columnPath animated:animated];
    }
}

- (void)tableViewContentHolder:(TSTableViewContentHolder *)contentHolder didSelectColumnAtPath:(NSIndexPath *)columnPath
{
    VerboseLog();
    if(self.delegate && [self.delegate respondsToSelector:@selector(tableView:didSelectColumnAtPath:)])
    {
        [self.delegate tableView:self didSelectColumnAtPath:columnPath];
    }
}

#pragma mark - 

- (void)toggleExpandStateForRow:(NSIndexPath *)rowPath animated:(BOOL)animated
{
    VerboseLog();
    BOOL expand = ![_tableControlPanel isRowExpanded:rowPath];
    [self changeExpandStateForRow:rowPath toValue:expand animated:animated];
}

- (void)changeExpandStateForRow:(NSIndexPath *)rowPath toValue:(BOOL)expanded animated:(BOOL)animated
{
    VerboseLog();
    [_tableControlPanel changeExpandStateForRow:rowPath toValue:expanded animated:YES];
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

- (void)selectRowAtPath:(NSIndexPath *)rowPath animated:(BOOL)animated
{
    [_tableContentHolder selectRowAtPath:rowPath animated:animated];
}

- (void)resetRowSelectionWithAnimtaion:(BOOL)animated
{
    [_tableContentHolder resetRowSelectionWithAnimtaion:YES];
}

- (void)selectColumnAtPath:(NSIndexPath *)rowPath animated:(BOOL)animated
{
    [_tableContentHolder selectRowAtPath:rowPath animated:animated];
}

- (void)resetColumnSelectionWithAnimtaion:(BOOL)animated
{
    [_tableContentHolder resetColumnSelectionWithAnimtaion:YES];
}

- (NSIndexPath *)pathToSelectedRow
{
    return [_tableContentHolder pathToSelectedRow];
}

- (NSIndexPath *)pathToSelectedColumn
{
    return [_tableContentHolder pathToSelectedColumn];
}

#pragma mark - TSTableViewAppearanceCoordinator

- (BOOL)isRowExpanded:(NSIndexPath *)indexPath
{
    return [_tableControlPanel isRowExpanded:indexPath];
}

- (BOOL)isRowVisible:(NSIndexPath *)indexPath
{
    return [_tableControlPanel isRowVisible:indexPath];
}

- (UIImage *)controlPanelExpandItemNormalBackgroundImage
{
    return _expandItemNormalBackgroundImage;
}

- (UIImage *)controlPanelExpandItemSelectedBackgroundImage
{
    return _expandItemSelectedBackgroundImage;
}

- (UIImage *)controlPanelExpandSectionBackgroundImage
{
    return _expandSectionBackgroundImage;
}

- (BOOL)lineNumbersAreHidden
{
    return _lineNumbersHidden;
}

- (BOOL)highlightControlsOnTap
{
    return _highlightControlsOnTap;
}

- (UIColor *)lineNumbersColor
{
    return _lineNumbersColor;
}

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

- (CGFloat)tableHeight
{
    VerboseLog();
    return [_tableControlPanel tableHeight];
}

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

- (CGFloat)offsetForColumnAtPath:(NSIndexPath *)columnPath
{
    VerboseLog();
    return [_tableHeader offsetForColumnAtPath:columnPath];
}


- (TSTableViewCell *)cellViewForRowAtPath:(NSIndexPath *)indexPath cellIndex:(NSInteger)index
{
    return [self tableView:self cellViewForRowAtPath:indexPath cellIndex:index];
}

- (TSTableViewHeaderSectionView *)headerSectionViewForColumnAtPath:(NSIndexPath *)indexPath
{
    return [self tableView:self headerSectionViewForColumnAtPath:indexPath];
}

#pragma mark - Modify content

- (void)insertRowAtPath:(NSIndexPath *)path animated:(BOOL)animated
{
    [_tableControlPanel insertRowAtPath:path animated:animated];
    [_tableContentHolder insertRowAtPath:path animated:animated];
    [TSUtils performViewAnimationBlock:^{
        [self updateLayout];
    } withCompletion:nil animated:animated];
}

- (void)removeRowAtPath:(NSIndexPath *)path animated:(BOOL)animated
{
    [_tableControlPanel removeRowAtPath:path animated:animated];
    [_tableContentHolder removeRowAtPath:path animated:animated];
    [TSUtils performViewAnimationBlock:^{
        [self updateLayout];
    } withCompletion:nil animated:animated];
}

- (void)updateRowAtPath:(NSIndexPath *)path
{
    [_tableContentHolder updateRowAtPath:path];
}

- (void)insertRowsAtPathes:(NSArray *)pathes animated:(BOOL)animated
{
     NSAssert(FALSE, @"Not implemented");
}

- (void)updateRowsAtPathes:(NSArray *)pathes animated:(BOOL)animated
{
    NSAssert(FALSE, @"Not implemented");
}

- (void)removeRowsAtPathes:(NSArray *)pathes animated:(BOOL)animated
{
     NSAssert(FALSE, @"Not implemented");
}

/**************************************************************************************************************************************/
#pragma mark - Create background images

- (NSString *)keyForColor:(UIColor *)color
{
    if(!color) return @"";
    const CGFloat *rgba = CGColorGetComponents(color.CGColor);
    return [NSString stringWithFormat:@"%d%d%d%d", (char)(rgba[0] * 255), (char)(rgba[1] * 255), (char)(rgba[2] * 255), (char)(rgba[3] * 255)];
}

- (UIImage *)cellBackgroundImageWithTintColor:(UIColor *)color
{
    NSString *key = [self keyForColor:color];
    UIImage *image = _cachedCellBackgroundImages[key];
    if(!image)
    {
        if(_tableStyle == kTSTableViewStyleDark)
            image = [self darkCellBackgroundImageWithTintColor:color];
        else
            image = [self lightCellBackgroundImageWithTintColor:color];
        _cachedCellBackgroundImages[key] = image;
    }
    return image;
}

- (UIImage *)headerSectionBackgroundImageWithTintColor:(UIColor *)color
{
    NSString *key = [self keyForColor:color];
    UIImage *image = _cachedHeaderSectionBackgroundImages[key];
    if(!image)
    {
        if(_tableStyle == kTSTableViewStyleDark)
            image = [self darkHeaderSectionBackgroundImageWithTintColor:color];
        else
            image = [self lightHeaderSectionBackgroundImageWithTintColor:color];
        _cachedHeaderSectionBackgroundImages[key] = image;
    }
    return image;
}

- (UIImage *)expandSectionBackgroundImage
{
    if(!_cachedExpandSectionBackgroundImage)
    {
        if(_tableStyle == kTSTableViewStyleDark)
            _cachedExpandSectionBackgroundImage = [self darkExpandSectionBackgroundImage];
        else
            _cachedExpandSectionBackgroundImage = [self lightExpandSectionBackgroundImage];
    }
    return _cachedExpandSectionBackgroundImage;
}

- (UIImage *)expandItemNormalBackgroundImage
{
    if(!_cachedExpandItemNormalBackgroundImage)
    {
        if(_tableStyle == kTSTableViewStyleDark)
            _cachedExpandItemNormalBackgroundImage = [self darkExpandItemNormalBackgroundImage];
        else
            _cachedExpandItemNormalBackgroundImage = [self lightExpandItemNormalBackgroundImage];
    }
    return _cachedExpandItemNormalBackgroundImage;
}

- (UIImage *)expandItemSelectedBackgroundImage
{
    if(!_cachedExpandItemSelectedBackgroundImage)
    {
        if(_tableStyle == kTSTableViewStyleDark)
            _cachedExpandItemSelectedBackgroundImage = [self darkExpandItemSelectedBackgroundImage];
        else
            _cachedExpandItemSelectedBackgroundImage = [self lightExpandItemSelectedBackgroundImage];
    }
    return _cachedExpandItemSelectedBackgroundImage;
}

- (UIImage *)generalBackgroundImage
{
    if(!_cachedGeneralBackgroundImage)
    {
        if(_tableStyle == kTSTableViewStyleDark)
            _cachedGeneralBackgroundImage = [self darkGeneralBackgroundImage];
        else
            _cachedGeneralBackgroundImage = [self lightGeneralBackgroundImage];
    }
    return _cachedGeneralBackgroundImage;
}

#pragma mark - Create background images for Light style

- (UIImage *)lightCellBackgroundImageWithTintColor:(UIColor *)color
{
    UIColor *topColor = (color ? color : [UIColor whiteColor]);
    UIColor *bottomColor = (color ? color : [UIColor whiteColor]);
    UIColor *topBorderColor = [UIColor whiteColor];
    UIColor *bottomBorderColor = [UIColor colorWithWhite:0.7f alpha:1.0f];
    UIColor *leftBorderColor = [UIColor whiteColor];
    UIColor *rightBorderColor = [UIColor colorWithWhite:0.7f alpha:1.0f];
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 20.0f, 20.0f);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [TSUtils drawLinearGradientInContext:context
                                    rect:rect
                              startColor:topColor.CGColor
                                endColor:bottomColor.CGColor];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(0, 0)
                      endPoint:CGPointMake(rect.size.width - 0.5f, 0)
                         color:topBorderColor.CGColor
                     lineWidth:0.5];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(0, rect.size.height - 0.5f)
                      endPoint:CGPointMake(rect.size.width - 0.5f, rect.size.height - 0.5f)
                         color:bottomBorderColor.CGColor
                     lineWidth:0.5];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(rect.size.width - 0.5f, 0)
                      endPoint:CGPointMake(rect.size.width - 0.5f, rect.size.height - 0.5f)
                         color:rightBorderColor.CGColor
                     lineWidth:0.5];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(0, 0)
                      endPoint:CGPointMake(0, rect.size.height - 0.5f)
                         color:leftBorderColor.CGColor
                     lineWidth:0.5];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [image stretchableImageWithLeftCapWidth:rect.size.width/2 topCapHeight:rect.size.height/2];
    //return [image resizableImageWithCapInsets:UIEdgeInsetsMake(rect.size.height/2, rect.size.width/2, rect.size.height/2, rect.size.width/2)];
}

- (UIImage *)lightHeaderSectionBackgroundImageWithTintColor:(UIColor *)color
{
    UIColor *topColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
    UIColor *bottomColor = (color ? color : [UIColor colorWithWhite:0.9f alpha:1.0f]);
    UIColor *topBorderColor = [UIColor whiteColor];
    UIColor *bottomBorderColor = [UIColor colorWithWhite:0.7f alpha:1.0f];
    UIColor *leftBorderColor = [UIColor whiteColor];
    UIColor *rightBorderColor = [UIColor colorWithWhite:0.7f alpha:1.0f];
    UIColor *lineColor = [UIColor colorWithWhite:0.0f alpha:0.1f];
    
    CGFloat lineWidth = 8;
    CGRect rect = CGRectMake(0.0f, 0.0f, 20.0f, 20.0f);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [TSUtils drawLinearGradientInContext:context
                                    rect:rect
                              startColor:topColor.CGColor
                                endColor:bottomColor.CGColor];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(0, 0)
                      endPoint:CGPointMake(rect.size.width - 0.5f, 0)
                         color:topBorderColor.CGColor
                     lineWidth:0.5];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(0, rect.size.height - 0.5f)
                      endPoint:CGPointMake(rect.size.width - 0.5f, rect.size.height - 0.5f)
                         color:bottomBorderColor.CGColor
                     lineWidth:0.5];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(rect.size.width - 0.5f, 0)
                      endPoint:CGPointMake(rect.size.width - 0.5f, rect.size.height - 0.5f)
                         color:rightBorderColor.CGColor
                     lineWidth:0.5];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(0, 0)
                      endPoint:CGPointMake(0, rect.size.height - 0.5f)
                         color:leftBorderColor.CGColor
                     lineWidth:0.5];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(rect.size.width - lineWidth/2, 0)
                      endPoint:CGPointMake(rect.size.width - lineWidth/2, rect.size.height - 0.5f)
                         color:lineColor.CGColor
                     lineWidth:lineWidth];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [image stretchableImageWithLeftCapWidth:rect.size.width/2 topCapHeight:rect.size.height/2];
    //return [image resizableImageWithCapInsets:UIEdgeInsetsMake(rect.size.height/2, rect.size.width/2, rect.size.height/2, rect.size.width/2)];
}

- (UIImage *)lightExpandSectionBackgroundImage
{
    UIColor *topColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
    UIColor *bottomColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    UIColor *topBorderColor = [UIColor whiteColor];
    UIColor *bottomBorderColor = [UIColor colorWithWhite:0.7f alpha:1.0f];
    UIColor *leftBorderColor = [UIColor whiteColor];
    UIColor *rightBorderColor = [UIColor colorWithWhite:0.7f alpha:1.0f];
    UIColor *lineColor = [UIColor colorWithWhite:0.0f alpha:0.1f];
    
    CGFloat lineWidth = 8;
    CGRect rect = CGRectMake(0.0f, 0.0f, 20.0f, 20.0f);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [TSUtils drawLinearGradientInContext:context
                                    rect:rect
                              startColor:topColor.CGColor
                                endColor:bottomColor.CGColor];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(0, 0)
                      endPoint:CGPointMake(rect.size.width - 0.5f, 0)
                         color:topBorderColor.CGColor
                     lineWidth:0.5];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(0, rect.size.height - 0.5f)
                      endPoint:CGPointMake(rect.size.width - 0.5f, rect.size.height - 0.5f)
                         color:bottomBorderColor.CGColor
                     lineWidth:0.5];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(rect.size.width - 0.5f, 0)
                      endPoint:CGPointMake(rect.size.width - 0.5f, rect.size.height - 0.5f)
                         color:rightBorderColor.CGColor
                     lineWidth:0.5];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(0, 0)
                      endPoint:CGPointMake(0, rect.size.height - 0.5f)
                         color:leftBorderColor.CGColor
                     lineWidth:0.5];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(lineWidth/2, 0)
                      endPoint:CGPointMake(lineWidth/2, rect.size.height - 0.5f)
                         color:lineColor.CGColor
                     lineWidth:lineWidth];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [image stretchableImageWithLeftCapWidth:rect.size.width/2 topCapHeight:rect.size.height/2];
    //return [image resizableImageWithCapInsets:UIEdgeInsetsMake(rect.size.height/2, rect.size.width/2, rect.size.height/2, rect.size.width/2)];
}


- (UIImage *)lightExpandItemNormalBackgroundImage
{
    CGFloat expandItemWidth = [self widthForExpandItem];
    CGFloat rowHeight = [self heightForRow];
    CGRect rect = CGRectMake(0.0f, 0.0f, 2 * expandItemWidth, rowHeight);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat lineWithd = 8;
    NSArray *points = @[
                        [NSValue valueWithCGPoint:CGPointMake(lineWithd + 1, CGRectGetMidY(rect) - lineWithd/2)],
                        [NSValue valueWithCGPoint:CGPointMake(lineWithd + expandItemWidth - 5, CGRectGetMidY(rect) - lineWithd/2)],
                        [NSValue valueWithCGPoint:CGPointMake(lineWithd + expandItemWidth, CGRectGetMidY(rect))],
                        
                        [NSValue valueWithCGPoint:CGPointMake(lineWithd + expandItemWidth - 5, CGRectGetMidY(rect) + lineWithd/2)],
                        [NSValue valueWithCGPoint:CGPointMake(lineWithd + 1, CGRectGetMidY(rect) + lineWithd/2)]
                        ];
    
    [TSUtils drawPolygonInContext:context points:points
                        fillColor:[UIColor colorWithWhite:0 alpha:0.1].CGColor
                      strokeColor:[UIColor clearColor].CGColor
                       strokeSize:0];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)lightExpandItemSelectedBackgroundImage
{
    CGFloat expandItemWidth = [self widthForExpandItem];
    CGFloat rowHeight = [self heightForRow];
    CGRect rect = CGRectMake(0.0f, 0.0f, 2 * expandItemWidth, rowHeight);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat lineWithd = 8;
    
    NSArray *points = @[
                        [NSValue valueWithCGPoint:CGPointMake(expandItemWidth + lineWithd/2, CGRectGetMaxY(rect) - 2)],
                        [NSValue valueWithCGPoint:CGPointMake(expandItemWidth - lineWithd/2, CGRectGetMaxY(rect) - 14)],
                        [NSValue valueWithCGPoint:CGPointMake(expandItemWidth + 3 * lineWithd/2, CGRectGetMaxY(rect) - 14)]
                        ];
    
    [TSUtils drawPolygonInContext:context points:points
                        fillColor:[UIColor colorWithWhite:0 alpha:0.1].CGColor
                      strokeColor:[UIColor clearColor].CGColor
                       strokeSize:0];
    
    NSArray *points1 = @[
                         [NSValue valueWithCGPoint:CGPointMake(expandItemWidth, CGRectGetMaxY(rect))],
                         [NSValue valueWithCGPoint:CGPointMake(expandItemWidth, CGRectGetMaxY(rect) - 6)],
                         [NSValue valueWithCGPoint:CGPointMake(expandItemWidth + lineWithd/2, CGRectGetMaxY(rect))],
                         [NSValue valueWithCGPoint:CGPointMake(expandItemWidth + lineWithd, CGRectGetMaxY(rect) - 6)],
                         [NSValue valueWithCGPoint:CGPointMake(expandItemWidth + lineWithd, CGRectGetMaxY(rect))]
                         ];
    
    [TSUtils drawPolygonInContext:context points:points1
                        fillColor:[UIColor colorWithWhite:0 alpha:0.1].CGColor
                      strokeColor:[UIColor clearColor].CGColor
                       strokeSize:0];
    
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)lightGeneralBackgroundImage
{
    UIColor *topColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
    UIColor *bottomColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    UIColor *topBorderColor = [UIColor whiteColor];
    UIColor *bottomBorderColor = [UIColor colorWithWhite:0.7f alpha:1.0f];
    UIColor *leftBorderColor = [UIColor whiteColor];
    UIColor *rightBorderColor = [UIColor colorWithWhite:0.7f alpha:1.0f];
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 20.0f, 20.0f);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [TSUtils drawLinearGradientInContext:context
                                    rect:rect
                              startColor:topColor.CGColor
                                endColor:bottomColor.CGColor];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(0, 0)
                      endPoint:CGPointMake(rect.size.width - 0.5f, 0)
                         color:topBorderColor.CGColor
                     lineWidth:0.5];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(0, rect.size.height - 0.5f)
                      endPoint:CGPointMake(rect.size.width - 0.5f, rect.size.height - 0.5f)
                         color:bottomBorderColor.CGColor
                     lineWidth:0.5];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(rect.size.width - 0.5f, 0)
                      endPoint:CGPointMake(rect.size.width - 0.5f, rect.size.height - 0.5f)
                         color:rightBorderColor.CGColor
                     lineWidth:0.5];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(0, 0)
                      endPoint:CGPointMake(0, rect.size.height - 0.5f)
                         color:leftBorderColor.CGColor
                     lineWidth:0.5];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [image stretchableImageWithLeftCapWidth:rect.size.width/2 topCapHeight:rect.size.height/2];
    //return [image resizableImageWithCapInsets:UIEdgeInsetsMake(rect.size.height/2, rect.size.width/2, rect.size.height/2, rect.size.width/2)];
}

#pragma mark - Create background images for Dark Style

- (UIImage *)darkCellBackgroundImageWithTintColor:(UIColor *)color
{
    UIColor *topColor = (color ? color : [UIColor colorWithWhite:0.2f alpha:1.0f]);
    UIColor *bottomColor = (color ? color : [UIColor colorWithWhite:0.15f alpha:1.0f]);
    UIColor *topBorderColor =   [UIColor colorWithWhite:0.4f alpha:1.0f];
    UIColor *bottomBorderColor =[UIColor colorWithWhite:0.05f alpha:1.0f];
    UIColor *leftBorderColor =  [UIColor colorWithWhite:0.4f alpha:1.0f];
    UIColor *rightBorderColor = [UIColor colorWithWhite:0.05f alpha:1.0f];
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 20.0f, 20.0f);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [TSUtils drawLinearGradientInContext:context
                                    rect:rect
                              startColor:topColor.CGColor
                                endColor:bottomColor.CGColor];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(0, 0)
                      endPoint:CGPointMake(rect.size.width - 0.5f, 0)
                         color:topBorderColor.CGColor
                     lineWidth:0.5];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(0, rect.size.height - 0.5f)
                      endPoint:CGPointMake(rect.size.width - 0.5f, rect.size.height - 0.5f)
                         color:bottomBorderColor.CGColor
                     lineWidth:0.5];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(rect.size.width - 0.5f, 0)
                      endPoint:CGPointMake(rect.size.width - 0.5f, rect.size.height - 0.5f)
                         color:rightBorderColor.CGColor
                     lineWidth:0.5];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(0, 0)
                      endPoint:CGPointMake(0, rect.size.height - 0.5f)
                         color:leftBorderColor.CGColor
                     lineWidth:0.5];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [image stretchableImageWithLeftCapWidth:rect.size.width/2 topCapHeight:rect.size.height/2];
    //return [image resizableImageWithCapInsets:UIEdgeInsetsMake(rect.size.height/2, rect.size.width/2, rect.size.height/2, rect.size.width/2)];
}

- (UIImage *)darkHeaderSectionBackgroundImageWithTintColor:(UIColor *)color
{
    UIColor *topColor =         [UIColor colorWithWhite:0.2f alpha:1.0f];
    UIColor *bottomColor =   (color ? color :  [UIColor colorWithWhite:0.15f alpha:1.0f]);
    UIColor *topBorderColor =   [UIColor colorWithWhite:0.4f alpha:1.0f];
    UIColor *bottomBorderColor =[UIColor colorWithWhite:0.05f alpha:1.0f];
    UIColor *leftBorderColor =  [UIColor colorWithWhite:0.4f alpha:1.0f];
    UIColor *rightBorderColor = [UIColor colorWithWhite:0.05f alpha:1.0f];
    UIColor *lineColor = [UIColor colorWithWhite:0.0f alpha:0.1f];
    
    CGFloat lineWidth = 8;
    CGRect rect = CGRectMake(0.0f, 0.0f, 20.0f, 20.0f);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [TSUtils drawLinearGradientInContext:context
                                    rect:rect
                              startColor:topColor.CGColor
                                endColor:bottomColor.CGColor];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(0, 0)
                      endPoint:CGPointMake(rect.size.width - 0.5f, 0)
                         color:topBorderColor.CGColor
                     lineWidth:0.5];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(0, rect.size.height - 0.5f)
                      endPoint:CGPointMake(rect.size.width - 0.5f, rect.size.height - 0.5f)
                         color:bottomBorderColor.CGColor
                     lineWidth:0.5];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(rect.size.width - 0.5f, 0)
                      endPoint:CGPointMake(rect.size.width - 0.5f, rect.size.height - 0.5f)
                         color:rightBorderColor.CGColor
                     lineWidth:0.5];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(0, 0)
                      endPoint:CGPointMake(0, rect.size.height - 0.5f)
                         color:leftBorderColor.CGColor
                     lineWidth:0.5];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(rect.size.width - lineWidth/2, 0)
                      endPoint:CGPointMake(rect.size.width - lineWidth/2, rect.size.height - 0.5f)
                         color:lineColor.CGColor
                     lineWidth:lineWidth];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [image stretchableImageWithLeftCapWidth:rect.size.width/2 topCapHeight:rect.size.height/4];
    //return [image resizableImageWithCapInsets:UIEdgeInsetsMake(2, rect.size.width/2, 2, rect.size.width/2) resizingMode:UIImageResizingModeStretch];
}

- (UIImage *)darkExpandSectionBackgroundImage
{
    UIColor *topColor =         [UIColor colorWithWhite:0.2f alpha:1.0f];
    UIColor *bottomColor =      [UIColor colorWithWhite:0.15f alpha:1.0f];
    UIColor *topBorderColor =   [UIColor colorWithWhite:0.3f alpha:1.0f];
    UIColor *bottomBorderColor =[UIColor colorWithWhite:0.05f alpha:1.0f];
    UIColor *leftBorderColor =  [UIColor colorWithWhite:0.15f alpha:1.0f];
    UIColor *rightBorderColor = [UIColor colorWithWhite:0.05f alpha:1.0f];
    UIColor *lineColor = [UIColor colorWithWhite:0 alpha:0.15f];
    
    CGFloat lineWidth = 8;
    CGRect rect = CGRectMake(0.0f, 0.0f, 20.0f, 20.0f);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [TSUtils drawLinearGradientInContext:context
                                    rect:rect
                              startColor:topColor.CGColor
                                endColor:bottomColor.CGColor];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(0, 0)
                      endPoint:CGPointMake(rect.size.width - 0.5f, 0)
                         color:topBorderColor.CGColor
                     lineWidth:0.5];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(0, rect.size.height - 0.5f)
                      endPoint:CGPointMake(rect.size.width - 0.5f, rect.size.height - 0.5f)
                         color:bottomBorderColor.CGColor
                     lineWidth:0.5];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(rect.size.width - 0.5f, 0)
                      endPoint:CGPointMake(rect.size.width - 0.5f, rect.size.height - 0.5f)
                         color:rightBorderColor.CGColor
                     lineWidth:0.5];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(0, 0)
                      endPoint:CGPointMake(0, rect.size.height - 0.5f)
                         color:leftBorderColor.CGColor
                     lineWidth:0.5];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(lineWidth/2, 0)
                      endPoint:CGPointMake(lineWidth/2, rect.size.height - 0.5f)
                         color:lineColor.CGColor
                     lineWidth:lineWidth];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [image stretchableImageWithLeftCapWidth:rect.size.width/2 topCapHeight:rect.size.height/2];
    //return [image resizableImageWithCapInsets:UIEdgeInsetsMake(rect.size.height/2, rect.size.width/2, rect.size.height/2, rect.size.width/2)];
}


- (UIImage *)darkExpandItemNormalBackgroundImage
{
    CGFloat expandItemWidth = [self widthForExpandItem];
    CGFloat rowHeight = [self heightForRow];
    CGRect rect = CGRectMake(0.0f, 0.0f, 2 * expandItemWidth, rowHeight);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat lineWithd = 8;
    NSArray *points = @[
                        [NSValue valueWithCGPoint:CGPointMake(lineWithd , CGRectGetMidY(rect) - lineWithd/2)],
                        [NSValue valueWithCGPoint:CGPointMake(lineWithd + expandItemWidth, CGRectGetMidY(rect) - lineWithd/2)],
                        [NSValue valueWithCGPoint:CGPointMake(lineWithd + expandItemWidth, CGRectGetMidY(rect) + lineWithd/2)],
                        [NSValue valueWithCGPoint:CGPointMake(lineWithd , CGRectGetMidY(rect) + lineWithd/2)]
                        ];
    
    CGMutablePathRef path = CGPathCreateMutable();
    for(int i = 0; i < points.count;  ++i)
    {
        NSValue *pointVal = points[i];
        CGPoint point = [pointVal CGPointValue];
        if(i == 0)
            CGPathMoveToPoint(path, NULL, point.x, point.y);
        else
            CGPathAddLineToPoint(path, NULL, point.x, point.y);
    }
    CGFloat radius = 8;
    CGPathAddEllipseInRect(path, NULL, CGRectMake(expandItemWidth + lineWithd/2 - radius, CGRectGetMidY(rect) - radius, 2*radius, 2*radius));
    
    CGPathCloseSubpath(path);
    
    
    CGContextSaveGState(context);
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0 alpha:0.15].CGColor);
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:1 alpha:0.1].CGColor);
    CGFloat innerRadius = 3.5f;
    CGContextAddEllipseInRect(context, CGRectMake(expandItemWidth + lineWithd/2 - innerRadius, CGRectGetMidY(rect) - innerRadius, 2*innerRadius, 2*innerRadius));
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    CGPathRelease(path);
    
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)darkExpandItemSelectedBackgroundImage
{
    CGFloat expandItemWidth = [self widthForExpandItem];
    CGFloat rowHeight = [self heightForRow];
    CGRect rect = CGRectMake(0.0f, 0.0f, 2 * expandItemWidth, rowHeight);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat lineWithd = 8;
    NSArray *points = @[
                        [NSValue valueWithCGPoint:CGPointMake(expandItemWidth, CGRectGetMaxY(rect))],
                        [NSValue valueWithCGPoint:CGPointMake(expandItemWidth, CGRectGetMidY(rect))],
                        [NSValue valueWithCGPoint:CGPointMake(expandItemWidth + lineWithd, CGRectGetMidY(rect))],
                        [NSValue valueWithCGPoint:CGPointMake(expandItemWidth + lineWithd, CGRectGetMaxY(rect))]
                        ];
    
    CGMutablePathRef path = CGPathCreateMutable();
    for(int i = 0; i < points.count;  ++i)
    {
        NSValue *pointVal = points[i];
        CGPoint point = [pointVal CGPointValue];
        if(i == 0)
            CGPathMoveToPoint(path, NULL, point.x, point.y);
        else
            CGPathAddLineToPoint(path, NULL, point.x, point.y);
    }
    CGFloat radius = 8;
    CGPathAddEllipseInRect(path, NULL, CGRectMake(expandItemWidth + lineWithd/2 - radius, CGRectGetMidY(rect) - radius, 2*radius, 2*radius));
    
    CGPathCloseSubpath(path);
    
    
    CGContextSaveGState(context);
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0 alpha:0.15].CGColor);
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.185 alpha:1].CGColor);
    CGFloat innerRadius = 3.5f;
    CGContextAddEllipseInRect(context, CGRectMake(expandItemWidth + lineWithd/2 - innerRadius, CGRectGetMidY(rect) - innerRadius, 2*innerRadius, 2*innerRadius));
    CGContextFillPath(context);
    CGContextRestoreGState(context);
    
    CGPathRelease(path);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)darkGeneralBackgroundImage
{
    UIColor *topColor =         [UIColor colorWithWhite:0.2f alpha:1.0f];
    UIColor *bottomColor =      [UIColor colorWithWhite:0.15f alpha:1.0f];
    UIColor *topBorderColor =   [UIColor colorWithWhite:0.4f alpha:1.0f];
    UIColor *bottomBorderColor =[UIColor colorWithWhite:0.05f alpha:1.0f];
    UIColor *leftBorderColor =  [UIColor colorWithWhite:0.4f alpha:1.0f];
    UIColor *rightBorderColor = [UIColor colorWithWhite:0.05f alpha:1.0f];
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 20.0f, 20.0f);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [TSUtils drawLinearGradientInContext:context
                                    rect:rect
                              startColor:topColor.CGColor
                                endColor:bottomColor.CGColor];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(0, 0)
                      endPoint:CGPointMake(rect.size.width - 0.5f, 0)
                         color:topBorderColor.CGColor
                     lineWidth:0.5];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(0, rect.size.height - 0.5f)
                      endPoint:CGPointMake(rect.size.width - 0.5f, rect.size.height - 0.5f)
                         color:bottomBorderColor.CGColor
                     lineWidth:0.5];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(rect.size.width - 0.5f, 0)
                      endPoint:CGPointMake(rect.size.width - 0.5f, rect.size.height - 0.5f)
                         color:rightBorderColor.CGColor
                     lineWidth:0.5];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(0, 0)
                      endPoint:CGPointMake(0, rect.size.height - 0.5f)
                         color:leftBorderColor.CGColor
                     lineWidth:0.5];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [image stretchableImageWithLeftCapWidth:rect.size.width/2 topCapHeight:rect.size.height/2];
    //return [image resizableImageWithCapInsets:UIEdgeInsetsMake(rect.size.height/2, rect.size.width/2, rect.size.height/2, rect.size.width/2)];
}

#pragma mark - TSTableViewDataSource

//mark:
/*
 根据path取行头内容
 */
- (NSString *)rowHead:(NSIndexPath *)indexPath
{
    TSRow *row;
    NSMutableArray *rows = _rows;
    for(int i = 0; i < indexPath.length;  ++i)
    {
        NSInteger index = [indexPath indexAtPosition:i];
        row = rows[index];
        rows = row.subrows;
    }
    return [row rowHead];
}

- (NSInteger)numberOfColumns
{
    VerboseLog();
    return [self calcNumberOfColumns:_columns];
}

- (NSInteger)calcNumberOfColumns:(NSArray *)columns
{
    VerboseLog();
    NSInteger columnsCount = columns.count;
    for(TSColumn *column in columns)
    {
        if(column.subcolumns.count)
        {
            columnsCount += [self calcNumberOfColumns:column.subcolumns] - 1;
        }
    }
    return columnsCount;
}

- (NSInteger)numberOfRows
{
    VerboseLog();
    return [self calcNumberOfRows:_rows];
}

- (NSInteger)calcNumberOfRows:(NSArray *)rows
{
    VerboseLog();
    NSInteger rowsCount = rows.count;
    for(TSRow *row in rows)
    {
        rowsCount += [self calcNumberOfRows:row.subrows];
    }
    return rowsCount;
}

- (NSInteger)numberOfColumnsAtPath:(NSIndexPath *)indexPath
{
    VerboseLog(@"%@", indexPath);
    if(indexPath == nil)
        return _columns.count;
    TSColumn *column = [self columnAtPath:indexPath];
    return column.subcolumns.count;
}

- (NSInteger)numberOfRowsAtPath:(NSIndexPath *)indexPath
{
    VerboseLog();
    if(indexPath == nil)
        return _rows.count;
    TSRow *row = [self rowAtPath:indexPath];
    return row.subrows.count;
}

- (CGFloat)heightForRowAtPath:(NSIndexPath *)indexPath
{
    VerboseLog();
    return _heightForRow;
}

- (CGFloat)heightForHeaderSectionAtPath:(NSIndexPath *)columnPath
{
    VerboseLog();
    TSColumn *columnInfo = [self columnAtPath:columnPath];
    return columnInfo.headerHeight;
}

- (CGFloat)defaultWidthForColumnAtIndex:(NSInteger)index
{
    TSColumn *columnInfo = [self columnAtIndex:index];
    return columnInfo.defWidth;
}

- (CGFloat)minimalWidthForColumnAtIndex:(NSInteger)index
{
    TSColumn *columnInfo = [self columnAtIndex:index];
    return columnInfo.minWidth;
}

- (CGFloat)maximalWidthForColumnAtIndex:(NSInteger)index
{
    TSColumn *columnInfo = [self columnAtIndex:index];
    return columnInfo.maxWidth;
}

- (CGFloat)widthForExpandItem
{
    VerboseLog();
    return _widthForExpandItem;
}

//mark: 单元格点击事件处理。调用协议中的方法，让其动作给实现协议的类处理。
-(void)tapTableViewCell:(UITapGestureRecognizer *)recognizer
{
    TSTableViewCell *cell = (TSTableViewCell*)recognizer.view;
    NSString *value = cell.textLabel.text;
    
    [self.delegate tableView:self tapCellView:cell cellValue:value];
    
    NSIndexPath *rowPath = cell.rowPath;
    NSString *pathstr = rowPath.description;
    NSString *pre = @"path =";
    NSString *suff = @"}";
    NSRange preRange = [pathstr rangeOfString:pre];
    NSUInteger preIndex = preRange.location + preRange.length;
    NSRange suffRange = [pathstr rangeOfString:suff];
    NSUInteger suffIndex = suffRange.location;
    NSRange rang = NSMakeRange(preIndex+1, suffIndex-preIndex-1);
    NSString *row = [pathstr substringWithRange:rang];
    NSInteger col = cell.colIndex;
    
    [self.delegate cellClickWithRowPath:row colIndex:col cellValue:value];
}

- (TSTableViewCell *)tableView:(TSTableView *)tableView cellViewForRowAtPath:(NSIndexPath *)indexPath cellIndex:(NSInteger)index
{
    VerboseLog();
    NSString * const kReuseCellId = @"TSTableViewCell";
    TSCell *cellInfo = [self cellAtRowPath:indexPath atIndex:index];
    TSTableViewCell *cell =  [tableView dequeueReusableCellViewWithIdentifier:kReuseCellId];
    if(!cell){
        cell = [[TSTableViewCell alloc] initWithReuseIdentifier:kReuseCellId];
        cell.rowPath = indexPath;
        cell.colIndex = index;
        
        //mark: add TSTableViewCell UITapGestureRecognizer
        UITapGestureRecognizer *tapCell = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTableViewCell:)];
        [cell addGestureRecognizer:tapCell];
    }
    
    TSColumn *columnInfo = [self columnAtIndex:index];
    if(columnInfo.titleColor)
    {
        cell.textLabel.textColor = columnInfo.titleColor;
    }
    else
    {
        if(_tableStyle == kTSTableViewStyleDark)
            cell.textLabel.textColor = [UIColor grayColor];
        else
            cell.textLabel.textColor = [UIColor darkGrayColor];
    }
    
    if(cellInfo.value)
    {
        cell.textLabel.text = [cellInfo.value description];
        cell.textLabel.textAlignment = cellInfo.textAlignment;
        if(cellInfo.textColor)
            cell.textLabel.textColor = cellInfo.textColor;
    }
    if(cellInfo.details)
    {
        cell.detailsLabel.text = cellInfo.details;
        cell.detailsLabel.textAlignment = cellInfo.textAlignment;
        if(cellInfo.detailsColor)
            cell.detailsLabel.textColor = cellInfo.detailsColor;
    }
    if(cellInfo.icon)
        cell.iconView.image = cellInfo.icon;
    
    // Color values and proportions below just came up from my head, there is no special logic for this... it just looks fine, that's all
    if(columnInfo.color)
    {
        CGFloat color = 0.9f + 0.1f * (1 - (indexPath.length - 1)/(float)tableView.maxNestingLevel);
        CGColorRef colorRef = columnInfo.color.CGColor;
        const CGFloat *rgb = CGColorGetComponents(colorRef);
        cell.backgroundImageView.image = [self cellBackgroundImageWithTintColor:[UIColor colorWithRed:color * rgb[0]  green:color * rgb[1] blue:color * rgb[2] alpha:1]];
    }
    else
    {
        CGFloat color;
        if(_tableStyle == kTSTableViewStyleDark)
            color = 0.16f + 0.04f * (1 - (indexPath.length - 1)/(float)tableView.maxNestingLevel);
        else
            color = 0.9f + 0.1f * (1 - (indexPath.length - 1)/(float)tableView.maxNestingLevel);
        cell.backgroundImageView.image = [self cellBackgroundImageWithTintColor:[UIColor colorWithWhite:color alpha:1]];
    }
    return cell;
}

- (TSTableViewHeaderSectionView *)tableView:(TSTableView *)tableView headerSectionViewForColumnAtPath:(NSIndexPath *)indexPath
{
    VerboseLog();
    TSColumn *column = [self columnAtPath:indexPath];
    TSTableViewHeaderSectionView *section = [[TSTableViewHeaderSectionView alloc] init];
    
    if(_tableStyle == kTSTableViewStyleDark)
    {
        section.textLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        section.textLabel.textColor = [UIColor grayColor];
    }
    else
    {
        section.textLabel.textColor = [UIColor darkGrayColor];
    }
    section.backgroundImageView.image = [self headerSectionBackgroundImageWithTintColor:column.color];
    
    if(column.title)
    {
        section.textLabel.text = column.title;
        section.textLabel.textAlignment = column.textAlignment;
    }
    if(column.subtitle)
    {
        section.detailsLabel.text = column.subtitle;
        section.detailsLabel.textAlignment = column.textAlignment;
    }
    if(column.icon)
        section.iconView.image = column.icon;
    if(column.titleColor)
        section.textLabel.textColor = column.titleColor;
    if(column.subtitleColor)
        section.detailsLabel.textColor = column.subtitleColor;
    if(column.titleFontSize)
        section.textLabel.font = [UIFont boldSystemFontOfSize:column.titleFontSize];
    if(column.subtitleFontSize)
        section.detailsLabel.font = [UIFont boldSystemFontOfSize:column.subtitleFontSize];
    
    return section;
}


- (void)setColumns:(NSArray *)columns andRows:(NSArray *)rows
{
    VerboseLog();
    [_columns removeAllObjects];
    [_bottomEndColumns removeAllObjects];
    [_rows removeAllObjects];
    
    for(id columnInfo in columns)
    {
        if([columnInfo isKindOfClass:[TSColumn class]])
        {
            [_columns addObject:columnInfo];
        }
        else if([columnInfo isKindOfClass:[NSString class]])
        {
            [_columns addObject:[[TSColumn alloc] initWithTitle:columnInfo]];
        }
        else if([columnInfo isKindOfClass:[NSDictionary class]])
        {
            [_columns addObject:[TSColumn columnWithDictionary:columnInfo]];
        }
        else
        {
            NSAssert(FALSE, @"Type is not supported");
        }
        [self addLeafColumnsFrom:[_columns lastObject]];
    }
    
    for(id rowInfo in rows)
    {
        if([rowInfo isKindOfClass:[TSRow class]])
        {
            [_rows addObject:rowInfo];
        }
        else if([rowInfo isKindOfClass:[NSArray class]])
        {
            [_rows addObject:[[TSRow alloc] initWithCells:rowInfo]];//此分支不能加行头!
        }
        else if([rowInfo isKindOfClass:[NSDictionary class]])
        {
            [_rows addObject:[TSRow rowWithDictionary:rowInfo]];
        }
        else
        {
            NSAssert(FALSE, @"Type is not supported");
        }
    }
    [self reloadData];
}

- (void)addLeafColumnsFrom:(TSColumn *)parentColumn
{
    if(parentColumn.subcolumns.count == 0)
    {
        [_bottomEndColumns addObject:parentColumn];
    }
    else
    {
        for(TSColumn *column in parentColumn.subcolumns)
        {
            [self addLeafColumnsFrom:column];
        }
    }
}

- (void)setRows:(NSArray *)rows
{
    VerboseLog();
    [_rows removeAllObjects];
    
    for(id rowInfo in rows)
    {
        if([rowInfo isKindOfClass:[TSRow class]])
        {
            [_rows addObject:rowInfo];
        }
        else if([rowInfo isKindOfClass:[NSArray class]])
        {
            [_rows addObject:[[TSRow alloc] initWithCells:rowInfo]];
        }
        else if([rowInfo isKindOfClass:[NSDictionary class]])
        {
            [_rows addObject:[TSRow rowWithDictionary:rowInfo]];
        }
        else
        {
            NSAssert(FALSE, @"Type is not supported");
        }
    }
    [self reloadRowsData];
}

- (TSRow *)rowAtPath:(NSIndexPath *)indexPath
{
    VerboseLog();
    TSRow *row;
    NSArray *rows = _rows;
    for(int i = 0; i < indexPath.length;  ++i)
    {
        NSInteger index = [indexPath indexAtPosition:i];
        row = rows[index];
        rows = row.subrows;
    }
    return row;
}

- (TSColumn *)columnAtPath:(NSIndexPath *)indexPath
{
    VerboseLog();
    TSColumn *column;
    NSArray *columns = _columns;
    for(int i = 0; i < indexPath.length;  ++i)
    {
        NSInteger index = [indexPath indexAtPosition:i];
        column = columns[index];
        columns = column.subcolumns;
    }
    return column;
}

- (TSCell *)cellAtRowPath:(NSIndexPath *)rowPath atIndex:(NSInteger)index
{
    VerboseLog();
    TSRow *row = [self rowAtPath:rowPath];
    TSCell *cell = row.cells[index];
    return cell;
}

- (TSColumn *)columnAtIndex:(NSInteger)index
{
    VerboseLog(@"index = %d",index);
    
    return [_bottomEndColumns objectAtIndex:index];
}

// Find specified column recursevly in TSColumn hierarchy
- (TSColumn *)findColumnAtIndex:(NSInteger *)index inColumns:(NSArray *)columns
{
    TSColumn *found;
    for (int i = 0; i < columns.count;  ++i)
    {
        TSColumn *column = columns[i];
        if(column.subcolumns.count == 0)
        {
            if(*index == 0)
                return column;
            --(*index);
        }
        else
        {
            found = [self findColumnAtIndex:index inColumns:column.subcolumns];
            if(found) break;
        }
    }
    return found;
}


#pragma mark - Modify content

- (void)insertRow:(TSRow *)rowInfo atPath:(NSIndexPath *)indexPath
{
    VerboseLog();
    TSRow *row;
    NSMutableArray *rows = _rows;
    for(int i = 0; i < indexPath.length - 1;  ++i)
    {
        NSInteger index = [indexPath indexAtPosition:i];
        row = rows[index];
        rows = row.subrows;
    }
    NSInteger lastIndex = [indexPath indexAtPosition:indexPath.length - 1];
    [rows insertObject:rowInfo atIndex:lastIndex];
    [self insertRowAtPath:indexPath animated:YES];
}

- (void)removeRowAtPath:(NSIndexPath *)indexPath
{
    VerboseLog();
    TSRow *row;
    NSMutableArray *rows = _rows;
    for(int i = 0; i < indexPath.length - 1;  ++i)
    {
        NSInteger index = [indexPath indexAtPosition:i];
        row = rows[index];
        rows = row.subrows;
    }
    NSInteger lastIndex = [indexPath indexAtPosition:indexPath.length - 1];
    [rows removeObjectAtIndex:lastIndex];
    [self removeRowAtPath:indexPath animated:YES];
}

- (void)replcaceRowAtPath:(NSIndexPath *)indexPath withRow:(TSRow *)rowInfo
{
    VerboseLog();
    TSRow *row;
    NSMutableArray *rows = _rows;
    for(int i = 0; i < indexPath.length - 1;  ++i)
    {
        NSInteger index = [indexPath indexAtPosition:i];
        row = rows[index];
        rows = row.subrows;
    }
    NSInteger lastIndex = [indexPath indexAtPosition:indexPath.length - 1];
    [rows replaceObjectAtIndex:lastIndex withObject:rowInfo];
    [self updateRowAtPath:indexPath];
}

@end


@implementation TSColumn

+ (id)columnWithTitle:(NSString *)title
{
    return [[TSColumn alloc] initWithTitle:title];
}

+ (id)columnWithTitle:(NSString *)title andSubcolumns:(NSArray *)sublolumns
{
    return [[TSColumn alloc] initWithTitle:title andSubcolumns:sublolumns];
}

+ (id)columnWithDictionary:(NSDictionary *)info
{
    return [[TSColumn alloc] initWithDictionary:info];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ - %@", [super description], self.title];
}

- (id)initWithTitle:(NSString *)title
{
    if(self = [super init])
    {
        _title = title;
        _minWidth = MIN_COLUMN_WIDTH;
        _maxWidth = MAX_COLUMN_WIDTH;
        _defWidth = DEF_COLUMN_WIDTH;
        _headerHeight = DEF_COLUMN_HEADER_HEIGHT;
        _textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (id)initWithTitle:(NSString *)title andSubcolumns:(NSArray *)subcolumns
{
    if(self = [super init])
    {
        _title = title;
        _minWidth = MIN_COLUMN_WIDTH;
        _maxWidth = MAX_COLUMN_WIDTH;
        _defWidth = DEF_COLUMN_WIDTH;
        _headerHeight = DEF_COLUMN_HEADER_HEIGHT;
        _textAlignment = NSTextAlignmentCenter;
        
        NSMutableArray *columns = [[NSMutableArray alloc] initWithCapacity:subcolumns.count];
        for(id subcolumn in subcolumns)
        {
            if([subcolumn isKindOfClass:[TSColumn class]])
            {
                [columns addObject:subcolumn];
            }
            else if([subcolumn isKindOfClass:[NSString class]])
            {
                [columns addObject:[[TSColumn alloc] initWithTitle:title]];
            }
            else
            {
                NSAssert(FALSE, @"Type is not supported");
            }
        }
        _subcolumns = columns;
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)info
{
    if(self = [super init])
    {
        _title = info[@"title"];
        _subtitle = info[@"subtitle"];
        id iconVal = info[@"icon"];
        if([iconVal isKindOfClass:[UIImage class]])
            _icon = iconVal;
        else if([iconVal isKindOfClass:[NSString class]])
            _icon = [UIImage imageNamed:iconVal];
        
        id colorVal = info[@"color"];
        if([colorVal isKindOfClass:[UIColor class]])
            _color = colorVal;
        else if([colorVal isKindOfClass:[NSString class]])
            _color = [TSUtils colorWithHexString:colorVal];
        
        colorVal = info[@"titleColor"];
        if([colorVal isKindOfClass:[UIColor class]])
            _titleColor = colorVal;
        else if([colorVal isKindOfClass:[NSString class]])
            _titleColor = [TSUtils colorWithHexString:colorVal];
        
        colorVal = info[@"subtitleColor"];
        if([colorVal isKindOfClass:[UIColor class]])
            _subtitleColor = colorVal;
        else if([colorVal isKindOfClass:[NSString class]])
            _subtitleColor = [TSUtils colorWithHexString:colorVal];
        
        _titleFontSize = [info[@"titleFontSize"] floatValue];
        _subtitleFontSize = [info[@"subtitleFontSize"] floatValue];
        
        _minWidth = MIN_COLUMN_WIDTH;
        _maxWidth = MAX_COLUMN_WIDTH;
        _defWidth = DEF_COLUMN_WIDTH;
        _headerHeight = DEF_COLUMN_HEADER_HEIGHT;
        _textAlignment = NSTextAlignmentCenter;
        
        NSString *textAligmentStr = info[@"textAlignment"];
        if(textAligmentStr)
            _textAlignment = [textAligmentStr integerValue];
        
        NSString *widthStr = info[@"minWidth"];
        if(widthStr)
            _minWidth = [widthStr floatValue];
        
        widthStr = info[@"maxWidth"];
        if(widthStr)
            _maxWidth = [widthStr floatValue];
        
        widthStr = info[@"defWidth"];
        if(widthStr)
            _defWidth = [widthStr floatValue];
        
        widthStr = info[@"headerHeight"];
        if(widthStr)
            _headerHeight = [widthStr floatValue];
        
        NSArray *subcolumns = info[@"subcolumns"];
        if(subcolumns.count)
        {
            NSMutableArray *tmpColumns = [[NSMutableArray alloc] initWithCapacity:subcolumns.count];
            for(id subcolumnInfo in subcolumns)
            {
                if([subcolumnInfo isKindOfClass:[NSString class]])
                {
                    [tmpColumns addObject:[[TSColumn alloc] initWithTitle:subcolumnInfo]];
                }
                else if([subcolumnInfo isKindOfClass:[NSDictionary class]])
                {
                    [tmpColumns addObject:[[TSColumn alloc] initWithDictionary:subcolumnInfo]];
                }
                else if([subcolumnInfo isKindOfClass:[TSColumn class]])
                {
                    [tmpColumns addObject:subcolumnInfo];
                }
                else
                {
                    NSAssert(FALSE, @"Type is not supported");
                }
            }
            _subcolumns = tmpColumns;
        }
    }
    return self;
}

@end

/**************************************************************************************************************************************/

@implementation TSRow

+ (id)rowWithCells:(NSArray *)cells
{
    return [[TSRow alloc] initWithCells:cells];
}

+ (id)rowWithCells:(NSArray *)cells andSubrows:(NSArray *)subrows
{
    return [[TSRow alloc] initWithCells:cells andSubrows:subrows andRowHead:nil];
}

+ (id)rowWithCells:(NSArray *)cells andSubrows:(NSArray *)subrows andRowHead:(NSString*)rowHead
{
    return [[TSRow alloc] initWithCells:cells andSubrows:subrows andRowHead:rowHead];
}

+ (id)rowWithDictionary:(NSDictionary *)info
{
    return [[TSRow alloc] initWithDictionary:info];
}

- (id)initWithCells:(NSArray *)cells
{
    return [self initWithCells:cells andSubrows:nil andRowHead:nil];
}

- (id)initWithCells:(NSArray *)cells andRowHead:(NSString*)rowHead
{
    return [self initWithCells:cells andSubrows:nil andRowHead:rowHead];
}

- (id)initWithCells:(NSArray *)cells andSubrows:(NSArray *)subrows andRowHead:(NSString*)rowHead
{
    if(self = [super init])
    {
        if (rowHead) {
            _rowHead = rowHead;
        }
        if(cells)
        {
            NSMutableArray *tmpCells = [[NSMutableArray alloc] initWithCapacity:cells.count];
            for(id cell in cells)
            {
                if([cell isKindOfClass:[TSCell class]])
                {
                    [tmpCells addObject:cell];
                }
                else
                {
                    [tmpCells addObject:[[TSCell alloc] initWithValue:cell]];
                }
            }
            _cells = tmpCells;
        }
        
        if(subrows)
        {
            NSMutableArray *tmpRows = [[NSMutableArray alloc] initWithCapacity:subrows.count];
            for(id row in subrows)
            {
                if([row isKindOfClass:[TSRow class]])
                {
                    [tmpRows addObject:row];
                }
                else if([row isKindOfClass:[NSArray class]])
                {
                    [tmpRows addObject:[[TSRow alloc] initWithCells:row]];
                }
                else
                {
                    NSAssert(FALSE, @"Type is not supported");
                }
            }
            _subrows = tmpRows;
        }
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)info
{
    if(self = [super init])
    {
        //mark: rowHead 处理
        NSString *rowHead = info[@"rowHead"];
        if (rowHead) {
            _rowHead = rowHead;
        }
        
        NSArray *cells = info[@"cells"];
        if(cells)
        {
            NSMutableArray *tmpCells = [[NSMutableArray alloc] initWithCapacity:cells.count];
            for(id cellInfo in cells)
            {
                if([cellInfo isKindOfClass:[NSDictionary class]])
                {
                    [tmpCells addObject:[[TSCell alloc] initWithDictionary:cellInfo]];
                }
                else if([cellInfo isKindOfClass:[TSCell class]])
                {
                    [tmpCells addObject:cellInfo];
                }
                else
                {
                    NSAssert(FALSE, @"Type is not supported");
                }
            }
            _cells = tmpCells;
        }
        
        NSArray *subrows = info[@"subrows"];
        if(subrows)
        {
            NSMutableArray *tmpRows = [[NSMutableArray alloc] initWithCapacity:subrows.count];
            for(id rowInfo in subrows)
            {
                if([rowInfo isKindOfClass:[NSDictionary class]])
                {
                    [tmpRows addObject:[[TSRow alloc] initWithDictionary:rowInfo]];
                }
                else if([rowInfo isKindOfClass:[TSRow class]])
                {
                    [tmpRows addObject:rowInfo];
                }
                else
                {
                    NSAssert(FALSE, @"Type is not supported");
                }
            }
            _subrows = tmpRows;
        }
    }
    return self;
}

@end

/**************************************************************************************************************************************/

@implementation TSCell

+ (id)cellWithValue:(NSObject *)value
{
    return [[TSCell alloc] initWithValue:value];
}

+ (id)cellWithDictionary:(NSDictionary *)info
{
    return [[TSCell alloc] initWithDictionary:info];
}

- (id)initWithValue:(NSObject *)value
{
    if(self = [super init])
    {
        _textAlignment = NSTextAlignmentCenter;
        _value = value;
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)info
{
    if(self = [super init])
    {
        _value = info[@"value"];
        _details = info[@"details"];
        
        id colorVal = info[@"textColor"];
        if([colorVal isKindOfClass:[UIColor class]])
            _textColor = colorVal;
        else if([colorVal isKindOfClass:[NSString class]])
            _textColor = [TSUtils colorWithHexString:colorVal];
        
        colorVal = info[@"detailsColor"];
        if([colorVal isKindOfClass:[UIColor class]])
            _detailsColor = colorVal;
        else if([colorVal isKindOfClass:[NSString class]])
            _detailsColor = [TSUtils colorWithHexString:colorVal];
        
        id iconVal = info[@"icon"];
        if([iconVal isKindOfClass:[UIImage class]])
            _icon = iconVal;
        else if([iconVal isKindOfClass:[NSString class]])
            _icon = [UIImage imageNamed:iconVal];
        
        _textAlignment = NSTextAlignmentCenter;
        NSString *textAligmentStr = info[@"textAlignment"];
        if(textAligmentStr)
            _textAlignment = [textAligmentStr integerValue];
    }
    return self;
}

@end



