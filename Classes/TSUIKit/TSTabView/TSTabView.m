//
//  TSTabView.m
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

#import "TSTabView.h"
#import "TSUtils.h"
#import "TSDefines.h"
 

@interface TSTabView () <UIScrollViewDelegate, TSNavigationStripViewDelegate>
{
    TSNavigationStripView *_navigationMenu;
    
    // Tabs can be represented by subclasses of UIView or UIViewController.
    NSMutableArray *_tabsContent;
    
    struct {
        BOOL dragging;
        BOOL justFinished;
        CGFloat lastScrollOffset;
    } _draggingInfo;
}

@end

@implementation TSTabView

- (id)initWithFrame:(CGRect)frame navigationMenu:(TSNavigationStripView *)navigationMenu
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        _tabsContent = [[NSMutableArray alloc] init];
        
        _navigationMenu = navigationMenu;
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _navigationMenu.frame.size.height, frame.size.width, frame.size.height - _navigationMenu.frame.size.height)];
        [_scrollView setShowsVerticalScrollIndicator:NO];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        [self addSubview:_scrollView];
        
        _navigationMenu.frame = CGRectMake(0, 0, frame.size.width, _navigationMenu.frame.size.height);
        _navigationMenu.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _navigationMenu.delegate = self;
        [self addSubview:_navigationMenu];
    }
    return self;
}

- (void)layoutSubviews
{
    VerboseLog();
    [super layoutSubviews];
    [self updateTabsLayout];
    [self updateContentSize];
    [self updateTabsScrollPositionForIndex:_navigationMenu.selectedSection];
}

#pragma mark - Setters & Getters

- (NSInteger)selectedTab
{
    VerboseLog();
    return _navigationMenu.selectedSection;
}

- (void)setDataSource:(id<TSTabViewDataSource>)dataSource
{
    VerboseLog();
    _dataSource = dataSource;
    _navigationMenu.dataSource = dataSource;
}

- (void)setNavigationMenuEdgeInsets:(UIEdgeInsets)edgeInsets
{
    _navigationMenuEdgeInsets = edgeInsets;
    [self updateComponentsLayout];
}

- (void)setContentViewEdgeInsets:(UIEdgeInsets)edgeInsets
{
    _contentViewEdgeInsets = edgeInsets;
    [self updateComponentsLayout];
}

- (BOOL)bounces
{
    return _scrollView.bounces;
}

- (void)setBounces:(BOOL)bounces
{
    _scrollView.bounces = bounces;
}

#pragma mark - Update layout

- (void)updateComponentsLayout
{
    CGPoint leftUpperCorner = CGPointMake(_navigationMenuEdgeInsets.left, _navigationMenuEdgeInsets.top);
    CGPoint rightUpperCorner = CGPointMake(self.frame.size.width - _navigationMenuEdgeInsets.right, _navigationMenuEdgeInsets.top);
    
    _navigationMenu.frame = CGRectMake(leftUpperCorner.x, leftUpperCorner.y, rightUpperCorner.x - leftUpperCorner.x, _navigationMenu.frame.size.height);
    
    // if _navigationMenuEdgeInsets is not Zero, then calculate frame for _scrollView relative to root view bounds
    if(_navigationMenuEdgeInsets.left != UIEdgeInsetsZero.left ||
       _navigationMenuEdgeInsets.right != UIEdgeInsetsZero.right ||
       _navigationMenuEdgeInsets.top != UIEdgeInsetsZero.top ||
       _navigationMenuEdgeInsets.bottom != UIEdgeInsetsZero.bottom)
    {
        CGPoint leftUpperCorner = CGPointMake(_contentViewEdgeInsets.left, _contentViewEdgeInsets.top);
        CGPoint rightLowerCorner = CGPointMake(self.frame.size.width - _contentViewEdgeInsets.right, self.frame.size.height - _contentViewEdgeInsets.bottom);
        
        _scrollView.frame = CGRectMake(leftUpperCorner.x, leftUpperCorner.y, rightLowerCorner.x - leftUpperCorner.x, rightLowerCorner.y - leftUpperCorner.y);
    }
    else // if _navigationMenuEdgeInsets is Zero, then calculate frame for _scrollView relative to _navigationMenu
    {
        CGPoint leftUpperCorner = CGPointMake(_contentViewEdgeInsets.left, _navigationMenu.frame.size.height + _contentViewEdgeInsets.top);
        CGPoint rightLowerCorner = CGPointMake(self.frame.size.width - _contentViewEdgeInsets.right, self.frame.size.height - _navigationMenu.frame.size.height - _contentViewEdgeInsets.bottom);
        _scrollView.frame = CGRectMake(leftUpperCorner.x, leftUpperCorner.y, rightLowerCorner.x - leftUpperCorner.x, rightLowerCorner.y - leftUpperCorner.y);
    }
}

#pragma mark - Reload content

- (void)reloadData
{
    VerboseLog();
    if(!self.dataSource)
        return;
    [_navigationMenu reloadData];
    [self reloadTabsContent];
    [self updateTabsScrollPositionForIndex:_navigationMenu.selectedSection];
}

- (void)reloadTabsData
{
    VerboseLog();
    if(!self.dataSource)
        return;
    [_navigationMenu reloadSectionsData];
    [self reloadTabsContent];
    [self updateTabsScrollPositionForIndex:_navigationMenu.selectedSection];
}

- (void)reloadTabsContent
{
    VerboseLog();
    if(!self.dataSource)
        return;
    
    [_tabsContent enumerateObjectsUsingBlock:^(NSObject *object, NSUInteger idx, BOOL *stop) {
        
        if([object isKindOfClass:[UIViewController class]])
        {
            UIViewController *controller = (UIViewController *)object;
            [controller willMoveToParentViewController:nil];
            [controller.view removeFromSuperview];
            [controller removeFromParentViewController];
        }
        else
        {
            UIView *view = (UIView *)object;
            [view removeFromSuperview];
        }
    }];
    
    [_tabsContent removeAllObjects];
    
    NSInteger tabsCount = [self.dataSource numberOfSections];
    for(int i = 0; i < tabsCount; ++i)
    {
        [self insertTabAtIndex:i];
    }
}

#pragma mark - Update tabs layout

- (void)updateTabsScrollPositionForIndex:(NSInteger)index
{
    VerboseLog();
    _scrollView.contentOffset = CGPointMake(index * self.frame.size.width, 0);
}

- (void)updateTabsLayout
{
    VerboseLog();
    [_tabsContent enumerateObjectsUsingBlock:^(NSObject *object, NSUInteger idx, BOOL *stop) {
        UIView *view;
        if([object isKindOfClass:[UIViewController class]])
        {
            UIViewController *controller = (UIViewController *)object;
            view = controller.view;
        }
        else
        {
            view = (UIView *)object;
        }
        view.frame = CGRectMake(_scrollView.frame.size.width * idx, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
        
    }];
}

- (void)updateContentSize
{
    VerboseLog();
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * _tabsContent.count, _scrollView.frame.size.height);
}

#pragma mark - Change selection

- (void)selectTabAtIndex:(NSInteger)index animated:(BOOL)animated
{
    VerboseLog();
    if(0 <= index && index < _tabsContent.count)
    {
        [self selectTabAtIndex:index animated:animated internal:NO];
        [_navigationMenu selectSectionAtIndex:index animated:animated];
    }
}

- (void)selectTabAtIndex:(NSInteger)index animated:(BOOL)animated internal:(BOOL)internal
{
    VerboseLog();
    if(animated && abs(_navigationMenu.selectedSection - index) > 1)
    {
        [self smartSwapTabToIndex:index];
    }
    else
    {
        [TSUtils performViewAnimationBlock:^{
            [self updateTabsScrollPositionForIndex:index];
        } withCompletion:nil animated:animated];
    }
}

- (void)smartSwapTabToIndex:(NSInteger)index
{
    // In case if just selected tab is not sibling to previous selected, then do some tweak so user wouldn't see any tabs between current selected and previous selectd tabs during selection change animation.
    // Tab that going to become visible placed next to current selected tab, scroll animation played and on completion selected tab placed on its original place, contentOffset changed accordingly.
    UIView *view;
    NSObject *object = _tabsContent[index];
    if([object isKindOfClass:[UIViewController class]])
    {
        UIViewController *controller = (UIViewController *)object;
        view = controller.view;
    }
    else
    {
        view = (UIView *)object;
    }
    
    [_scrollView bringSubviewToFront:view];
    
    int tmpIndex = (_navigationMenu.selectedSection - index > 0 ? _navigationMenu.selectedSection - 1 : _navigationMenu.selectedSection + 1);
    view.frame = CGRectMake(_scrollView.frame.size.width * tmpIndex, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
    
    
    UIView *backView;
    object = _tabsContent[tmpIndex];
    if([object isKindOfClass:[UIViewController class]])
    {
        UIViewController *controller = (UIViewController *)object;
        backView = controller.view;
    }
    else
    {
        backView = (UIView *)object;
    }
    backView.hidden = YES;
    
    [TSUtils performViewAnimationBlock:^{
        [self updateTabsScrollPositionForIndex:tmpIndex];
    } withCompletion:^{
        view.frame = CGRectMake(_scrollView.frame.size.width * index, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
        [self updateTabsScrollPositionForIndex:index];
        backView.hidden = NO;
    } animated:YES];
}

#pragma mark - Modify content

- (void)insertTabAtIndex:(NSInteger)index
{
    if([self.dataSource respondsToSelector:@selector(viewControllerForTabAtIndex:)])
    {
        UIViewController *controller = [self.dataSource viewControllerForTabAtIndex:index];
        controller.view.frame = CGRectMake(_scrollView.frame.size.width * index, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
        controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        if(self.parentViewController)
            [self.parentViewController addChildViewController:controller];
        [_scrollView insertSubview:controller.view atIndex:0];
        if(self.parentViewController)
            [controller didMoveToParentViewController:self.parentViewController];
        [_tabsContent insertObject:controller atIndex:index];
    }
    else if([self.dataSource respondsToSelector:@selector(viewForTabAtIndex:)])
    {
        UIView *view = [self.dataSource viewForTabAtIndex:index];
        view.frame = CGRectMake(_scrollView.frame.size.width * index, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_scrollView insertSubview:view atIndex:0];
        [_tabsContent insertObject:view atIndex:index];
    }
    else
    {
        NSAssert(NO,@"TSTabViewDataSource must implement one of the following methods tabViewControllerForTabAtIndex: or tabViewControllerForTabAtIndex:");
    }
}

- (void)insertTabAtIndex:(NSInteger)index animated:(BOOL)animated
{
    VerboseLog();
    [self.navigationMenu insertSectionAtIndex:index animated:animated];
    
    NSInteger realIndex = MIN(MAX(0, index), _tabsContent.count);
    [self insertTabAtIndex:realIndex];
    
    NSAssert([self.dataSource numberOfSections] == _tabsContent.count, @"Number of tabs in TabView should be equal to the number of entities in DataSource");
    
    [self updateContentSize];
    
    [TSUtils performViewAnimationBlock:^{
        [self updateTabsLayout];
        [self updateTabsScrollPositionForIndex:_navigationMenu.selectedSection];
    } withCompletion:nil animated:animated];
}

- (void)removeTabAtIndex:(NSInteger)index animated:(BOOL)animated
{
    VerboseLog();
    if(0 <= index && index < _tabsContent.count)
    {
        NSObject *object = _tabsContent[index];
        if([object isKindOfClass:[UIViewController class]])
        {
            UIViewController *controller = (UIViewController *)object;
            [controller willMoveToParentViewController:nil];
            [controller.view removeFromSuperview];
            [controller removeFromParentViewController];
        }
        else
        {
            UIView *view = (UIView *)object;
            [view removeFromSuperview];
        }
        [_tabsContent removeObjectAtIndex:index];
        
        [self.navigationMenu removeSectionAtIndex:index animated:animated];
        
        NSAssert([self.dataSource numberOfSections] == _tabsContent.count, @"Number of  tabs in TabView should be equal to the number of entities in DataSource");
        
        [self updateContentSize];
        
        [TSUtils performViewAnimationBlock:^{
            [self updateTabsLayout];
            [self updateTabsScrollPositionForIndex:_navigationMenu.selectedSection];
        } withCompletion:nil animated:animated];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(_draggingInfo.dragging) // User dragging scrollView
    {
        CGFloat normOffset = (_scrollView.contentOffset.x - _navigationMenu.selectedSection * self.frame.size.width)/self.frame.size.width;
        VerboseLog(@"%f",normOffset);
        [_navigationMenu scrollSelectedSectionTo:normOffset];
        if(self.delegate && [self.delegate respondsToSelector:@selector(tabView:didScrollTo:)])
        {
            [self.delegate tabView:self didScrollTo:normOffset];
        }
    }
    else if(_draggingInfo.justFinished) // Dragging has just finished. Check what page would be selected after deceleration animation stops
    {
        int tabIndex = _navigationMenu.selectedSection;
        if(_scrollView.contentOffset.x > _navigationMenu.selectedSection * _scrollView.frame.size.width)
        {
            if(_scrollView.contentOffset.x > _draggingInfo.lastScrollOffset)
            {
                ++tabIndex;
            }
        }
        else
        {
            if(_scrollView.contentOffset.x < _draggingInfo.lastScrollOffset)
            {
                --tabIndex;
            }
        }
        tabIndex = MIN(_tabsContent.count - 1, MAX(0, tabIndex));
        [_navigationMenu selectSectionAtIndex:tabIndex animated:YES];
        _draggingInfo.justFinished = NO;
    }
    _draggingInfo.lastScrollOffset = _scrollView.contentOffset.x;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _draggingInfo.dragging = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    _draggingInfo.dragging = NO;
    _draggingInfo.justFinished = YES; // Couldn't determine for sure what tab would be visible after deceleration stops. Lets see how contentOffset will change in next scrollViewDidScroll.
}

#pragma mark - TSNavigationStripViewDelegate

- (void)navigationStrip:(TSNavigationStripView *)navigationStripView itemAtIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide didChangeState:(BOOL)selected
{
    VerboseLog();
    if(self.delegate && [self.delegate respondsToSelector:@selector(tabView:menuItemAtIndex:fromLeftSide:didChangeState:)])
    {
        [self.delegate tabView:self menuItemAtIndex:index fromLeftSide:leftSide didChangeState:selected];
    }
}

- (void)navigationStrip:(TSNavigationStripView *)navigationStripView willSelectSectionAtIndex:(NSInteger)index animated:(BOOL)animated
{
    VerboseLog();
    if(self.delegate && [self.delegate respondsToSelector:@selector(tabView:willSelectTabAtIndex:animated:)])
    {
        [self.delegate tabView:self willSelectTabAtIndex:index animated:animated];
    }
    
    [self selectTabAtIndex:index animated:animated internal:YES];
}

- (void)navigationStrip:(TSNavigationStripView *)navigationStripView didSelectSectionAtIndex:(NSInteger)index
{
    VerboseLog();
    if(self.delegate && [self.delegate respondsToSelector:@selector(tabView:didSelectTabAtIndex:)])
    {
        [self.delegate tabView:self didSelectTabAtIndex:index];
    }
}

- (void)navigationStrip:(TSNavigationStripView *)navigationStripView didScrollTo:(CGFloat)normScrollOffset
{
    VerboseLog();
    if(self.delegate && [self.delegate respondsToSelector:@selector(tabView:didScrollTo:)])
    {
        [self.delegate tabView:self didScrollTo:normScrollOffset];
    }
    CGFloat xOffset = (_navigationMenu.selectedSection + normScrollOffset) * self.frame.size.width;
    if(!_scrollView.bounces)
        xOffset = MAX( 0, MIN( xOffset, (_tabsContent.count - 1) * self.frame.size.width));
    [_scrollView setContentOffset:CGPointMake(xOffset, 0)];
}

- (void)navigationStripDidEndScroll:(TSNavigationStripView *)navigationStripView
{
    VerboseLog();
    [_scrollView setContentOffset:CGPointMake(_navigationMenu.selectedSection * self.frame.size.width, 0) animated:YES];
}

@end
