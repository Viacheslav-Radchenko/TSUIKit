//
//  SSTabViewModel.m
//  SSUIKit
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

#import "SSTabViewModel.h"

@implementation SSTabViewSection 

@end

//--------------------------------------------------------------------------------------------

@implementation SSTabViewItem 

@end

//--------------------------------------------------------------------------------------------

@implementation SSTabViewModel

- (id)initWithTabView:(SSTabView *)tabView
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

- (void)insertNewTab:(SSTabViewSection *)tabInfo atIndex:(NSInteger)index animated:(BOOL)animated
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
    [_sections addObjectsFromArray:tabs];
    [_tabView reloadTabsData];
}

#pragma mark - SSTabViewDataSource

//- (UIViewController *)viewControllerForTabAtIndex:(NSInteger)index
//{
//    
//}

- (UIView *)viewForTabAtIndex:(NSInteger)index
{
    NSInteger idx = MIN(MAX(index, 0), _sections.count);
    SSTabViewSection *tabInfo = _sections[idx];
    return tabInfo.tabContent;
}

#pragma mark - Override

- (id)initWithNavigationStrip:(SSNavigationStripView *)navigationStrip
{
    NSAssert(FALSE, @"initWithNavigationStrip shouldn't be used for SSTabView. Use initWithTabView instead.");
    return nil;
}

- (void)insertNewSection:(SSNavigationStripSection *)sectionInfo atIndex:(NSInteger)index animated:(BOOL)animated
{
    NSAssert(FALSE, @"insertNewSection shouldn't be used for SSTabView. Use insertNewTab instead.");
}

- (void)removeSectionAtIndex:(NSInteger)index animated:(BOOL)animated
{
    NSAssert(FALSE, @"removeSectionAtIndex shouldn't be used for SSTabView. Use removeTabAtIndex instead.");
}

- (void)setSections:(NSArray *)sections
{
    NSAssert(FALSE, @"setSections shouldn't be used for SSTabView. Use setSections instead.");
}

@end
