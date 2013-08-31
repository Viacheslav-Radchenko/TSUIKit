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

                This prototype provides enough flexibility for building custom TSTabView containers.
                If you need something completly different you can always implement your own data source entity.
 */

/**************************************************************************************************************************************/

/** TSTabViewSection contains information about corresponding tab in TSTabView. This information includes appearance and content properties. */
@interface TSTabViewSection : TSNavigationStripSection

/** UIView assotiated with this section */
@property (nonatomic, strong) UIView *tabContent;
/** UIViewController assotiated with this section */
@property (nonatomic, strong) UIViewController *tabController;

/** Initialize TSTabViewSection with section title and corresponding UIView */
- (id)initWithTitle:(NSString *)title andView:(UIView *)view;
/** Initialize TSTabViewSection with section title and corresponding UIViewController */
- (id)initWithTitle:(NSString *)title andController:(UIViewController *)controller;
/** Initialize TSTabViewSection with dictionary which define content and appearance.
    @param info Dictionary containes information about tab.
 
 ```
     NSDictionary *tabInfo = @{
         @"tabContent" : [[UIView alloc] init],
         @"title" : @"Tab 1"
     };
 ```
 */
- (id)initWithDictionary:(NSDictionary *)dictionary;

@end

/**************************************************************************************************************************************/

/** TSTabViewItem contains information about menu item in  TSNavigationStrip. */
@interface TSTabViewItem : TSNavigationStripItem

@end

/**************************************************************************************************************************************/

/**
    TSNavigationStripComponent is base class, which provides appearance information for TSNavigationStripView's section or item.

 @warning
    In sake of code reuse, TSTabViewModel inherits from TSNavigationStripModel. 
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

/** Readonly reference to TSTabView instance managed by this model. */
@property (nonatomic, strong, readonly) TSTabView *tabView;

/**  Initialize instance of TSTabViewModel with corresponding TSTabView object.
     @param tabView Instance of TSTabView which would be managed by this data model.
 */
- (id)initWithTabView:(TSTabView *)tabView;

/** Insert new tab/page into TSTabViewModel. TSTabView would be notified about changes in data model.
    @param tabInfo Provide appearance and content infomation about new tab.
    @param index Insert position.
    @param animated If YES insertion would be done aniamted.
 */
- (void)insertNewTab:(TSTabViewSection *)tabInfo atIndex:(NSInteger)index animated:(BOOL)animated;
/**  Insert new tab/page into TSTabViewModel. TSTabView would be notified about changes in data model.
     @param index Remove position.
     @param animated If YES removing would be done aniamted.
 */
- (void)removeTabAtIndex:(NSInteger)index animated:(BOOL)animated;
/**  Provide content description for TSTabViewModel.
     @param tabs Array of TSTabViewSection or NSDictionary  objects. TSTabViewSection instance would be constructed if needed.
 */
- (void)setTabs:(NSArray *)tabs;

@end
