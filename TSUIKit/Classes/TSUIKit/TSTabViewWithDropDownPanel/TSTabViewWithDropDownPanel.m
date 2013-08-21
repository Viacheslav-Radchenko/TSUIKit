//
//  TSTabViewWithDropDownPanel.m
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

#import "TSTabViewWithDropDownPanel.h"
#import "TSUtils.h"
#import "TSDefines.h"
#import  <QuartzCore/QuartzCore.h>


typedef enum {
    kTSDropDownPanelState_Hidden,
    kTSDropDownPanelState_Show,
    kTSDropDownPanelState_Shown,
    kTSDropDownPanelState_Hide
} TSDropDownPanelState;

@interface TSTabViewWithDropDownPanel ()
{
    UIView *_dropDownPanelContainer;
    UIView *_dropDownPanelClipContainer;
    BOOL _dropDownPanelMovedDown; // Remember direction of last panel's move 
    TSDropDownPanelState _dropDownPanelState;
}

@end

@implementation TSTabViewWithDropDownPanel

- (id)initWithFrame:(CGRect)rect navigationMenu:(TSNavigationStripView *)navigationMenu
{
    VerboseLog();
    self = [super initWithFrame:rect navigationMenu:navigationMenu];
    if (self)
    {
        _showPanelBelowNavigationMenu = YES;
        _showPanelOnSelectedSectionTap = YES;
        _shouldAdjustTabsContainerSize = YES;
        _dropDownPanelState = kTSDropDownPanelState_Hidden;
        _dropDownPanelContainer = [[UIView alloc] initWithFrame:CGRectMake(0, (_showPanelBelowNavigationMenu ? navigationMenu.frame.size.height : 0), rect.size.width, 0)];
        _dropDownPanelContainer.backgroundColor = [UIColor clearColor];
        _dropDownPanelContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _dropDownPanelContainer.clipsToBounds = NO;
        [self insertSubview:_dropDownPanelContainer belowSubview:navigationMenu];
        
        _dropDownPanelClipContainer = [[UIView alloc] initWithFrame:_dropDownPanelContainer.bounds];
        _dropDownPanelClipContainer.backgroundColor = [UIColor clearColor];
        _dropDownPanelClipContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _dropDownPanelClipContainer.clipsToBounds = YES;
        [_dropDownPanelContainer addSubview:_dropDownPanelClipContainer];
    }
    return self;
}

#pragma mark - Setters & getters

- (void)setAttachedPanel:(UIView *)attachedPanel
{
    VerboseLog();
    if(_attachedPanel == attachedPanel)
        return;
    if(_attachedPanel)
    {
        [_attachedPanel removeFromSuperview];
    }
    _attachedPanel = attachedPanel;
    if(_attachedPanel)
    {
        _dropDownPanelContainer.layer.shadowColor = _attachedPanel.layer.shadowColor;
        _dropDownPanelContainer.layer.shadowOffset = _attachedPanel.layer.shadowOffset;
        _dropDownPanelContainer.layer.shadowOpacity = _attachedPanel.layer.shadowOpacity;
        _dropDownPanelContainer.layer.shadowRadius = _attachedPanel.layer.shadowRadius;

        [_dropDownPanelClipContainer addSubview:_attachedPanel];
        _attachedPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _attachedPanel.frame = CGRectMake(0, _dropDownPanelContainer.frame.size.height - _attachedPanel.frame.size.height, _dropDownPanelContainer.frame.size.width, _attachedPanel.frame.size.height);
    }
}

- (void)setshowPanelBelowNavigationMenu:(BOOL)showPanelBelowNavigationMenu
{
    _showPanelBelowNavigationMenu = showPanelBelowNavigationMenu;
    [self updateComponentsLayout];
}

- (BOOL)panelIsHidden
{
    return (_dropDownPanelState == kTSDropDownPanelState_Hidden);
}

- (void)showDropDownPanelWithAnimation:(BOOL)animated
{
    VerboseLog();
    if(_attachedPanel)
    {
        if(self.delegate && [self.delegate respondsToSelector:@selector(tabViewWithDropDownPanel:willShowPanel:animated:)])
        {
            [self.delegate tabViewWithDropDownPanel:self willShowPanel:_attachedPanel animated:animated];
        }
        _dropDownPanelState = kTSDropDownPanelState_Show;
        _scrollView.scrollEnabled = NO;
        _dropDownPanelContainer.hidden = NO;
        [TSUtils performViewAnimationBlock:^{
            VerboseLog();
            _dropDownPanelContainer.frame = CGRectMake(_dropDownPanelContainer.frame.origin.x, _dropDownPanelContainer.frame.origin.y, _dropDownPanelContainer.frame.size.width, _attachedPanel.frame.size.height);
             [self updateComponentsLayout];
        } withCompletion:^{
            VerboseLog();
            if(_dropDownPanelState == kTSDropDownPanelState_Show)
            {
                _dropDownPanelState = kTSDropDownPanelState_Shown;
                _scrollView.scrollEnabled = YES;
                if(self.delegate && [self.delegate respondsToSelector:@selector(tabViewWithDropDownPanel:didShowPanel:)])
                {
                    [self.delegate tabViewWithDropDownPanel:self didShowPanel:_attachedPanel];
                }
            }
        } animated:animated];
    }
}

- (void)hideDropDownPanelWithAnimation:(BOOL)animated
{
    VerboseLog();
    if(_attachedPanel)
    {
        if(self.delegate && [self.delegate respondsToSelector:@selector(tabViewWithDropDownPanel:willHidePanel:animated:)])
        {
            [self.delegate tabViewWithDropDownPanel:self willHidePanel:_attachedPanel animated:animated];
        }
        _dropDownPanelState = kTSDropDownPanelState_Hide;
        _scrollView.scrollEnabled = NO;
        [TSUtils performViewAnimationBlock:^{
            VerboseLog();
            _dropDownPanelContainer.frame = CGRectMake(_dropDownPanelContainer.frame.origin.x, _dropDownPanelContainer.frame.origin.y, _dropDownPanelContainer.frame.size.width, 0);
            [self updateComponentsLayout];
        } withCompletion:^{
            VerboseLog();
            if(_dropDownPanelState == kTSDropDownPanelState_Hide)
            {
                _scrollView.scrollEnabled = YES;
                _dropDownPanelContainer.hidden = YES;
                _dropDownPanelState = kTSDropDownPanelState_Hidden;
                if(self.delegate && [self.delegate respondsToSelector:@selector(tabViewWithDropDownPanel:didHidePanel:)])
                {
                    [self.delegate tabViewWithDropDownPanel:self didHidePanel:_attachedPanel];
                }
            }
        } animated:animated];
    }
}

- (void)movePanel:(CGFloat)delta finished:(BOOL)finished
{
    VerboseLog();
    if(_attachedPanel)
    {
        CGFloat height = MAX(0, MIN(_dropDownPanelContainer.frame.size.height + delta, _attachedPanel.frame.size.height));
        _dropDownPanelContainer.hidden = (height == 0);
        _scrollView.scrollEnabled = NO;
        if(height != _dropDownPanelContainer.frame.size.height)
        {
            _dropDownPanelMovedDown = (height > _dropDownPanelContainer.frame.size.height);
        }
        if(finished)
        {
            const CGFloat threshold = 0.1f * _attachedPanel.frame.size.height;
            if(_dropDownPanelContainer.frame.size.height < threshold ||
               (!_dropDownPanelMovedDown && _dropDownPanelContainer.frame.size.height < _attachedPanel.frame.size.height - threshold))
            {
                [self hideDropDownPanelWithAnimation:YES];
            }
            else
            {
                [self showDropDownPanelWithAnimation:YES];
            }
        }
        else
        {
            _dropDownPanelContainer.frame = CGRectMake(_dropDownPanelContainer.frame.origin.x, _dropDownPanelContainer.frame.origin.y, _dropDownPanelContainer.frame.size.width, height);
            [self updateComponentsLayout];
        }
    }
}

#pragma mark - Update layout

- (void)updateComponentsLayout
{
    VerboseLog();
    CGPoint leftCorner = CGPointMake(self.navigationMenuEdgeInsets.left, self.navigationMenuEdgeInsets.top);
    CGPoint rightCorner = CGPointMake(self.frame.size.width - self.navigationMenuEdgeInsets.right, self.navigationMenuEdgeInsets.top);
    CGRect navigationMenuRect = CGRectMake(leftCorner.x,
                                           leftCorner.y,
                                           rightCorner.x - leftCorner.x,
                                           self.navigationMenu.frame.size.height);
    CGRect dropDownPanelRect = CGRectMake(navigationMenuRect.origin.x,
                                          CGRectGetMaxY(navigationMenuRect),
                                          navigationMenuRect.size.width,
                                          _dropDownPanelContainer.frame.size.height);

    if(!_showPanelBelowNavigationMenu)
    {
        // swap views location
        dropDownPanelRect = CGRectMake(dropDownPanelRect.origin.x, navigationMenuRect.origin.y, dropDownPanelRect.size.width,dropDownPanelRect.size.height);
        navigationMenuRect = CGRectOffset(navigationMenuRect,0,_dropDownPanelContainer.frame.size.height);
    }
    
    self.navigationMenu.frame = navigationMenuRect;
    
    _dropDownPanelContainer.frame = dropDownPanelRect;
    
    // if _navigationMenuEdgeInsets is not Zero, then calculate frame for _scrollView relative to root view bounds
    if(self.navigationMenuEdgeInsets.left   != UIEdgeInsetsZero.left ||
       self.navigationMenuEdgeInsets.right  != UIEdgeInsetsZero.right ||
       self.navigationMenuEdgeInsets.top    != UIEdgeInsetsZero.top ||
       self.navigationMenuEdgeInsets.bottom != UIEdgeInsetsZero.bottom)
    {
         // -> (navigationMenu is above scrollView)
        leftCorner = CGPointMake(self.contentViewEdgeInsets.left, self.contentViewEdgeInsets.top);
        rightCorner = CGPointMake(self.frame.size.width - self.contentViewEdgeInsets.right, self.frame.size.height - self.contentViewEdgeInsets.bottom);
        _scrollView.frame = CGRectMake(leftCorner.x, leftCorner.y, rightCorner.x - leftCorner.x, rightCorner.y - leftCorner.y);
    }
    else // if _navigationMenuEdgeInsets is Zero, then calculate frame for _scrollView relative to _navigationMenu 
    {
        // -> (navigationMenu is next to scrollView)
        CGFloat height = self.navigationMenu.frame.size.height + (self.shouldAdjustTabsContainerSize ? dropDownPanelRect.size.height : 0);
        leftCorner = CGPointMake(self.contentViewEdgeInsets.left, height + self.contentViewEdgeInsets.top);
        rightCorner = CGPointMake(self.frame.size.width - self.contentViewEdgeInsets.right, self.frame.size.height - self.contentViewEdgeInsets.bottom);
        _scrollView.frame = CGRectMake(leftCorner.x, leftCorner.y, rightCorner.x - leftCorner.x, rightCorner.y - leftCorner.y);
    }
}

#pragma mark - TSNavigationStripViewDelegate

- (void)navigationStripDidRecognizeTapOnSelectedSection:(TSNavigationStripView *)navigationStripView
{
    VerboseLog();
    if(self.showPanelOnSelectedSectionTap)
    {
        if([self panelIsHidden])
        {
            [self showDropDownPanelWithAnimation:YES];
        }
        else
        {
            [self hideDropDownPanelWithAnimation:YES];
        }
    }
}

@end
