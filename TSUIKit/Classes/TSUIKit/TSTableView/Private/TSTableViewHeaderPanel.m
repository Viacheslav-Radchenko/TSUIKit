//
//  TSTableViewHeaderPanel.m
//  TSUIKit
//
//  Created by Viacheslav Radchenko on 8/9/13.
//  Copyright (c) 2013 Viacheslav Radchenko. All rights reserved.
//

#import "TSTableViewHeaderPanel.h"
#import "TSTableViewHeaderSection.h"
#import "TSTableViewHeaderSectionView.h"
#import "TSTableViewDataSource.h"
#import "TSTableViewAppearanceCoordinator.h"
#import "TSUtils.h"
#import "TSDefines.h"

#define DEF_TABLE_MIN_COLUMN_WIDTH  64
#define DEF_TABLE_MAX_COLUMN_WIDTH  512

#ifndef VerboseLog
#define VerboseLog(fmt, ...)  (void)0
#endif

@interface TSTableViewHeaderPanel ()
{
    NSMutableArray *_headerSections;
    CGFloat _headerHeight;
    CGPoint _lastTouchPos;
    BOOL _changingColumnSize;
    
    UIColor *_topColor;
    UIColor *_bottomColor;
    UIColor *_topBorderColor;
    UIColor *_bottomBorderColor;
    UIColor *_leftBorderColor;
    UIColor *_rightBorderColor;
}

@end

@implementation TSTableViewHeaderPanel

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
    self.scrollEnabled = NO;
    _changingColumnSize = NO;
    _headerSections = [[NSMutableArray alloc] init];
    
    _minColumnWidth = DEF_TABLE_MIN_COLUMN_WIDTH;
    _maxColumnWidth = DEF_TABLE_MAX_COLUMN_WIDTH;
    
    _topColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
    _bottomColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    _topBorderColor = [UIColor whiteColor];
    _bottomBorderColor = [UIColor colorWithWhite:0.7f alpha:1.0f];
    _leftBorderColor = [UIColor whiteColor];
    _rightBorderColor = [UIColor colorWithWhite:0.7f alpha:1.0f];
}

- (TSTableViewHeaderSection *)headerSectionAtIndex:(NSInteger)index
{
    VerboseLog(@"index = %d",index);
    TSTableViewHeaderSection *section;
    NSArray *sections = _headerSections;
    while(sections && sections.count)
    {
        for(int i = 0; i < sections.count; i++)
        {
            section = sections[i];
            if(index < section.subcolumnsRange.location + section.subcolumnsRange.length)
            {
                sections = section.subsections;
                break;
            }
        }
    }
    return section;
}

- (TSTableViewHeaderSection *)headerSectionAtPath:(NSIndexPath *)indexPath
{
    VerboseLog();
    TSTableViewHeaderSection *section;
    NSArray *sections = _headerSections;
    for(int i = 0; i < indexPath.length; i++)
    {
        NSInteger index = [indexPath indexAtPosition:i];
        section = sections[index];
        sections = section.subsections;
    }
    return section;
}

#pragma mark - Custom Draw


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
                    startPoint:CGPointMake(0, 0)
                      endPoint:CGPointMake(self.bounds.size.width - 1, 0)
                         color:_topBorderColor.CGColor
                     lineWidth:0.5];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(0, self.bounds.size.height - 1)
                      endPoint:CGPointMake(self.bounds.size.width - 1, self.bounds.size.height - 1)
                         color:_bottomBorderColor.CGColor
                     lineWidth:0.5];

}


#pragma mark - Slide Button

- (void)addSlideButtonToSection:(TSTableViewHeaderSection *)section
{
    VerboseLog();
    CGFloat slideBtnWidth = 8;
    UIButton *slideBtn = [[UIButton alloc] initWithFrame:CGRectMake(section.frame.size.width - slideBtnWidth, 0, slideBtnWidth, section.frame.size.height)];
    slideBtn.showsTouchWhenHighlighted = YES;
    [slideBtn addTarget:self action:@selector(slideBtnTouchBegin:withEvent:) forControlEvents:UIControlEventTouchDown];
    [slideBtn addTarget:self action:@selector(slideBtnTouch:withEvent:) forControlEvents:UIControlEventAllTouchEvents];
    [slideBtn addTarget:self action:@selector(slideBtnTouchEnd:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    [slideBtn addTarget:self action:@selector(slideBtnTouchEnd:withEvent:) forControlEvents:UIControlEventTouchUpOutside];
    slideBtn.tag = section.subcolumnsRange.location + section.subcolumnsRange.length - 1;
    slideBtn.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1];
    slideBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    [section addSubview:slideBtn];
}

- (void)slideBtnTouchBegin:(UIButton *)sender withEvent:(UIEvent *)event
{
    VerboseLog();
    _changingColumnSize = YES;
    _lastTouchPos = [[[event allTouches] anyObject] locationInView:self];
}

- (void)slideBtnTouchEnd:(UIButton *)sender withEvent:(UIEvent *)event
{
    VerboseLog();
    _changingColumnSize = NO;
}

- (void)slideBtnTouch:(UIButton *)sender withEvent:(UIEvent *)event
{
    VerboseLog();
    if(_changingColumnSize)
    {
        UIButton *thisButton = (UIButton *)sender;
        NSInteger columnIndex = thisButton.tag;
        TSTableViewHeaderSection *section = [self headerSectionAtIndex:columnIndex];
        CGFloat oldWidth = section.bounds.size.width;
        CGPoint centerPoint = [[[event allTouches] anyObject] locationInView:self];
        CGFloat delta = centerPoint.x - _lastTouchPos.x;
        CGFloat newWidth = oldWidth + delta;
        newWidth = CLAMP(_minColumnWidth, _maxColumnWidth, newWidth);
        [self changeColumnWidthOnAmount:newWidth - oldWidth forColumn:columnIndex animated:NO];
        
        if(self.headerDelegate)
        {
            [self.headerDelegate tableViewHeader:self columnWidthDidChange:columnIndex oldWidth:oldWidth newWidth:newWidth];
        }

        _lastTouchPos = centerPoint;
    }
}

#pragma mark - Load data

- (void)reloadData
{
    VerboseLog();
    for(TSTableViewHeaderSection *section in _headerSections)
    {
        [section removeFromSuperview];
    }
    [_headerSections removeAllObjects];

    if(self.dataSource)
    {
        _headerHeight = 0;
        NSInteger numberOfColumns = [self.dataSource numberOfColumnsAtPath:nil];
        NSInteger columnsCount = 0;
       
        CGFloat xOffset = 0;
        for(int i = 0; i < numberOfColumns; i++)
        {
            NSIndexPath *columnPath = [NSIndexPath indexPathWithIndex:i];
            CGFloat columnWidth = [self.dataSource defaultWidthForColumnAtPath:columnPath];
            CGFloat columnHeight = [self.dataSource heightForHeaderSectionAtPath:columnPath];
            CGFloat totalHeight = columnHeight;
            CGFloat totalWidth = columnWidth;
            
            TSTableViewHeaderSection *columnSection = [[TSTableViewHeaderSection alloc] initWithFrame:CGRectMake(xOffset, 0, columnWidth, columnHeight)];
            columnSection.backgroundColor = [UIColor clearColor];
            columnSection.subcolumnsRange = NSMakeRange(columnsCount, 1);
            [self addSubview:columnSection];
            [_headerSections addObject:columnSection];
            
            [self loadSectionAtPath:columnPath section:columnSection];
            [self loadSubsectionsAtPath:columnPath section:columnSection yOffset:columnHeight totalHeight:&totalHeight totalWidth:&totalWidth];
            [self addSlideButtonToSection:columnSection];
            
            columnSection.frame = CGRectMake(xOffset, 0, totalWidth, columnHeight);
            
            if(totalHeight > _headerHeight)
                _headerHeight = totalHeight;
            
            xOffset += totalWidth;
            columnsCount += columnSection.subcolumnsRange.length;
        }
        
        for(int i = 0; i < numberOfColumns; i++)
        {
            TSTableViewHeaderSection *columnSection = _headerSections[i];
            columnSection.frame = CGRectMake(columnSection.frame.origin.x, columnSection.frame.origin.y, columnSection.frame.size.width, _headerHeight);
            if(columnSection.subsections.count == 0)
                columnSection.sectionView.frame = columnSection.bounds;
        }
    }
}

#pragma mark - Load sections

- (void)loadSectionAtPath:(NSIndexPath *)sectionPath section:(TSTableViewHeaderSection *)section
{
    VerboseLog();
    CGFloat columnHeight = [self.dataSource heightForHeaderSectionAtPath:sectionPath];
    TSTableViewHeaderSectionView *sectionView = [self.dataSource headerSectionViewForColumnAtPath:sectionPath];
    sectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    sectionView.frame = CGRectMake(0, 0, section.bounds.size.width, columnHeight);
    section.sectionView = sectionView;
}

- (void)loadSubsectionsAtPath:(NSIndexPath *)sectionPath section:(TSTableViewHeaderSection *)rootSection yOffset:(CGFloat)yOffset totalHeight:(CGFloat *)totalHeight totalWidth:(CGFloat *)totalWidth
{
    VerboseLog();
    NSInteger numberOfColumns = [self.dataSource numberOfColumnsAtPath:sectionPath];
    if(numberOfColumns)
    {
        NSMutableArray *subsections = [[NSMutableArray alloc] initWithCapacity:numberOfColumns];
        CGFloat xOffset = 0;
        CGFloat maxHeight = 0;
        CGFloat columnsCount = 0;
        for(int j = 0; j < numberOfColumns; j++)
        {
            NSIndexPath *subsectionPath = [sectionPath indexPathByAddingIndex:j];
            CGFloat columnWidth = [self.dataSource defaultWidthForColumnAtPath:subsectionPath];
            CGFloat columnHeight = [self.dataSource heightForHeaderSectionAtPath:subsectionPath];
            CGFloat subsectionsHeight = columnHeight;
            CGFloat subsectionsWidth = columnWidth;
            
            TSTableViewHeaderSection *columnSection = [[TSTableViewHeaderSection alloc] initWithFrame:CGRectMake(xOffset, yOffset, columnWidth, columnHeight)];
            columnSection.backgroundColor = [UIColor clearColor];
            columnSection.subcolumnsRange = NSMakeRange(rootSection.subcolumnsRange.location + columnsCount, 1);
            [subsections addObject:columnSection];
            
            [self loadSectionAtPath:subsectionPath section:columnSection];
            [self loadSubsectionsAtPath:subsectionPath section:columnSection yOffset:columnHeight totalHeight:&subsectionsHeight totalWidth:&subsectionsWidth];
            if(j != numberOfColumns - 1)
                [self addSlideButtonToSection:columnSection];
            
            columnSection.frame = CGRectMake(xOffset, yOffset, subsectionsWidth, subsectionsHeight);
        
            if(subsectionsHeight > maxHeight)
                maxHeight = subsectionsHeight;
            
            xOffset += subsectionsWidth;
            columnsCount += columnSection.subcolumnsRange.length;
        }
        
        // Update section's size to max height
        for(int j = 0; j < numberOfColumns; j++)
        {
            TSTableViewHeaderSection *columnSection = subsections[j];
            columnSection.frame = CGRectMake(columnSection.frame.origin.x, columnSection.frame.origin.y, columnSection.frame.size.width, maxHeight);
            if(columnSection.subsections.count == 0)
                columnSection.sectionView.frame = columnSection.bounds;
        }
        rootSection.subcolumnsRange = NSMakeRange(rootSection.subcolumnsRange.location, columnsCount);
        rootSection.subsections = [NSArray arrayWithArray:subsections];
        *totalHeight += maxHeight;
        *totalWidth = xOffset;
    }
}

#pragma mark - Modify content

- (void)changeColumnWidthOnAmount:(CGFloat)delta forColumn:(NSInteger)columnIndex animated:(BOOL)animated
{
    VerboseLog();
    TSTableViewHeaderSection *section;
    NSArray *sections = _headerSections;
    while(sections && sections.count)
    {
        for(int i = 0; i < sections.count; i++)
        {
            section = sections[i];
            if(columnIndex < section.subcolumnsRange.location + section.subcolumnsRange.length)
            {
                [TSUtils performViewAnimationBlock:^{
                    for(int j = i; j < sections.count; j++)
                    {
                        TSTableViewHeaderSection *tmp = sections[j];
                        CGRect rect = tmp.frame;
                        if(j == i)
                            rect.size.width += delta;
                        else
                            rect.origin.x += delta;
                        tmp.frame = rect;
                    }
                } withCompletion:nil animated:animated];
                sections = section.subsections;
                break;
            }
        }
    }
}

#pragma mark - Getters

- (CGFloat)tableTotalWidth
{
    VerboseLog();
    CGFloat width = 0;
    for(int j = 0; j < _headerSections.count; j++)
    {
        TSTableViewHeaderSection *columnSection = _headerSections[j];
        width += columnSection.frame.size.width;
    }
    return width;
}

- (CGFloat)headerHeight
{
    VerboseLog();
    return _headerHeight;
}

- (CGFloat)widthForColumnAtIndex:(NSInteger)index
{
    VerboseLog();
    TSTableViewHeaderSection *section = [self headerSectionAtIndex:index];
    return section.frame.size.width;
}

- (CGFloat)widthForColumnAtPath:(NSIndexPath *)indexPath
{
    VerboseLog();
    TSTableViewHeaderSection *section = [self headerSectionAtPath:indexPath];
    return section.frame.size.width;
}

@end