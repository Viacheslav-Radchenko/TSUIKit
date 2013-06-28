//
//  SSTabView.h
//  SSUIKit
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
#import "SSTabViewDataSource.h"
#import "SSTabViewDelegate.h"
#import "SSNavigationStripView.h"

/**
 *  @abstract   SSTabView is a container for set of views or view controllers.
 *              Provides smooth animations while switching between visible tabs and for dynamic content modification.
 *              Basic layout shown below:
 *
 *  +------------+---+--------------+---+-------------+
 *  | LEFT ITEMS | < |   SECTIONS   | > | RIGHT ITEMS |  <-- SSNavigationStripView as a subview. Set during SSTabView initialization.
 *  +------------+---+--------------+---+-------------+
 *  |                                                 |
 *  |                                                 |
 *  |                      TABS                       |  <-- Content container. Tabs can be represented by subclasses of UIView or UIViewController.
 *  |                                                 |
 *  |                                                 |
 *  +-------------------------------------------------+                                           
 */
@interface SSTabView : UIView

@property (nonatomic, weak) id<SSTabViewDelegate>   delegate;
@property (nonatomic, weak) id<SSTabViewDataSource> dataSource;

/**
 *  @abstract   Navigation control. Set during SSTabView initialization.
 */
@property (nonatomic, strong, readonly) SSNavigationStripView *navigationMenu;

/**
 *  @abstract   Customize position and bounds of SSNavigationStripView and tabs container in root view.
 *              By default both insets are UIEdgeInsetsZero: 
 *                  - SSNavigationStripView is located along top edge of SSTabView view.
 *                  - Tabs container is located below and fill remaining space in SSTabView view.
 *              If navigationMenuEdgeInsets is UIEdgeInsetsZero, then contentViewEdgeInsets is applied considering SSNavigationStripView size.
 *              If navigationMenuEdgeInsets isn't UIEdgeInsetsZero, then contentViewEdgeInsets is applied relative root view's frame,
 *              size of SSNavigationStripView isn't taken into account during layout calculation.
 *              This allows creating overlapping layouts when SSNavigationStripView is located above tabs container.
 *  @def        UIEdgeInsetsZero
 */
@property (nonatomic, assign) UIEdgeInsets navigationMenuEdgeInsets;
@property (nonatomic, assign) UIEdgeInsets contentViewEdgeInsets;

/**
 *  @abstract Currently selected tab.
 */
@property (nonatomic, assign, readonly) NSInteger selectedTab;

/**
 *  @abstract Should be set appropriatly in case if tab's content represented with UIVewController's subclasses.
 *            Needed to keep valid UIViewControllers hierarchy.
 */
@property (nonatomic, weak) UIViewController *parentViewController;

- (id)initWithFrame:(CGRect)rect navigationMenu:(SSNavigationStripView *)navigationMenu;

- (void)reloadData;
- (void)reloadTabsData;

/**
 *  @abstract Selection.
 */
- (void)selectTabAtIndex:(NSInteger)index animated:(BOOL)animated;

/**
 *  @abstract Content modification. Should be invoked when data source content has been changed.
 */
- (void)insertTabAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)removeTabAtIndex:(NSInteger)index animated:(BOOL)animated;

@end
