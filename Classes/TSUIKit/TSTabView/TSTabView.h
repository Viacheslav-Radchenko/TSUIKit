//
//  TSTabView.h
//  TSUIKit
//
//  Created by Viacheslav Radchenko on 6/18/13.
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

#import <UIKit/UIKit.h>
#import "TSTabViewDataSource.h"
#import "TSTabViewDelegate.h"
#import "TSNavigationStripView.h"

/**
    @abstract   TSTabView is a container for set of views or view controllers.
                Provides smooth animations while switching between visible tabs and for dynamic content modification.
                Basic layout shown below:
 *
    +------------+---+--------------+---+-------------+
    | LEFT ITEMS | < |   SECTIONS   | > | RIGHT ITEMS |  <-- TSNavigationStripView as a subview. Set during TSTabView initialization.
    +------------+---+--------------+---+-------------+
    |                                                 |
    |                                                 |
    |                      TABS                       |  <-- Content container. Tabs can be represented by subclasses of UIView or UIViewController.
    |                                                 |
    |                                                 |
    +-------------------------------------------------+                                           
 */
@interface TSTabView : UIView
{
    UIScrollView *_scrollView;
}

@property (nonatomic, weak) id<TSTabViewDelegate>   delegate;
@property (nonatomic, weak) id<TSTabViewDataSource> dataSource;

/**
    @abstract   Navigation control. Set during TSTabView initialization.
 */
@property (nonatomic, strong, readonly) TSNavigationStripView *navigationMenu;

/**
    @abstract   Customize position and bounds of TSNavigationStripView and tabs container in root view.
                By default both insets are UIEdgeInsetsZero: 
                    - TSNavigationStripView is located along top edge of TSTabView view.
                    - Tabs container is located below and fill remaining space in TSTabView view.
                If navigationMenuEdgeInsets is UIEdgeInsetsZero, then contentViewEdgeInsets is applied considering TSNavigationStripView size.
                If navigationMenuEdgeInsets isn't UIEdgeInsetsZero, then contentViewEdgeInsets is applied relative root view's frame,
                size of TSNavigationStripView isn't taken into account during layout calculation.
                This allows creating overlapping layouts when TSNavigationStripView is located above tabs container.
    @def        UIEdgeInsetsZero
 */
@property (nonatomic, assign) UIEdgeInsets navigationMenuEdgeInsets;
@property (nonatomic, assign) UIEdgeInsets contentViewEdgeInsets;

/**
    @abstract Currently selected tab.
 */
@property (nonatomic, assign, readonly) NSInteger selectedTab;

@property (nonatomic, assign) BOOL bounces;

/**
    @abstract Should be set appropriatly in case if tab's content represented with UIVewController's subclasses.
              Needed to keep valid UIViewControllers hierarchy.
 */
@property (nonatomic, weak) UIViewController *parentViewController;

- (id)initWithFrame:(CGRect)rect navigationMenu:(TSNavigationStripView *)navigationMenu;

- (void)reloadData;
- (void)reloadTabsData;

/**
    @abstract Selection.
 */
- (void)selectTabAtIndex:(NSInteger)index animated:(BOOL)animated;

/**
    @abstract Content modification. Should be invoked when data source content has been changed.
 */
- (void)insertTabAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)removeTabAtIndex:(NSInteger)index animated:(BOOL)animated;

@end
