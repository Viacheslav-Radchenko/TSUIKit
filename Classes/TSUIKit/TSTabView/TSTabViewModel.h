//
//  TSTabViewModel.h
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

#import "TSNavigationStripModel.h"
#import "TSTabView.h"


/**
    @abstract   Classes provided below implement prototype for TSTabViewDataSource.
                It is optional part of TSTabView infrastructure, inluded as an example of possible data source implementation.
 *
                This prototype provides enough flexibility for building custom TSTabView containers.
                If you need something completly different you can always implement your own data source entity.
 */

/**************************************************************************************************************************************/

@interface TSTabViewSection : TSNavigationStripSection

@property (nonatomic, strong) UIView *tabContent;
@property (nonatomic, strong) UIViewController *tabController;

@end

/**************************************************************************************************************************************/

@interface TSTabViewItem : TSNavigationStripItem

@end

/**************************************************************************************************************************************/

/**
    @abstract   TSNavigationStripComponent is base class, which provides appearance information for TSNavigationStripView's section or item.
 *
    @remark     In sake of code reuse, TSTabViewModel inherits from TSNavigationStripModel. 
                Because they have similar underlying data structure and logic, it safes many lines of code)
                Hovewer, few methods that provided by TSNavigationStripModel interface are not applied in context of TSTabViewModel.
                    - (id)initWithNavigationStrip:
                    - (void)insertNewSection:atIndex:animated:
                    - (void)removeSectionAtIndex:animated:
                    - (void)setSections:
                These methods are overrided as dummy and do nothing beside assertion.
                TSTabViewModel replace these methods with following:
                    - (id)initWithTabView:
                    - (void)insertNewTab:atIndex:animated:
                    - (void)removeTabAtIndex:animated:
                    - (void)setTabs:
 */

@interface TSTabViewModel : TSNavigationStripModel <TSTabViewDataSource>

@property (nonatomic, strong, readonly) TSTabView *tabView;

- (id)initWithTabView:(TSTabView *)tabView;

- (void)insertNewTab:(TSTabViewSection *)tabInfo atIndex:(NSInteger)index animated:(BOOL)animated;
- (void)removeTabAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)setTabs:(NSArray *)tabs;

@end
