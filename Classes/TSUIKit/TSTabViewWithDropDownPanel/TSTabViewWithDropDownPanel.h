//
//  TSTabViewWithDropDownPanel.h
//  TSUIKit
//
//  Created by Viacheslav Radchenko on 7/1/13.
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
#import "TSTabView.h"
#import "TSTabViewWithDropDownPanelDelegate.h"

/**
    @abstract   TSTabViewWithDropDownPanel extends TSTabView. 
                Custom panel can be attached to navigation menu and pull down/up on top of tabs container.
                Provides smooth animations while switching between visible tabs and for dynamic content modification.
                Basic layout shown below:
 *
    +-------------------------------------------------+
    |              TSNavigationStripView              |  <-- TSNavigationStripView as a subview. Set during TSTabView initialization.
    +-------------------------------------------------+
    |                                                 |
    |              ATTACHED PANEL (MENU)              | <-- Custom UIView.
    |                                                 |
    +-------------------------------------------------+
    |                                                 |
    |                      TABS                       |  <-- Content container. Tabs can be represented by subclasses of UIView or UIViewController.
    |                                                 |
    |                                                 |
    +-------------------------------------------------+
 */

@interface TSTabViewWithDropDownPanel : TSTabView

/**
    @abstract   Custom UIView. Would be shouwn in drop down container.
    @def        nil
 */
@property (nonatomic, strong) UIView *attachedPanel;

/**
    @abstract   TSTabViewWithDropDownPanelDelegate extends TSTabViewDelegate with callback for DropDownPanel state changes.
 */
@property (nonatomic, weak) id<TSTabViewWithDropDownPanelDelegate> delegate;

/**
    @abstract   If YES then tabs container's size would be changed during DropDownPanel show/hide animation
                If NO then DropDownPanel will be shown on top of tabs container.
    @def        YES
 */
@property (nonatomic, assign) BOOL shouldAdjustTabsContainerSize;

/**
    @abstract   If YES then DropDownPanel will be shown/hidden on selected section tap.
    @def        YES
 */
@property (nonatomic, assign) BOOL showPanelOnSelectedSectionTap;

/**
    @abstract   If YES then DropDownPanel will be shown below NavigationMenu.
                If NO then DropDownPanel will be shown above NavigationMenu and NavigationMenu itself will slide down.
    @def        YES
 */
@property (nonatomic, assign) BOOL showPanelBelowNavigationMenu;

/**
    @abstract   DropDownPanel visibility status.
 */
@property (nonatomic, assign, readonly) BOOL panelIsHidden;

- (void)showDropDownPanelWithAnimation:(BOOL)animated;
- (void)hideDropDownPanelWithAnimation:(BOOL)animated;
- (void)movePanel:(CGFloat)delta finished:(BOOL)finished;

@end
