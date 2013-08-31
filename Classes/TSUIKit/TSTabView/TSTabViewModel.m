//
//  TSTabViewModel.m
//  TSUIKit
//
//  Created by Viacheslav Radchenko on 6/20/13.
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

#import "TSTabViewModel.h"

@implementation TSTabViewSection

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if(self = [super initWithDictionary:dictionary])
    {
        _tabContent = dictionary[@"tabContent"];
        _tabController = dictionary[@"tabController"];
    }
    return self;
}

- (id)initWithTitle:(NSString *)title andView:(UIView *)view
{
    if(self = [super initWithTitle:title])
    {
        _tabContent = view;
    }
    return self;
}

- (id)initWithTitle:(NSString *)title andController:(UIViewController *)controller
{
    if(self = [super initWithTitle:title])
    {
        _tabController = controller;
    }
    return self;
}

@end

/**************************************************************************************************************************************/

@implementation TSTabViewItem 

@end

/**************************************************************************************************************************************/

@implementation TSTabViewModel

- (id)initWithTabView:(TSTabView *)tabView
{
    if(self = [super init])
    {
        _tabView = tabView;
        _tabView.dataSource = self;
        
        _navigationStrip = tabView.navigationMenu;
        
        _leftItems = [[NSMutableArray alloc] init];
        _rightItems = [[NSMutableArray alloc] init];
        _sections = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)insertNewTab:(TSTabViewSection *)tabInfo atIndex:(NSInteger)index animated:(BOOL)animated
{
    NSInteger idx = MIN(MAX(index, 0), _sections.count);
    [_sections insertObject:tabInfo atIndex:idx];
    [_tabView insertTabAtIndex:idx animated:animated];
}

- (void)removeTabAtIndex:(NSInteger)index animated:(BOOL)animated
{
    NSInteger idx = MIN(MAX(index, 0), _sections.count);
    [_sections removeObjectAtIndex:idx];
    [_tabView removeTabAtIndex:idx animated:animated];
}

- (void)setTabs:(NSArray *)tabs
{
    [_sections removeAllObjects];
    
    for(id tabInfo in tabs)
    {
        if([tabInfo isKindOfClass:[TSTabViewSection class]])
        {
            [_sections addObject:tabInfo];
        }
        else if([tabInfo isKindOfClass:[NSDictionary class]])
        {
            [_sections addObject:[[TSTabViewSection alloc] initWithDictionary:tabInfo]];
        }
        else
        {
            NSAssert(FALSE, @"Type is not supported");
        }
    }
    
    [_tabView reloadTabsData];
}

#pragma mark - TSTabViewDataSource

//- (UIViewController *)viewControllerForTabAtIndex:(NSInteger)index
//{
//    
//}

- (UIView *)viewForTabAtIndex:(NSInteger)index
{
    NSInteger idx = MIN(MAX(index, 0), _sections.count);
    TSTabViewSection *tabInfo = _sections[idx];
    return tabInfo.tabContent;
}

#pragma mark - Override

- (id)initWithNavigationStrip:(TSNavigationStripView *)navigationStrip
{
    NSAssert(FALSE, @"initWithNavigationStrip shouldn't be used for TSTabView. Use initWithTabView instead.");
    return nil;
}

- (void)insertNewSection:(TSNavigationStripSection *)sectionInfo atIndex:(NSInteger)index animated:(BOOL)animated
{
    NSAssert(FALSE, @"insertNewSection shouldn't be used for TSTabView. Use insertNewTab instead.");
}

- (void)removeSectionAtIndex:(NSInteger)index animated:(BOOL)animated
{
    NSAssert(FALSE, @"removeSectionAtIndex shouldn't be used for TSTabView. Use removeTabAtIndex instead.");
}

- (void)setSections:(NSArray *)sections
{
    NSAssert(FALSE, @"setSections shouldn't be used for TSTabView. Use setSections instead.");
}

@end
