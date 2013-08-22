//
//  TSNavigationStripModel.m
//  TSUIKit
//
//  Created by Viacheslav Radchenko on 6/17/13.
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

#import "TSNavigationStripModel.h"

@implementation TSNavigationStripComponent

- (id)init
{
    if(self = [super init])
    {
        _title = @"";
        _selectedTitle = @"";
        
        _icon = nil;
        _selectedIcon = nil;
        
        _backgroundImage = nil;
        _selectedBackgroundImage = nil;
        
        _font = [UIFont systemFontOfSize:15.0f];
        _selectedFont = [UIFont boldSystemFontOfSize:15.0f];
        
        _color = [UIColor darkGrayColor];
        _selectedColor = [UIColor blackColor];
        
        _backgroundColor = [UIColor clearColor];
        _selectedBackgroundColor = [UIColor clearColor];
        
        _shadowColor = [UIColor clearColor];
        _shadowOffset = CGSizeZero;
    }
    return self;
}

@end

/**************************************************************************************************************************************/

@implementation TSNavigationStripItem

@end

/**************************************************************************************************************************************/

@implementation TSNavigationStripSection

@end

/**************************************************************************************************************************************/

@implementation TSNavigationStripModel

- (id)initWithNavigationStrip:(TSNavigationStripView *)navigationStrip
{
    if(self = [super init])
    {
        _navigationStrip = navigationStrip;
        _navigationStrip.dataSource = self;
        _useEdgeInsetsForSections = NO;
        
        _leftItems = [[NSMutableArray alloc] init];
        _rightItems = [[NSMutableArray alloc] init];
        _sections = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSArray *)leftItems
{
    return _leftItems;
}

- (NSArray *)rightItems
{
    return _rightItems;
}

- (NSArray *)sections
{
    return _sections;
}

- (void)insertNewSection:(TSNavigationStripSection *)sectionInfo atIndex:(NSInteger)index animated:(BOOL)animated
{
    NSInteger idx = MIN(MAX(index, 0), _sections.count);
    [_sections insertObject:sectionInfo atIndex:idx];
    [_navigationStrip insertSectionAtIndex:idx animated:animated];
    
    if(idx == 0 && _sections.count > 1) // update appearance of previous most left section
    {
        [_navigationStrip updateSectionsAtIndexes:@[@1] animated:animated];
    }
    else if(idx == _sections.count - 1 && _sections.count > 1) // update appearance of previous most right section
    {
        [_navigationStrip updateSectionsAtIndexes:@[@(_sections.count - 2)] animated:animated];
    }
}

- (void)insertNewItem:(TSNavigationStripItem *)itemInfo atIndex:(NSInteger)index fromLeft:(BOOL)fromLeft animated:(BOOL)animated
{
    NSMutableArray *items = (fromLeft ? _leftItems : _rightItems);
    NSInteger idx = MIN(MAX(index, 0), items.count);
    [items insertObject:itemInfo atIndex:idx];
  
    [_navigationStrip insertItemAtIndex:idx fromLeftSide:fromLeft animated:animated];
    
    if(idx == 0 && items.count > 1) // update appearance of previous most left item
    {
        [_navigationStrip updateItemsAtIndexes:@[@1] fromLeftSide:fromLeft animated:animated];
    }
    else if(idx == items.count - 1 && items.count > 1) // update appearance of previous most right item
    {
        [_navigationStrip updateItemsAtIndexes:@[@(items.count - 2)] fromLeftSide:fromLeft animated:animated];
    }
}

- (void)removeSectionAtIndex:(NSInteger)index animated:(BOOL)animated
{
    NSInteger idx = MIN(MAX(index, 0), _sections.count);
    [_sections removeObjectAtIndex:idx];
    [_navigationStrip removeSectionAtIndex:idx animated:animated];
    
    if(idx == 0 && _sections.count) // update appearance of current most left section
    {
        [_navigationStrip updateSectionsAtIndexes:@[@0] animated:animated];
    }
    else if(idx == _sections.count && _sections.count) // update appearance of current most right section
    {
        [_navigationStrip updateSectionsAtIndexes:@[@(_sections.count - 1)] animated:animated];
    }
}

- (void)removeItemAtIndex:(NSInteger)index fromLeft:(BOOL)fromLeft animated:(BOOL)animated
{
    NSMutableArray *items = (fromLeft ? _leftItems : _rightItems);
    NSInteger idx = MIN(MAX(index, 0), items.count);
    [items removeObjectAtIndex:idx];
    
    [_navigationStrip removeItemAtIndex:idx fromLeftSide:fromLeft animated:animated];
    
    if(idx == 0 && items.count) // update appearance of current most left item
    {
        [_navigationStrip updateItemsAtIndexes:@[@0] fromLeftSide:fromLeft animated:animated];
    }
    else if(idx == items.count && items.count) // update appearance of current most right item
    {
        [_navigationStrip updateItemsAtIndexes:@[@(items.count - 1)] fromLeftSide:fromLeft animated:animated];
    }
}

- (void)setSections:(NSArray *)sections
{
    [_sections removeAllObjects];
    [_sections addObjectsFromArray:sections];
    [_navigationStrip reloadSectionsData];
}

- (void)setItems:(NSArray *)items fromLeft:(BOOL)fromLeft
{
    if(fromLeft)
    {
        [_leftItems removeAllObjects];
        [_leftItems addObjectsFromArray:items];
    }
    else
    {
        [_rightItems removeAllObjects];
        [_rightItems addObjectsFromArray:items];
        
    }
    [_navigationStrip reloadItemsData];
}

#pragma mark - TSNavigationStripDataSource

- (NSInteger)numberOfSections
{
    return _sections.count;
}

- (UIButton *)customSectionControlForIndex:(NSInteger)index
{
    CGRect rect = CGRectMake(0, 0, self.navigationStrip.frame.size.height, self.navigationStrip.frame.size.height);
    return (self.customClassForSection ? [[NSClassFromString(self.customClassForSection) alloc] initWithFrame:rect] : [[UIButton alloc] initWithFrame:rect]);
}

- (NSString *)titleForSectionAtIndex:(NSInteger)index forSelectedState:(BOOL)selected
{
    TSNavigationStripSection *section = _sections[index];
    return (selected ? section.selectedTitle : section.title);
}

- (UIColor *)titleColorForSectionAtIndex:(NSInteger)index forSelectedState:(BOOL)selected
{
    TSNavigationStripSection *section = _sections[index];
    return (selected ? section.selectedColor : section.color);
}

- (CGFloat)sectionWidthAtIndex:(NSInteger)index forSelectedState:(BOOL)selected
{
    TSNavigationStripSection *section = _sections[index];
    if(selected)
        return [section.selectedTitle sizeWithFont:section.selectedFont].width + 2 * _navigationStrip.bounds.size.height;
    else
        return [section.title sizeWithFont:section.font].width + 2 * _navigationStrip.bounds.size.height;
}

- (UIFont *)titleFontForSectionAtIndex:(NSInteger)index forSelectedState:(BOOL)selected
{
    TSNavigationStripSection *section = _sections[index];
    return (selected ? section.selectedFont : section.font);
}

- (UIImage *)backgroundImageForSectionAtIndex:(NSInteger)index forSelectedState:(BOOL)selected
{
    TSNavigationStripSection *section = _sections[index];
    return (selected ? section.selectedBackgroundImage : section.backgroundImage);
}

- (UIImage *)iconForSectionAtIndex:(NSInteger)index forSelectedState:(BOOL)selected
{
    TSNavigationStripSection *section = _sections[index];
    return (selected ? section.selectedIcon : section.icon);
}

- (UIColor *)backgroundColorForSectionAtIndex:(NSInteger)index forSelectedState:(BOOL)selected
{
    TSNavigationStripSection *section = _sections[index];
    return (selected ? section.selectedBackgroundColor : section.backgroundColor);
}

- (UIColor *)shadowColorForSectionAtIndex:(NSInteger)index 
{
    TSNavigationStripSection *section = _sections[index];
    return section.shadowColor;
}

- (CGSize)shadowOffsetForSectionAtIndex:(NSInteger)index
{
    TSNavigationStripSection *section = _sections[index];
    return section.shadowOffset;
}

- (UIEdgeInsets)edgeInsetsForSectionAtIndex:(NSInteger)index
{
    UIEdgeInsets res;
    if(!_useEdgeInsetsForSections || _sections.count <= 1)
    {
        return UIEdgeInsetsZero;
    }
    else if(index == 0)
    {
        res = UIEdgeInsetsMake(0, 0, 0, -self.navigationStrip.frame.size.height/2);
    }
    else if(index == _sections.count - 1)
    {
        res = UIEdgeInsetsMake(0, -self.navigationStrip.frame.size.height/2, 0, 0);
    }
    else
    {
        res = UIEdgeInsetsMake(0, -self.navigationStrip.frame.size.height/2, 0, -self.navigationStrip.frame.size.height/2);
    }
    
    if(_navigationStrip.sectionsAligment == UIViewContentModeCenter)
    {
        res = UIEdgeInsetsMake(0, -self.navigationStrip.frame.size.height/2, 0, -self.navigationStrip.frame.size.height/2); 
    }
    return res;
}

#pragma mark - Items

- (NSInteger)numberOfItemsFromLeftSide:(BOOL)leftSide
{
    return (leftSide ? _leftItems.count : _rightItems.count);
}

- (UIImage *)iconForItemAtIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide forSelectedState:(BOOL)selected
{
    TSNavigationStripItem *item = (leftSide ? _leftItems[index] : _rightItems[index]);
    return (selected ? item.selectedIcon : item.icon);
}

- (CGFloat)itemWidthAtIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide forSelectedState:(BOOL)selected
{
    TSNavigationStripItem *item = (leftSide ? _leftItems[index] : _rightItems[index]);
    if(selected)
        return [item.selectedTitle sizeWithFont:item.selectedFont].width + _navigationStrip.bounds.size.height;
    else
        return [item.title sizeWithFont:item.font].width + _navigationStrip.bounds.size.height;
}

- (UIImage *)backgroundImageForItemAtIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide forSelectedState:(BOOL)selected
{
    TSNavigationStripItem *item = (leftSide ? _leftItems[index] : _rightItems[index]);
    return (selected ? item.selectedBackgroundImage : item.backgroundImage);
}

- (UIColor *)titleColorForItemAtIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide forSelectedState:(BOOL)selected
{
    TSNavigationStripItem *item = (leftSide ? _leftItems[index] : _rightItems[index]);
    return (selected ? item.selectedColor : item.color);
}

- (UIFont *)titleFontForItemAtIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide forSelectedState:(BOOL)selected
{
    TSNavigationStripItem *item = (leftSide ? _leftItems[index] : _rightItems[index]);
    return (selected ? item.selectedFont : item.font);
}

- (NSString *)titleForItemAtIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide forSelectedState:(BOOL)selected
{
    TSNavigationStripItem *item = (leftSide ? _leftItems[index] : _rightItems[index]);
    return (selected ? item.selectedTitle : item.title);
}

- (UIColor *)backgroundColorForItemAtIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide forSelectedState:(BOOL)selected
{
    TSNavigationStripItem *item = (leftSide ? _leftItems[index] : _rightItems[index]);
    return (selected ? item.selectedBackgroundColor : item.backgroundColor);
}

- (UIColor *)shadowColorForItemAtIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide
{
    TSNavigationStripItem *item = (leftSide ? _leftItems[index] : _rightItems[index]);
    return item.shadowColor;
}

- (CGSize)shadowOffsetForItemAtIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide
{
    TSNavigationStripItem *item = (leftSide ? _leftItems[index] : _rightItems[index]);
    return item.shadowOffset;
}

- (UIEdgeInsets)edgeInsetsForItemAtIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide
{
    return UIEdgeInsetsZero;
}

@end
