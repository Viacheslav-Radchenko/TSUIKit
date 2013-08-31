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
#import "TSUtils.h"

@implementation TSNavigationStripComponent

- (void)setup
{
    _title = @"";
    _selectedTitle = nil;
    
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

- (id)init
{
    if(self = [super init])
    {
        [self setup];
    }
    return self;
}

- (id)initWithTitle:(NSString *)title
{
    if(self = [super init])
    {
        [self setup];
        _title = title;
        _selectedTitle = title;
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)info
{
    if(self = [super init])
    {
        [self setup];
        _title = info[@"title"];
        _selectedTitle = info[@"selectedTitle"];
        
        id imgVal = info[@"icon"];
        if([imgVal isKindOfClass:[UIImage class]])
            _icon = imgVal;
        else if([imgVal isKindOfClass:[NSString class]])
            _icon = [UIImage imageNamed:imgVal];
        
        imgVal = info[@"selectedIcon"];
        if([imgVal isKindOfClass:[UIImage class]])
            _selectedIcon = imgVal;
        else if([imgVal isKindOfClass:[NSString class]])
            _selectedIcon = [UIImage imageNamed:imgVal];
        
        imgVal = info[@"backgroundImage"];
        if([imgVal isKindOfClass:[UIImage class]])
            _backgroundImage = imgVal;
        else if([imgVal isKindOfClass:[NSString class]])
            _backgroundImage = [UIImage imageNamed:imgVal];
        
        imgVal = info[@"selectedBackgroundImage"];
        if([imgVal isKindOfClass:[UIImage class]])
            _selectedBackgroundImage = imgVal;
        else if([imgVal isKindOfClass:[NSString class]])
            _selectedBackgroundImage = [UIImage imageNamed:imgVal];
        
        _font = info[@"font"];
        _selectedFont = info[@"selectedFont"];
        
        id colorVal = info[@"color"];
        if([colorVal isKindOfClass:[UIColor class]])
            _color = colorVal;
        else if([colorVal isKindOfClass:[NSString class]])
            _color = [TSUtils colorWithHexString:colorVal];
        
        colorVal = info[@"selectedColor"];
        if([colorVal isKindOfClass:[UIColor class]])
            _selectedColor = colorVal;
        else if([colorVal isKindOfClass:[NSString class]])
            _selectedColor = [TSUtils colorWithHexString:colorVal];
    
        colorVal = info[@"backgroundColor"];
        if([colorVal isKindOfClass:[UIColor class]])
            _backgroundColor = colorVal;
        else if([colorVal isKindOfClass:[NSString class]])
            _backgroundColor = [TSUtils colorWithHexString:colorVal];
        
        colorVal = info[@"selectedBackgroundColor"];
        if([colorVal isKindOfClass:[UIColor class]])
            _selectedBackgroundColor = colorVal;
        else if([colorVal isKindOfClass:[NSString class]])
            _selectedBackgroundColor = [TSUtils colorWithHexString:colorVal];
        
        colorVal = info[@"shadowColor"];
        if([colorVal isKindOfClass:[UIColor class]])
            _shadowColor = colorVal;
        else if([colorVal isKindOfClass:[NSString class]])
            _shadowColor = [TSUtils colorWithHexString:colorVal];
        
        _shadowOffset = [info[@"shadowOffset"] CGSizeValue];
    }
    return self;
}

- (NSString *)selectedTitle
{
    return (_selectedTitle ? _selectedTitle : _title);
}

- (UIImage *)selectedIcon
{
    return (_selectedIcon ? _selectedIcon : _icon);
}

- (UIImage *)selectedBackgroundImage
{
    return (_selectedBackgroundImage ? _selectedBackgroundImage : _backgroundImage);
}

- (UIFont *)selectedFont
{
    return (_selectedFont ? _selectedFont : _font);
}

- (UIColor *)selectedColor
{
    return (_selectedColor ? _selectedColor : _color);
}

- (UIColor *)selectedBackgroundColor
{
    return (_selectedBackgroundColor ? _selectedBackgroundColor : _backgroundColor);
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
    
    for(id sectionInfo in sections)
    {
        if([sectionInfo isKindOfClass:[TSNavigationStripSection class]])
        {
            [_sections addObject:sectionInfo];
        }
        else if([sectionInfo isKindOfClass:[NSDictionary class]])
        {
            [_sections addObject:[[TSNavigationStripSection alloc] initWithDictionary:sectionInfo]];
        }
        else if([sectionInfo isKindOfClass:[NSString class]])
        {
            [_sections addObject:[[TSNavigationStripSection alloc] initWithTitle:sectionInfo]];
        }
        else
        {
            NSAssert(FALSE, @"Type is not supported!");
        }
    }
    [_navigationStrip reloadSectionsData];
}

- (void)setItems:(NSArray *)items fromLeft:(BOOL)fromLeft
{
    NSMutableArray *destItems;
    if(fromLeft)
    {
        [_leftItems removeAllObjects];
        destItems = _leftItems;
    }
    else
    {
        [_rightItems removeAllObjects];
        destItems = _rightItems;
    }
    
    for(id sectionInfo in items)
    {
        if([sectionInfo isKindOfClass:[TSNavigationStripItem class]])
        {
            [destItems addObject:sectionInfo];
        }
        else if([sectionInfo isKindOfClass:[NSDictionary class]])
        {
            [destItems addObject:[[TSNavigationStripItem alloc] initWithDictionary:sectionInfo]];
        }
        else if([sectionInfo isKindOfClass:[NSString class]])
        {
            [destItems addObject:[[TSNavigationStripItem alloc] initWithTitle:sectionInfo]];
        }
        else
        {
            NSAssert(FALSE, @"Type is not supported");
        }
    }
    [_navigationStrip reloadItemsData];
}

#pragma mark - TSNavigationStripDataSource (Sections)

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

#pragma mark - TSNavigationStripDataSource (Items)

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
