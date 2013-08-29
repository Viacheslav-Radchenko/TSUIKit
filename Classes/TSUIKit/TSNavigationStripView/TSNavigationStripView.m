//
//  TSNavigationStripView.m
//  Created by Viacheslav Radchenko on 6/10/13.
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

#import <QuartzCore/QuartzCore.h>
#import "TSNavigationStripView.h"
#import "TSScrollView.h"
#import "TSUtils.h"
#import "TSDefines.h"
 

#define LEFT_SIDE_BUTTON_TAG    1
#define RIGHT_SIDE_BUTTON_TAG   2

/**
    @abstract   Information container. For internal use. 
 */

@interface TSNavigationStripComponentInfo : UIView

@property (nonatomic, assign) CGFloat defaultWidth;
@property (nonatomic, assign) CGFloat defaultSelectedWidth;
@property (nonatomic, strong) UIColor *defaultBackgroundColor;
@property (nonatomic, strong) UIColor *defaultSelectedBackgroundColor;
@property (nonatomic, strong) UIFont  *defaultFont;
@property (nonatomic, strong) UIFont  *defaultSelectedFont;

@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UIButton *control;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation TSNavigationStripComponentInfo

@end

/**************************************************************************************************************************************/

@interface TSNavigationStripView () <UIScrollViewDelegate>
{
    // Basic hierarchy
    UIView         *_leftContainerView;
    UIView         *_rightContainerView;
    UIView         *_centerContainerView;
    UIImageView    *_backgroundImageView;
    
    // Sections container hierarchy
    UIView         *_sectionsContainerView;
    UIScrollView   *_sectionsScrollView;
    UIImageView    *_emptySpaceHolderLeftImageView;
    UIImageView    *_emptySpaceHolderRightImageView;
    
    // Containers for TSNavigationStripComponentInfo
    NSMutableArray *_sections;
    NSMutableArray *_leftItems;
    NSMutableArray *_rightItems;
    
    // Alpha mask type for sections container
    NSInteger       _maskSectionsContainerEdgesType;
    
    struct {
        CGFloat         startOffset;
        CGFloat         leftSectionOffset;
        CGFloat         rightSectionOffset;
        CGFloat         normScroll;
        BOOL            dragging;
    } _sectionDraggingInfo;
}

@end

@implementation TSNavigationStripView

- (id)initWithFrame:(CGRect)rect
{
    VerboseLog();
    self = [super initWithFrame:rect];
    if (self)
    {
        // Initialization code
        _selectedSection = 0;
        _selectedSectionWidth = 256;
        _sectionWidth = 128;
        _autohideNavigationButtons = YES;
        _navigationButtonsHidden = NO;
        _maskSectionsContainerEdges = YES;
        _sectionsAligment = UIViewContentModeCenter;
        
        _sections = [[NSMutableArray alloc] init];
        _leftItems = [[NSMutableArray alloc] init];
        _rightItems = [[NSMutableArray alloc] init];
        
        // Background appearance
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width,  rect.size.height)];
        _backgroundImageView.backgroundColor = [UIColor clearColor];
        _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _backgroundImageView.hidden = YES;
        [self addSubview:_backgroundImageView];
        
        UIView *rootContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width,  rect.size.height)];
        rootContainer.backgroundColor = [UIColor clearColor];
        rootContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        rootContainer.layer.masksToBounds = YES;
        [self addSubview:rootContainer];
        
        // Left container for items
        _leftContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, rect.size.height)];
        _leftContainerView.backgroundColor = [UIColor clearColor];
        _leftContainerView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [rootContainer addSubview:_leftContainerView];
        
         // Right container for items
        _rightContainerView = [[UIView alloc] initWithFrame:CGRectMake(rect.size.width, 0, 0, rect.size.height)];
        _rightContainerView.backgroundColor = [UIColor clearColor];
        _rightContainerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
        [rootContainer addSubview:_rightContainerView];
        
        // Center container for sections
        _centerContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
        _centerContainerView.backgroundColor = [UIColor clearColor];
        _centerContainerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [rootContainer addSubview:_centerContainerView];
        
        // Sections container
        _sectionsContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
        _sectionsContainerView.backgroundColor = [UIColor clearColor];
        _sectionsContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_centerContainerView addSubview:_sectionsContainerView];
        
        // Scroll view sections
        TSScrollView *scrollView = [[TSScrollView alloc] initWithFrame:_sectionsContainerView.bounds];
        [scrollView allowCancelTouchesForClasses:@[NSStringFromClass([UIButton class])]];
        _sectionsScrollView = scrollView;
        _sectionsScrollView.delegate = self;
        _sectionsScrollView.bounces = (_sectionsAligment == UIViewContentModeCenter);
        _sectionsScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _sectionsScrollView.backgroundColor = [UIColor clearColor];
        _sectionsScrollView.scrollEnabled = YES;
        _sectionsScrollView.showsHorizontalScrollIndicator = NO;
        _sectionsScrollView.showsVerticalScrollIndicator = NO;
        [_sectionsContainerView addSubview:_sectionsScrollView];
        
        _emptySpaceHolderLeftImageView = [[UIImageView alloc] initWithFrame:_sectionsScrollView.bounds];
        _emptySpaceHolderLeftImageView.backgroundColor = [UIColor clearColor];
        _emptySpaceHolderLeftImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _emptySpaceHolderLeftImageView.hidden = YES;
        [_sectionsScrollView addSubview:_emptySpaceHolderLeftImageView];
        
        _emptySpaceHolderRightImageView = [[UIImageView alloc] initWithFrame:_sectionsScrollView.bounds];
        _emptySpaceHolderRightImageView.backgroundColor = [UIColor clearColor];
        _emptySpaceHolderRightImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _emptySpaceHolderRightImageView.hidden = YES;
        [_sectionsScrollView addSubview:_emptySpaceHolderRightImageView];
        
        // Left side naviagtion button
        int navigationButtonWidth = rect.size.height;
        _leftNavigationButton = [[UIButton alloc] initWithFrame:CGRectMake(-navigationButtonWidth, 0, navigationButtonWidth, rect.size.height)];
        _leftNavigationButton.tag = LEFT_SIDE_BUTTON_TAG;
        _leftNavigationButton.backgroundColor = [UIColor clearColor];
        _leftNavigationButton.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [_leftNavigationButton addTarget:self action:@selector(sideButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_centerContainerView addSubview:_leftNavigationButton];
        
        // Right side naviagtion button
        _rightNavigationButton = [[UIButton alloc] initWithFrame:CGRectMake(rect.size.width, 0, navigationButtonWidth, rect.size.height)];
        _rightNavigationButton.tag = RIGHT_SIDE_BUTTON_TAG;
        _rightNavigationButton.backgroundColor = [UIColor clearColor];
        _rightNavigationButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
        [_rightNavigationButton addTarget:self action:@selector(sideButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_centerContainerView addSubview:_rightNavigationButton];
    }
    return self;
}

- (void)layoutSubviews
{
    VerboseLog();
    [super layoutSubviews];
    [self updateSectionsScrollSizeOnlyIfNewSizeGreater:NO];
    [self updateSectionsLayout];
    [self updateEmptySpaceHolderLayout];
    [self updateSectionsScrollPosition];
    [self updateSectionsViewMaskLayout];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    VerboseLog();
    // Update mask for sections container.
    // In case if sections scrolled to left side or right side it may need to change mask type
    [self updateSectionsViewMaskLayout];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    VerboseLog();
    // Update mask for sections container. 
    // In case if sections scrolled to left side or right side it may need to change mask type
    if(scrollView.dragging)
    {
        [self updateSectionsViewMaskLayout];
    }
    
    // Special case if aligment type is UIViewContentModeCenter and user dragging sections.
    // Scrolling replaced with manual calculation of selected section position and resizing sibling sections.
    if(_sectionsAligment == UIViewContentModeCenter && _sections.count > 1 && _sectionDraggingInfo.dragging)
    {
        CGFloat sectionsContainerWidth = [self sectionsContainerWidth];
        
        // Calculate delta offset since last time
        float delta = (int)(scrollView.contentOffset.x - _sectionDraggingInfo.startOffset );
        scrollView.contentOffset = CGPointMake(_sectionDraggingInfo.startOffset, scrollView.contentOffset.y);

        // if delta > 0 then section moved to left 
        
        // Layout structure. Selected section can be moved left/right.
        //
        //  | sectionLeftLeftToSelected || sectionLeftToSelected       <-|    sectionSelected    |->     sectionRightToSelected || sectionRightRightToSelected |
        //                               ^                                                                                      ^
        //                               |____________________________________ Visible Area ____________________________________|
        // Layout selected section
        TSNavigationStripComponentInfo *selectedSectionInfo = _sections[_selectedSection];
        CGFloat originX = selectedSectionInfo.container.frame.origin.x - delta;
        
        if(_sectionDraggingInfo.rightSectionOffset > 0 && delta > 0) // if selected section in left most position and right section moving to center
        {
            _sectionDraggingInfo.rightSectionOffset += delta; // increase rightSectionOffset
            originX = _sectionDraggingInfo.startOffset;
        }
        else if(_sectionDraggingInfo.rightSectionOffset > 0) 
        {
            _sectionDraggingInfo.rightSectionOffset += delta; // decrease rightSectionOffset
            originX = _sectionDraggingInfo.startOffset;
        }
        else if(selectedSectionInfo.container.frame.origin.x - delta < _sectionDraggingInfo.startOffset) // if selected section in left most position and right section starts moving to center
        {
            _sectionDraggingInfo.rightSectionOffset += delta;
            originX = _sectionDraggingInfo.startOffset;
        }
        
        if(_sectionDraggingInfo.leftSectionOffset > 0 && delta < 0) // if selected section in right most position and left section moving to center
        {
            _sectionDraggingInfo.leftSectionOffset += fabs(delta); // increase leftSectionOffset
            originX = _sectionDraggingInfo.startOffset + sectionsContainerWidth - selectedSectionInfo.container.frame.size.width;
        }
        else if(_sectionDraggingInfo.leftSectionOffset > 0) 
        {
            _sectionDraggingInfo.leftSectionOffset -= delta; // decrease leftSectionOffset
            originX = _sectionDraggingInfo.startOffset + sectionsContainerWidth - selectedSectionInfo.container.frame.size.width;
        }
        else if(selectedSectionInfo.container.frame.origin.x - delta > _sectionDraggingInfo.startOffset + sectionsContainerWidth - selectedSectionInfo.container.frame.size.width) // if selected section in right most position and left section starts moving to center
        {
            _sectionDraggingInfo.leftSectionOffset += fabs(delta);
            originX = _sectionDraggingInfo.startOffset + sectionsContainerWidth - selectedSectionInfo.container.frame.size.width;
        }

        selectedSectionInfo.container.frame = CGRectMake(originX, selectedSectionInfo.container.frame.origin.y, selectedSectionInfo.container.frame.size.width, selectedSectionInfo.container.frame.size.height);

        // Layout section next to selected from left side
        UIView *sectionLeftToSelected;
        CGFloat widthForSectionLeftToSelected; // minimal section width
        if(_selectedSection - 1 >= 0) // if there is section before selected
        {
            TSNavigationStripComponentInfo *sectionInfo = _sections[_selectedSection - 1];
            sectionLeftToSelected =  sectionInfo.container;
            widthForSectionLeftToSelected = sectionInfo.defaultWidth;
        }
        else // else resize _emptySpaceHolderImageView
        {
            sectionLeftToSelected = _emptySpaceHolderLeftImageView;
            widthForSectionLeftToSelected = 0;
        }
        
        UIView *sectionLeftLeftToSelected; // section before sibling
        if(_selectedSection - 2 >= 0) // if there is section before sibling to selected from left size
        {
            TSNavigationStripComponentInfo *sectionInfo = _sections[_selectedSection - 2];
            sectionLeftLeftToSelected = sectionInfo.container;
        }
        else if(_selectedSection - 1 >= 0) // else resize _emptySpaceHolderImageView
        {
            sectionLeftLeftToSelected = _emptySpaceHolderLeftImageView;
        }
        
        CGFloat width = 0;
        if(sectionLeftLeftToSelected)
        {
           width =  MAX(widthForSectionLeftToSelected, originX - _sectionDraggingInfo.startOffset - _sectionDraggingInfo.leftSectionOffset);
            
            CGRect rect = sectionLeftLeftToSelected.frame;
            rect.size.width = originX - width - rect.origin.x;
            sectionLeftLeftToSelected.frame = rect;
        }
        else
        {
            width =  MAX(widthForSectionLeftToSelected, originX - _sectionDraggingInfo.startOffset);
        }
        sectionLeftToSelected.frame = CGRectMake(originX - width, sectionLeftToSelected.frame.origin.y, width, sectionLeftToSelected.frame.size.height);
       
        // Layout section next to selected from right side
        UIView *sectionRightToSelected;
        CGFloat widthForSectionRightToSelected;
        if(_selectedSection + 1 < _sections.count) // if there is section after selected
        {
            TSNavigationStripComponentInfo *sectionInfo = _sections[_selectedSection + 1];
            sectionRightToSelected = sectionInfo.container;
            widthForSectionRightToSelected = sectionInfo.defaultWidth;
        }
        else // if selected section is last then resize _emptySpaceHolderImageView
        {
            sectionRightToSelected = _emptySpaceHolderRightImageView;
            widthForSectionRightToSelected = 0;
        }
        
        UIView *sectionRightRightToSelected;
        if(_selectedSection + 2 < _sections.count) // if there is section before selected
        {
            TSNavigationStripComponentInfo *sectionInfo = _sections[_selectedSection + 2];
            sectionRightRightToSelected = sectionInfo.container;
        }
        else if(_selectedSection + 1  < _sections.count) // else resize _emptySpaceHolderImageView
        {
            sectionRightRightToSelected = _emptySpaceHolderRightImageView;
        }
        
        // if section is on the right side and now it is dragging left then change position and maybe resize
        originX = CGRectGetMaxX(selectedSectionInfo.container.frame);
        if(sectionRightRightToSelected)
        {
            width = MAX(widthForSectionRightToSelected, _sectionDraggingInfo.startOffset + sectionsContainerWidth - originX - _sectionDraggingInfo.rightSectionOffset);
            
            CGRect rect = sectionRightRightToSelected.frame;
            rect.size.width = CGRectGetMaxX(sectionRightRightToSelected.frame) - (originX + width);
            rect.origin.x = CGRectGetMaxX(sectionRightRightToSelected.frame) - rect.size.width;
            sectionRightRightToSelected.frame = rect;
        }
        else
        {
            width = MAX(widthForSectionRightToSelected, _sectionDraggingInfo.startOffset + sectionsContainerWidth - originX);
        }
        sectionRightToSelected.frame = CGRectMake(originX, sectionRightToSelected.frame.origin.y, width, sectionRightToSelected.frame.size.height);
        
        
        // Calculate normalized scroll offset of selected section.
        CGFloat normScroll = 0;
        CGFloat defPos = _sectionDraggingInfo.startOffset + (sectionsContainerWidth - selectedSectionInfo.container.frame.size.width)/2;
        CGFloat scrollOffset = selectedSectionInfo.container.frame.origin.x - defPos;
        if(scrollOffset > 0)
        {
            CGFloat maxOffset = (sectionsContainerWidth - selectedSectionInfo.container.frame.size.width)/2 + (sectionsContainerWidth - selectedSectionInfo.container.frame.size.width - widthForSectionLeftToSelected);
            if(maxOffset > 0)
            {
                normScroll = -MIN(1,(scrollOffset  + _sectionDraggingInfo.leftSectionOffset)/maxOffset);
            }
        }
        else
        {
            CGFloat maxOffset = (sectionsContainerWidth - selectedSectionInfo.container.frame.size.width)/2 + (sectionsContainerWidth - selectedSectionInfo.container.frame.size.width - widthForSectionRightToSelected);
            if(maxOffset > 0)
            {
                normScroll = MIN(1,(_sectionDraggingInfo.rightSectionOffset - scrollOffset)/maxOffset);
            }
        }
        
        if(_sectionDraggingInfo.normScroll != normScroll)
        {
            if(self.delegate && [self.delegate respondsToSelector:@selector(navigationStrip:didScrollTo:)])
            {
                [self.delegate navigationStrip:self didScrollTo:normScroll];
            }
            _sectionDraggingInfo.normScroll = normScroll;
        }
        
        [self updateSelectionMarkerLayout];
    }
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    VerboseLog();
    if(_sectionsAligment == UIViewContentModeCenter && _sections.count > 1)
    {
        [scrollView setContentOffset:scrollView.contentOffset animated:NO];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    VerboseLog();
    if(_sectionsAligment == UIViewContentModeCenter && _sections.count > 1)
    {
        // Start dragging section. Reset all values.
        _sectionDraggingInfo.startOffset = scrollView.contentOffset.x;
        _sectionDraggingInfo.normScroll = 0;
        _sectionDraggingInfo.leftSectionOffset = 0;
        _sectionDraggingInfo.rightSectionOffset = 0;
        _sectionDraggingInfo.dragging = YES;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    VerboseLog();
    if(_sectionsAligment == UIViewContentModeCenter && _sections.count > 1)
    {
        // End dragging section. Change selection if needed.
        _sectionDraggingInfo.dragging = NO;
        const CGFloat kThreshold = 0.5f;
        BOOL sectionChanged = NO;
        if(_sectionDraggingInfo.normScroll < -kThreshold)
        {
            NSInteger index = _selectedSection - 1;
            if(index >= 0)
            {
                [self selectSectionAtIndex:index animated:YES internal:YES];
                sectionChanged = YES;
            }
        }
        else if(_sectionDraggingInfo.normScroll > kThreshold)
        {
            NSInteger index = _selectedSection + 1;
            if(index < _sections.count)
            {
                [self selectSectionAtIndex:index animated:YES internal:YES];
                sectionChanged = YES;
            }
        }
        
        if(!sectionChanged)
        {
            [TSUtils performViewAnimationBlock:^{
                [self updateSectionsLayout];
                [self updateSectionsScrollPosition];
                [self updateEmptySpaceHolderLayout];
            } withCompletion:nil animated:YES];
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(navigationStripDidEndScroll:)])
            {
                [self.delegate navigationStripDidEndScroll:self];
            }
        }
    }
}

- (void)scrollSelectedSectionTo:(CGFloat)normOffset
{
    VerboseLog();
    
    if(_sectionsAligment == UIViewContentModeCenter)
    {
        CGFloat sectionsContainerWidth = [self sectionsContainerWidth];
        TSNavigationStripComponentInfo *selectedSectionInfo = _sections[_selectedSection];
        
        // Layout section next to selected from left side
        UIView *sectionLeftToSelected;
        CGFloat widthForSectionLeftToSelected; // minimal section width
        if(_selectedSection - 1 >= 0) // if there is section before selected
        {
            TSNavigationStripComponentInfo *sectionInfo = _sections[_selectedSection - 1];
            sectionLeftToSelected =  sectionInfo.container;
            widthForSectionLeftToSelected = sectionInfo.defaultWidth;
        }
        else // else resize _emptySpaceHolderImageView
        {
            sectionLeftToSelected = _emptySpaceHolderLeftImageView;
            widthForSectionLeftToSelected = 0;
        }
        
        UIView *sectionLeftLeftToSelected; // section before sibling
        if(_selectedSection - 2 >= 0) // if there is section before sibling to selected from left size
        {
            TSNavigationStripComponentInfo *sectionInfo = _sections[_selectedSection - 2];
            sectionLeftLeftToSelected = sectionInfo.container;
        }
        else if(_selectedSection - 1 >= 0) // else resize _emptySpaceHolderImageView
        {
            sectionLeftLeftToSelected = _emptySpaceHolderLeftImageView;
        }
        
        // Layout section next to selected from right side
        UIView *sectionRightToSelected;
        CGFloat widthForSectionRightToSelected;
        if(_selectedSection + 1 < _sections.count) // if there is section after selected
        {
            TSNavigationStripComponentInfo *sectionInfo = _sections[_selectedSection + 1];
            sectionRightToSelected = sectionInfo.container;
            widthForSectionRightToSelected = sectionInfo.defaultWidth;
        }
        else // if selected section is last then resize _emptySpaceHolderImageView
        {
            sectionRightToSelected = _emptySpaceHolderRightImageView;
            widthForSectionRightToSelected = 0;
        }
        
        UIView *sectionRightRightToSelected;
        if(_selectedSection + 2 < _sections.count) // if there is section before selected
        {
            TSNavigationStripComponentInfo *sectionInfo = _sections[_selectedSection + 2];
            sectionRightRightToSelected = sectionInfo.container;
        }
        else if(_selectedSection + 1  < _sections.count) // else resize _emptySpaceHolderImageView
        {
            sectionRightRightToSelected = _emptySpaceHolderRightImageView;
        }
        
        CGFloat originX = _sectionsScrollView.contentOffset.x + (sectionsContainerWidth - selectedSectionInfo.container.frame.size.width)/2;
        CGFloat leftSectionOffset = 0;
        CGFloat rightSectionOffset = 0;
        CGFloat length = (sectionsContainerWidth - selectedSectionInfo.container.frame.size.width)/2;
        if(normOffset < 0)
        {
            CGFloat fullLength = length + (sectionsContainerWidth - selectedSectionInfo.container.frame.size.width - widthForSectionLeftToSelected);
            CGFloat offset = fabs(fullLength * normOffset);
            if(offset > length)
            {
                originX += length;
                leftSectionOffset = offset - length;
            }
            else
            {
                originX += offset;
            }
        }
        else
        {
            CGFloat fullLength = length + (sectionsContainerWidth - selectedSectionInfo.container.frame.size.width - widthForSectionRightToSelected);
            CGFloat offset = fullLength * normOffset
            ;
            if(offset > length)
            {
                originX -= length;
                rightSectionOffset = offset - length;
            }
            else
            {
                originX -= offset;
            }
        }

        selectedSectionInfo.container.frame = CGRectMake(originX, selectedSectionInfo.container.frame.origin.y, selectedSectionInfo.container.frame.size.width, selectedSectionInfo.container.frame.size.height);
        
        CGFloat width = 0;
        if(sectionLeftLeftToSelected)
        {
            width =  MAX(widthForSectionLeftToSelected, selectedSectionInfo.container.frame.origin.x - _sectionsScrollView.contentOffset.x - leftSectionOffset);
            
            CGRect rect = sectionLeftLeftToSelected.frame;
            rect.size.width = originX - width - rect.origin.x;
            sectionLeftLeftToSelected.frame = rect;
        }
        else
        {
            width =  MAX(widthForSectionLeftToSelected, originX - _sectionsScrollView.contentOffset.x);
        }
        sectionLeftToSelected.frame = CGRectMake(originX - width, sectionLeftToSelected.frame.origin.y, width, sectionLeftToSelected.frame.size.height);
        
        // if section is on the right side and now it is dragging left then change position and maybe resize
        originX = CGRectGetMaxX(selectedSectionInfo.container.frame);
        if(sectionRightRightToSelected)
        {
            width = MAX(widthForSectionRightToSelected, _sectionsScrollView.contentOffset.x + sectionsContainerWidth - originX - rightSectionOffset);
            
            CGRect rect = sectionRightRightToSelected.frame;
            rect.size.width = CGRectGetMaxX(sectionRightRightToSelected.frame) - (originX + width);
            rect.origin.x = CGRectGetMaxX(sectionRightRightToSelected.frame) - rect.size.width;
            sectionRightRightToSelected.frame = rect;
        }
        else
        {
            width = MAX(widthForSectionRightToSelected, _sectionsScrollView.contentOffset.x + sectionsContainerWidth - originX);
        }
        sectionRightToSelected.frame = CGRectMake(originX, sectionRightToSelected.frame.origin.y, width, sectionRightToSelected.frame.size.height);
    }
}

#pragma mark - Setters & Getters

- (void)setDebugMode:(BOOL)debug
{
    _debugMode = debug;
    _centerContainerView.backgroundColor = (_debugMode ? [UIColor yellowColor] : [UIColor clearColor]);
    _sectionsScrollView.backgroundColor = (_debugMode ? [UIColor greenColor] : [UIColor clearColor]);
    _leftNavigationButton.backgroundColor = (_debugMode ? [UIColor purpleColor] : [UIColor clearColor]);
    _rightNavigationButton.backgroundColor = (_debugMode ? [UIColor orangeColor] : [UIColor clearColor]);
    _rightContainerView.backgroundColor = (_debugMode ? [UIColor blueColor] : [UIColor clearColor]);
    _leftContainerView.backgroundColor = (_debugMode ? [UIColor redColor] : [UIColor clearColor]);
}

- (void)setMaskSectionsContainerEdges:(BOOL)mask
{
    _maskSectionsContainerEdges = mask;
    [self updateSectionsViewMaskLayout];
}

- (void)setSectionsAligment:(UIViewContentMode)sectionsAligment
{
    _sectionsAligment = sectionsAligment;
    _sectionsScrollView.bounces = (_sectionsAligment == UIViewContentModeCenter);
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    VerboseLog();
    _backgroundImageView.image = backgroundImage;
    _backgroundImageView.hidden = (backgroundImage == nil);
}

- (void)setSelectionMarker:(UIView *)markerView
{
    if(_selectionMarker == markerView)
        return;
    if(_selectionMarker)
    {
        [_selectionMarker removeFromSuperview];
    }
    _selectionMarker = markerView;
    if(_selectionMarker)
    {
        [_sectionsScrollView insertSubview:_selectionMarker atIndex:0];
        [_sectionsScrollView sendSubviewToBack:_selectionMarker];
        [self updateSelectionMarkerLayout];
    }
}

- (UIImage *)backgroundImage
{
    VerboseLog();
    return _backgroundImageView.image;
}

- (void)setEmptySpaceHolderImage:(UIImage *)holderImage
{
    VerboseLog();
    _emptySpaceHolderLeftImageView.image = holderImage;
    _emptySpaceHolderLeftImageView.hidden = (holderImage == nil);
    _emptySpaceHolderRightImageView.image = holderImage;
    _emptySpaceHolderRightImageView.hidden = (holderImage == nil);
    [self updateEmptySpaceHolderLayout];
}

- (UIImage *)emptySpaceHolderImage
{
    VerboseLog();
    return _emptySpaceHolderLeftImageView.image;
}

#pragma mark - Retrieve elements size

- (CGFloat)sectionOriginalWidthAtIndex:(NSInteger)index selected:(BOOL)selected
{
    float width = (selected ? self.selectedSectionWidth :  self.sectionWidth);
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(sectionWidthAtIndex:forSelectedState:)])
    {
        width = [self.dataSource sectionWidthAtIndex:index forSelectedState:selected];
    }
    return floor(width);
}

- (CGFloat)sectionWidthAtIndex:(NSInteger)index
{
    CGFloat sectionsContainerWidth = [self sectionsContainerWidth];
    int sectionsCount = [self.dataSource numberOfSections];
    float width = self.sectionWidth;
    if(_sectionsAligment == UIViewContentModeScaleAspectFill)
    {
        width = (sectionsCount ? sectionsContainerWidth / sectionsCount : sectionsContainerWidth);
    }
    else if(_sectionsAligment == UIViewContentModeCenter && sectionsCount == 1)
    {
        width = sectionsContainerWidth;
    }
    else if(_sectionsAligment == UIViewContentModeCenter &&
           (index == _selectedSection - 1 || index == _selectedSection + 1)) //  if (central aligment) -> sibling to selected section would be most left or most right
    {
        TSNavigationStripComponentInfo *selectedSectionInfo = _sections[_selectedSection];
        CGFloat selecteSectiondWidth = selectedSectionInfo.defaultSelectedWidth;
        width = MAX(self.sectionWidth,(sectionsContainerWidth - selecteSectiondWidth)/2);
    }
    else if(0 <= index && index < _sections.count)
    {
        TSNavigationStripComponentInfo *selectedSectionInfo = _sections[_selectedSection];
        width = (index == _selectedSection ? selectedSectionInfo.defaultSelectedWidth : selectedSectionInfo.defaultWidth);
    }
    return floor(width);
}

- (CGFloat)itemOriginalWidthAtIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide selected:(BOOL)selected
{
    VerboseLog();
    float width = self.frame.size.height;
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(itemWidthAtIndex:fromLeftSide:forSelectedState:)])
    {
        width = [self.dataSource itemWidthAtIndex:index fromLeftSide:leftSide forSelectedState:selected];
    }
    return floor(width);
}

- (CGFloat)itemWidthAtIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide
{
    VerboseLog();
    float width = self.frame.size.height;
    NSArray *items = (leftSide ? _leftItems : _rightItems);
    if(0 <= index && index < items.count)
    {
        TSNavigationStripComponentInfo *selectedItemInfo = items[index];
        width = (selectedItemInfo.control.selected ? selectedItemInfo.defaultSelectedWidth : selectedItemInfo.defaultWidth);
    }
    return floor(width);
}

- (NSInteger)numberOfItemsFromLeftSide:(BOOL)leftSide
{
    VerboseLog();
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfItemsFromLeftSide:)])
    {
        return [self.dataSource numberOfItemsFromLeftSide:leftSide];
    }
    return 0;
}

- (CGFloat)sectionsContainerWidth
{
    CGFloat width = _centerContainerView.frame.size.width;
    if(!_navigationButtonsHidden)
    {
        BOOL hidden = _autohideNavigationButtons && !_leftNavigationButton.enabled;
        if(!hidden)
        {
            width -= _leftNavigationButton.frame.size.width;
        }
        
        hidden = _autohideNavigationButtons && !_rightNavigationButton.enabled;
        if(!hidden)
        {
            width -= _rightNavigationButton.frame.size.width;
        }
    }
    return width;
}

#pragma mark - Update content

- (void)reloadData
{
    VerboseLog();
    if(!self.dataSource) return;
    [self updateLeftItems];
    [self updateRightItems];
    [self updateSections];
    
    [self updateCenterContainerLayout];
    [self updateNavigationButtonsStateWithAnimation:NO];
    [self updateSectionsSelectionBeforeAnimation];
    [self updateSectionsSelectionAfterAnimation];
    [self updateSectionsLayout];
    [self updateSectionsScrollSizeOnlyIfNewSizeGreater:NO];
    [self updateSectionsScrollPosition];
    [self updateSectionsViewMaskLayout];
    [self updateEmptySpaceHolderLayout];
}

- (void)reloadSectionsData
{
    VerboseLog();
    if(!self.dataSource) return;
    [self updateSections];
    [self updateNavigationButtonsStateWithAnimation:NO];
    [self updateSectionsSelectionBeforeAnimation];
    [self updateSectionsSelectionAfterAnimation];
    [self updateSectionsLayout];
    [self updateSectionsScrollSizeOnlyIfNewSizeGreater:NO];
    [self updateSectionsScrollPosition];
    [self updateSectionsViewMaskLayout];
    [self updateEmptySpaceHolderLayout];
}

- (void)reloadItemsData
{
    VerboseLog();
    if(!self.dataSource) return;
    [self updateLeftItems];
    [self updateRightItems];
    
    [self updateCenterContainerLayout];
    [self updateNavigationButtonsStateWithAnimation:NO];
    [self updateSectionsSelectionBeforeAnimation];
    [self updateSectionsSelectionAfterAnimation];
    [self updateSectionsLayout];
    [self updateSectionsScrollSizeOnlyIfNewSizeGreater:NO];
    [self updateSectionsScrollPosition];
    [self updateSectionsViewMaskLayout];
    [self updateEmptySpaceHolderLayout];
}

- (void)setDataSource:(id<TSNavigationStripDataSource>)dataSource
{
    VerboseLog();
    _dataSource = dataSource;
    [self reloadData];
}

#pragma mark - Generate content

- (TSNavigationStripComponentInfo *)createItemForIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide
{
    VerboseLog();
    TSNavigationStripComponentInfo *itemInfo = [[TSNavigationStripComponentInfo alloc] init];
    CGRect rect = CGRectMake(0, 0, self.frame.size.height, self.frame.size.height);
    itemInfo.container = [[UIView alloc] initWithFrame:rect];
    itemInfo.container.backgroundColor = [UIColor clearColor];
    itemInfo.container.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(customItemControlForIndex:fromLeftSide:)])
    {
        itemInfo.control = [self.dataSource customItemControlForIndex:index fromLeftSide:leftSide];
    }
    else
    {
        itemInfo.control = [[UIButton alloc] initWithFrame:rect];
    }
    itemInfo.control.adjustsImageWhenDisabled = NO;
    itemInfo.control.adjustsImageWhenHighlighted = NO;
    itemInfo.control.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [itemInfo.container addSubview:itemInfo.control];
    [itemInfo.control addTarget:self action:@selector(itemButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setItemAppearance:itemInfo atIndex:index fromLeftSide:leftSide];
    itemInfo.container.frame = CGRectMake(0, 0, itemInfo.defaultWidth, self.frame.size.height);
    
    // Tag is internal reference on index; it starts from |1|; for left items it would be negative; for right items it would be positive
    itemInfo.container.tag = itemInfo.control.tag = (leftSide ? -(index + 1) : (index + 1));
    return itemInfo;
}

- (void)setItemAppearance:(TSNavigationStripComponentInfo *)itemInfo atIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide
{
    itemInfo.defaultWidth = [self itemOriginalWidthAtIndex:index fromLeftSide:leftSide selected:NO];
    itemInfo.defaultSelectedWidth = [self itemOriginalWidthAtIndex:index fromLeftSide:leftSide selected:YES];
    itemInfo.control.frame = itemInfo.container.bounds;
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(edgeInsetsForItemAtIndex:fromLeftSide:)])
    {
        UIEdgeInsets edgeInsets = [self.dataSource edgeInsetsForItemAtIndex:index fromLeftSide:leftSide];
        itemInfo.control.frame = CGRectMake(edgeInsets.left, edgeInsets.top, itemInfo.control.frame.size.width - edgeInsets.left - edgeInsets.right, itemInfo.control.frame.size.height - edgeInsets.top - edgeInsets.bottom);
    }
    UIColor *titleSelectedColor;
    UIColor *titleColor;
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(titleColorForItemAtIndex:fromLeftSide:forSelectedState:)])
    {
        titleSelectedColor = [self.dataSource titleColorForItemAtIndex:index fromLeftSide:leftSide forSelectedState:YES];
        titleColor = [self.dataSource titleColorForItemAtIndex:index fromLeftSide:leftSide forSelectedState:NO];
    }
    else
    {
        titleSelectedColor = [UIColor colorWithWhite:0.6f alpha:1];
        titleColor = [UIColor colorWithWhite:0.3f alpha:1];
        itemInfo.control.titleLabel.shadowOffset = CGSizeMake(1, 1);
        itemInfo.control.titleLabel.shadowColor = [UIColor blackColor];
    }
    [itemInfo.control setTitleColor:titleColor forState:UIControlStateNormal];
    [itemInfo.control setTitleColor:titleSelectedColor forState:UIControlStateSelected];
    
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(titleFontForItemAtIndex:fromLeftSide:forSelectedState:)])
    {
        itemInfo.defaultFont = [self.dataSource titleFontForItemAtIndex:index fromLeftSide:leftSide forSelectedState:NO];
        itemInfo.defaultSelectedFont = [self.dataSource titleFontForItemAtIndex:index fromLeftSide:leftSide forSelectedState:YES];
    }
    else
    {
        itemInfo.defaultFont = [UIFont systemFontOfSize:15.0f];
        itemInfo.defaultSelectedFont = [UIFont boldSystemFontOfSize:15.0f];
    }
    itemInfo.control.titleLabel.font = itemInfo.defaultFont;
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(backgroundColorForItemAtIndex:fromLeftSide:forSelectedState:)])
    {
        itemInfo.defaultBackgroundColor = [self.dataSource backgroundColorForItemAtIndex:index fromLeftSide:leftSide forSelectedState:NO];
        itemInfo.defaultSelectedBackgroundColor = [self.dataSource backgroundColorForItemAtIndex:index fromLeftSide:leftSide forSelectedState:YES];
    }
    else
    {
        itemInfo.defaultBackgroundColor = [UIColor clearColor];
        itemInfo.defaultSelectedBackgroundColor = [UIColor clearColor];
    }
    [itemInfo.control setBackgroundColor:itemInfo.defaultBackgroundColor];
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(backgroundImageForItemAtIndex:fromLeftSide:forSelectedState:)])
    {
        [itemInfo.control setBackgroundImage:[self.dataSource backgroundImageForItemAtIndex:index fromLeftSide:leftSide forSelectedState:NO] forState:UIControlStateNormal];
        [itemInfo.control setBackgroundImage:[self.dataSource backgroundImageForItemAtIndex:index fromLeftSide:leftSide forSelectedState:YES] forState:UIControlStateSelected];
    }
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(titleForItemAtIndex:fromLeftSide:forSelectedState:)])
    {
        [itemInfo.control setTitle:[self.dataSource titleForItemAtIndex:index fromLeftSide:leftSide forSelectedState:NO] forState:UIControlStateNormal];
        [itemInfo.control setTitle:[self.dataSource titleForItemAtIndex:index fromLeftSide:leftSide forSelectedState:YES] forState:UIControlStateSelected];
    }
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(iconForItemAtIndex:fromLeftSide:forSelectedState:)])
    {
        [itemInfo.control setImage:[self.dataSource iconForItemAtIndex:index fromLeftSide:leftSide forSelectedState:NO] forState:UIControlStateNormal];
        [itemInfo.control setImage:[self.dataSource iconForItemAtIndex:index fromLeftSide:leftSide forSelectedState:YES] forState:UIControlStateSelected];
    }
    
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(shadowColorForItemAtIndex:fromLeftSide:)])
    {
        itemInfo.control.titleLabel.shadowColor = [self.dataSource shadowColorForItemAtIndex:index fromLeftSide:leftSide ];
    }
    
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(shadowOffsetForItemAtIndex:fromLeftSide:)])
    {
        itemInfo.control.titleLabel.shadowOffset = [self.dataSource shadowOffsetForItemAtIndex:index fromLeftSide:leftSide ];
    }
}

- (void)addItemsForLeftSide:(BOOL)leftSide
{
    VerboseLog();
    UIView *parentContainer = (leftSide ? _leftContainerView : _rightContainerView);
    NSMutableArray *items = (leftSide ? _leftItems : _rightItems);
    
    [items enumerateObjectsUsingBlock:^(TSNavigationStripComponentInfo *obj, NSUInteger idx, BOOL *stop) {
        [obj.container removeFromSuperview];
    }];
    [items removeAllObjects];
    
    int itemsCount = [self numberOfItemsFromLeftSide:leftSide];
    float x = 0;
    for(int i = 0; i < itemsCount; ++i)
    {
        TSNavigationStripComponentInfo *itemInfo  = [self createItemForIndex:i fromLeftSide:leftSide];
        itemInfo.container.frame = CGRectMake(x, 0, itemInfo.container.frame.size.width, self.frame.size.height);
        [parentContainer addSubview:itemInfo.container];
        [items addObject:itemInfo];
        x += itemInfo.container.frame.size.width;
    }
    
    if(leftSide)
    {
        [self updateLeftContainerLayoutWithNewWidth:x];
    }
    else
    {
        [self updateRightContainerLayoutWithNewWidth:x];
    }
}

- (void)updateLeftItems
{
    VerboseLog();
    [self addItemsForLeftSide:YES];
}

- (void)updateRightItems
{
    VerboseLog();
    [self addItemsForLeftSide:NO];
}

#pragma mark - Add Sections

- (TSNavigationStripComponentInfo *)createSectionForIndex:(NSInteger)index
{
    VerboseLog();
    TSNavigationStripComponentInfo *itemInfo = [[TSNavigationStripComponentInfo alloc] init];
    CGRect rect = CGRectMake(0, 0, self.frame.size.height, self.frame.size.height);
    itemInfo.container = [[UIView alloc] initWithFrame:rect];
    itemInfo.container.backgroundColor = [UIColor clearColor];
    itemInfo.container.tag = index;
    itemInfo.container.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    itemInfo.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionTapGestureRecognizer:)];
    [itemInfo.container addGestureRecognizer:itemInfo.tapGesture];
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(customSectionControlForIndex:)])
    {
        itemInfo.control = [self.dataSource customSectionControlForIndex:index];
    }
    else
    {
        itemInfo.control = [[UIButton alloc] initWithFrame:rect];
    }
    itemInfo.control.adjustsImageWhenDisabled = NO;
    itemInfo.control.adjustsImageWhenHighlighted = NO;
    itemInfo.control.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [itemInfo.container addSubview:itemInfo.control];
    
    [self setSectionAppearance:itemInfo atIndex:index];
    itemInfo.container.frame = CGRectMake(0, 0, itemInfo.defaultWidth, self.frame.size.height);
    
    [itemInfo.control addTarget:self action:@selector(sectionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    itemInfo.container.tag = itemInfo.control.tag = index;
    itemInfo.control.selected = (index == self.selectedSection);
    itemInfo.control.userInteractionEnabled = !itemInfo.control.selected;
    itemInfo.tapGesture.enabled = itemInfo.control.selected;
    
    return itemInfo;
}

- (void)setSectionAppearance:(TSNavigationStripComponentInfo *)itemInfo atIndex:(NSInteger)index
{
    itemInfo.defaultWidth = [self sectionOriginalWidthAtIndex:index selected:NO];
    itemInfo.defaultSelectedWidth = [self sectionOriginalWidthAtIndex:index selected:YES];
    itemInfo.container.backgroundColor = [UIColor clearColor];
    itemInfo.control.frame = itemInfo.container.bounds;
    
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(edgeInsetsForSectionAtIndex:)])
    {
        UIEdgeInsets edgeInsets = [self.dataSource edgeInsetsForSectionAtIndex:index];
        itemInfo.control.frame = CGRectMake(edgeInsets.left, edgeInsets.top, itemInfo.control.frame.size.width - edgeInsets.left - edgeInsets.right, itemInfo.control.frame.size.height - edgeInsets.top - edgeInsets.bottom);
    }
    UIColor *titleSelectedColor = nil;
    UIColor *titleColor = nil;
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(titleColorForSectionAtIndex:forSelectedState:)])
    {
        titleSelectedColor = [self.dataSource titleColorForSectionAtIndex:index forSelectedState:YES];
        titleColor = [self.dataSource titleColorForSectionAtIndex:index forSelectedState:NO];
    }
    else
    {
        titleSelectedColor = [UIColor colorWithWhite:0.6f alpha:1];
        titleColor = [UIColor colorWithWhite:0.3f alpha:1];
        itemInfo.control.titleLabel.shadowOffset = CGSizeMake(1, 1);
        itemInfo.control.titleLabel.shadowColor = [UIColor blackColor];
    }
    [itemInfo.control setTitleColor:titleColor forState:UIControlStateNormal];
    [itemInfo.control setTitleColor:titleSelectedColor forState:UIControlStateSelected];
    
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(backgroundImageForSectionAtIndex:forSelectedState:)])
    {
        [itemInfo.control setBackgroundImage:[self.dataSource backgroundImageForSectionAtIndex:index forSelectedState:NO] forState:UIControlStateNormal];
        [itemInfo.control setBackgroundImage:[self.dataSource backgroundImageForSectionAtIndex:index forSelectedState:YES] forState:UIControlStateSelected];
    }
    
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(iconForSectionAtIndex:forSelectedState:)])
    {
        [itemInfo.control setImage:[self.dataSource iconForSectionAtIndex:index forSelectedState:NO] forState:UIControlStateNormal];
        [itemInfo.control setImage:[self.dataSource iconForSectionAtIndex:index forSelectedState:YES] forState:UIControlStateSelected];
    }
    
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(titleForSectionAtIndex:forSelectedState:)])
    {
        [itemInfo.control setTitle:[self.dataSource titleForSectionAtIndex:index forSelectedState:NO] forState:UIControlStateNormal];
        [itemInfo.control setTitle:[self.dataSource titleForSectionAtIndex:index forSelectedState:YES] forState:UIControlStateSelected];
    }
    
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(shadowColorForSectionAtIndex:)])
    {
        itemInfo.control.titleLabel.shadowColor = [self.dataSource shadowColorForSectionAtIndex:index];
    }
    
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(shadowOffsetForSectionAtIndex:)])
    {
        itemInfo.control.titleLabel.shadowOffset = [self.dataSource shadowOffsetForSectionAtIndex:index];
    }
    
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(titleFontForSectionAtIndex:forSelectedState:)])
    {
        itemInfo.defaultFont = [self.dataSource titleFontForSectionAtIndex:index forSelectedState:NO];
        itemInfo.defaultSelectedFont = [self.dataSource titleFontForSectionAtIndex:index forSelectedState:YES];
    }
    else
    {
        itemInfo.defaultSelectedFont = [UIFont boldSystemFontOfSize:15.0f];
        itemInfo.defaultFont = [UIFont systemFontOfSize:15.0f];
    }
    itemInfo.control.titleLabel.font = (index == _selectedSection ? itemInfo.defaultSelectedFont : itemInfo.defaultFont);
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(backgroundColorForSectionAtIndex:forSelectedState:)])
    {
        itemInfo.defaultBackgroundColor = [self.dataSource backgroundColorForSectionAtIndex:index forSelectedState:NO];
        itemInfo.defaultSelectedBackgroundColor = [self.dataSource backgroundColorForSectionAtIndex:index forSelectedState:YES];
    }
    else
    {
        itemInfo.defaultBackgroundColor = [UIColor clearColor];
        itemInfo.defaultSelectedBackgroundColor = [UIColor clearColor];
    }
    [itemInfo.control setBackgroundColor:(index == self.selectedSection ? itemInfo.defaultSelectedBackgroundColor : itemInfo.defaultBackgroundColor)];
}

- (void)updateSections
{
    VerboseLog();
    int sectionsCount = [self.dataSource numberOfSections];
    
    if(_selectedSection >= sectionsCount)
    {
        _selectedSection = 0;
    }

    [_sections enumerateObjectsUsingBlock:^(TSNavigationStripComponentInfo *obj, NSUInteger idx, BOOL *stop) {
        [obj.container removeFromSuperview];
    }];
    [_sections removeAllObjects];
    
    for (int i = 0; i < sectionsCount; ++i)
    {
        TSNavigationStripComponentInfo *sectionInfo = [self createSectionForIndex:i];
        [_sectionsScrollView addSubview:sectionInfo.container];
        [_sections addObject:sectionInfo];
    }
}

#pragma mark - Update layout of UI elements

- (void)updateSectionsViewMaskLayout
{
    if(_maskSectionsContainerEdges)
    {
        CGFloat sectionsContainerWidth = [self sectionsContainerWidth];
        if(_sectionsScrollView.contentSize.width > sectionsContainerWidth ||
           _sectionsAligment == UIViewContentModeCenter)
        {
            const NSInteger kMaskLeft = 1;
            const NSInteger kMaskRight = 2;
            const NSInteger kMaskCenter = 3;
            NSInteger maskType = 0;
            if((_sectionsScrollView.contentOffset.x > 0 &&
                _sectionsScrollView.contentOffset.x + sectionsContainerWidth <  _sectionsScrollView.contentSize.width) ||
                _sectionsAligment == UIViewContentModeCenter)
            {
                maskType = kMaskCenter;
            }
            else if(_sectionsScrollView.contentOffset.x > 0)
            {
                maskType = kMaskLeft;
            }
            else
            {
                maskType = kMaskRight;
            }
            
            CAGradientLayer *maskLayer = nil;
            if(maskType != _maskSectionsContainerEdgesType || !_sectionsContainerView.layer.mask)
            {
                _maskSectionsContainerEdgesType = maskType;
                maskLayer = [CAGradientLayer layer];
                maskLayer.startPoint = CGPointZero;
                maskLayer.endPoint = CGPointMake(1, 0);
            
                switch (maskType)
                {
                    case kMaskLeft:
                        maskLayer.colors = @[(id)[UIColor colorWithWhite:0 alpha:0.25f].CGColor,
                                             (id)[UIColor blackColor].CGColor,
                                             (id)[UIColor blackColor].CGColor];
                        maskLayer.locations = @[[NSNumber numberWithFloat:0],
                                                [NSNumber numberWithFloat:0.2f],
                                                [NSNumber numberWithFloat:1]];
                        break;
                    case kMaskCenter:
                        maskLayer.colors = @[(id)[UIColor colorWithWhite:0 alpha:0.25f].CGColor,
                                             (id)[UIColor blackColor].CGColor,
                                             (id)[UIColor blackColor].CGColor,
                                             (id)[UIColor colorWithWhite:0 alpha:0.25f].CGColor];
                        maskLayer.locations = @[[NSNumber numberWithFloat:0],
                                                [NSNumber numberWithFloat:0.2f],
                                                [NSNumber numberWithFloat:0.8f],
                                                [NSNumber numberWithFloat:1]];
                        break;
                    case kMaskRight:
                        maskLayer.colors = @[(id)[UIColor blackColor].CGColor,
                                             (id)[UIColor blackColor].CGColor,
                                             (id)[UIColor colorWithWhite:0 alpha:0.25f].CGColor];
                        maskLayer.locations = @[[NSNumber numberWithFloat:0],
                                                [NSNumber numberWithFloat:0.8f],
                                                [NSNumber numberWithFloat:1]];
                        break;
                    default:
                        break;
                }
                _sectionsContainerView.layer.mask = maskLayer;
            }
            else
            {
                maskLayer = (CAGradientLayer *)_sectionsContainerView.layer.mask;
            }
            maskLayer.frame = CGRectMake(0, 0, sectionsContainerWidth, _sectionsScrollView.frame.size.height);
            
        }
        else
        {
            _sectionsContainerView.layer.mask = nil;
        }
    }
    else
    {
        _sectionsContainerView.layer.mask = nil;
    }
}


- (void)updateEmptySpaceHolderLayout
{
    CGFloat sectionsContainerWidth = [self sectionsContainerWidth];
    if(_sections.count == 0)
    {
        _emptySpaceHolderLeftImageView.frame = CGRectMake(0, 0, sectionsContainerWidth, _emptySpaceHolderLeftImageView.frame.size.height);
        _emptySpaceHolderRightImageView.frame = CGRectMake(sectionsContainerWidth, 0, 0, _emptySpaceHolderRightImageView.frame.size.height);
    }
    else if(_sectionsAligment == UIViewContentModeCenter)
    {
        // if first section selected, space holder image should be in the beginning
        TSNavigationStripComponentInfo *firstSectionInfo = _sections[0];
        _emptySpaceHolderLeftImageView.frame = CGRectMake(0, 0, firstSectionInfo.container.frame.origin.x, _emptySpaceHolderLeftImageView.frame.size.height);
        
        // if last section selected, space holder image should be in the end
        TSNavigationStripComponentInfo *lastSectionInfo = [_sections lastObject];
        CGFloat originX = CGRectGetMaxX(lastSectionInfo.container.frame);
        _emptySpaceHolderRightImageView.frame = CGRectMake(originX, 0, _sectionsScrollView.contentSize.width - originX, _emptySpaceHolderRightImageView.frame.size.height);
    }
    else if(_sectionsAligment == UIViewContentModeRight)
    {
        TSNavigationStripComponentInfo *sectionInfo = _sections[0];
        _emptySpaceHolderLeftImageView.frame = CGRectMake(0, 0, sectionInfo.container.frame.origin.x, _emptySpaceHolderLeftImageView.frame.size.height);
        _emptySpaceHolderRightImageView.frame = CGRectMake(_sectionsScrollView.contentSize.width, 0, 0, _emptySpaceHolderRightImageView.frame.size.height);
    }
    else if(_sectionsAligment == UIViewContentModeLeft)
    {
        TSNavigationStripComponentInfo *sectionInfo = [_sections lastObject];
        CGFloat originX = CGRectGetMaxX(sectionInfo.container.frame);
        _emptySpaceHolderLeftImageView.frame = CGRectMake(0, 0, 0, _emptySpaceHolderLeftImageView.frame.size.height);
        _emptySpaceHolderRightImageView.frame = CGRectMake(originX, 0, _sectionsScrollView.contentSize.width - originX, _emptySpaceHolderRightImageView.frame.size.height);
    }
    else
    {
        _emptySpaceHolderLeftImageView.frame = CGRectMake(0, 0, 0, _emptySpaceHolderLeftImageView.frame.size.height);
        _emptySpaceHolderRightImageView.frame = CGRectMake(_sectionsScrollView.contentSize.width, 0, 0, _emptySpaceHolderRightImageView.frame.size.height);
    }
}

- (void)updateSelectionMarkerLayout
{
    if(_selectionMarker)
    {
        if(_sections.count)
        {
            _selectionMarker.hidden = NO;
            TSNavigationStripComponentInfo *info = _sections[_selectedSection];
            _selectionMarker.frame = info.container.frame;
        }
        else
        {
            _selectionMarker.hidden = YES;
        }
    }
}

- (void)updateCenterContainerLayout
{
    VerboseLog();
    CGFloat width = self.frame.size.width - _leftContainerView.frame.size.width - _rightContainerView.frame.size.width;
    _centerContainerView.frame = CGRectMake(_leftContainerView.frame.size.width, 0, width, self.frame.size.height);
}

- (void)updateLeftContainerLayoutWithNewWidth:(CGFloat)width
{
    VerboseLog();
    _leftContainerView.frame = CGRectMake(0, 0, width, self.frame.size.height);
}

- (void)updateRightContainerLayoutWithNewWidth:(CGFloat)width 
{
    VerboseLog();
    _rightContainerView.frame = CGRectMake(self.frame.size.width - width, 0, width, self.frame.size.height);
}

- (void)updateContainerLayoutAfterItemSelection:(NSInteger)itemIndex fromLeftSide:(BOOL)leftSide animated:(BOOL)animated
{
    VerboseLog();
    NSArray *items = (leftSide ? _leftItems : _rightItems);
    if(0 <= itemIndex && itemIndex < items.count)
    {
        TSNavigationStripComponentInfo *selectedItemInfo = items[itemIndex];
        UIView *rootContainer = (leftSide ? _leftContainerView : _rightContainerView);
        CGFloat oldWidth = selectedItemInfo.container.frame.size.width;
        CGFloat newWidth = [self itemWidthAtIndex:itemIndex fromLeftSide:leftSide];
        CGFloat delta = newWidth - oldWidth;
        
        [TSUtils performViewAnimationBlock:^{
            selectedItemInfo.container.frame = CGRectMake(selectedItemInfo.container.frame.origin.x, selectedItemInfo.container.frame.origin.y, newWidth, selectedItemInfo.container.frame.size.height);
            for(int i = itemIndex + 1; i < items.count; ++i)
            {
                TSNavigationStripComponentInfo *itemInfo = items[i];
                itemInfo.container.frame = CGRectMake(itemInfo.container.frame.origin.x + delta, itemInfo.container.frame.origin.y, itemInfo.container.frame.size.width, itemInfo.container.frame.size.height);
            }
            CGFloat width = rootContainer.frame.size.width + delta;
            if(leftSide)
            {
                [self updateLeftContainerLayoutWithNewWidth:width];
            }
            else
            {
                [self updateRightContainerLayoutWithNewWidth:width];
            }
            [self updateCenterContainerLayout];
        } withCompletion:^{
            [self updateSectionsViewMaskLayout];
        } animated:animated];
    }
}

- (void)updateNavigationButtonsStateWithAnimation:(BOOL)animated
{
    VerboseLog();
    // update left side navigation button appearance
    BOOL enabled = _selectedSection > 0;
    BOOL hidden = _navigationButtonsHidden || (_autohideNavigationButtons && !enabled);

    _leftNavigationButton.enabled = enabled;
    CGRect rectLeftBtn = _leftNavigationButton.frame;
    rectLeftBtn.origin.x = (hidden ? -rectLeftBtn.size.width : 0);
            
    if(enabled)
        _leftNavigationButton.hidden = NO;
    
    [TSUtils performViewAnimationBlock:^{
        _leftNavigationButton.frame = rectLeftBtn;  
        _leftNavigationButton.alpha = (hidden ? 0 : 1);
    } withCompletion:^{
         _leftNavigationButton.hidden = hidden;
    } animated:animated];
    
    // update right side navigation button appearance
    int sectionsCount = [_dataSource numberOfSections];
    enabled = _selectedSection < sectionsCount - 1;
    hidden = _navigationButtonsHidden || (_autohideNavigationButtons && !enabled);

    _rightNavigationButton.enabled = enabled;
    CGRect rectRightBtn = _rightNavigationButton.frame;
    rectRightBtn.origin.x = (hidden ? _centerContainerView.frame.size.width : _centerContainerView.frame.size.width - rectRightBtn.size.width);
    
    if(enabled)
        _rightNavigationButton.hidden = NO;
    
    [TSUtils performViewAnimationBlock:^{
        _rightNavigationButton.frame = rectRightBtn;
        _rightNavigationButton.alpha = (hidden ? 0 : 1);
    } withCompletion:^{
        _rightNavigationButton.hidden = hidden;
    } animated:animated];
    
    // update center scrollview size
    CGFloat leftX = CGRectGetMaxX(rectLeftBtn);
    CGFloat rightX = CGRectGetMinX(rectRightBtn);
    CGRect rectSectionsContainer = CGRectMake(leftX, 0, rightX - leftX, _sectionsContainerView.frame.size.height);
    [TSUtils performViewAnimationBlock:^{
        _sectionsContainerView.frame = rectSectionsContainer;
    } withCompletion:nil animated:animated];    
}

- (void)updateSectionsLayout
{
    VerboseLog();
    if(_sections.count)
    {
        CGFloat sectionsContainerWidth = [self sectionsContainerWidth];
        // update sections layout
        CGFloat originX = 0;
        // update sections width
        if(_sectionsAligment == UIViewContentModeRight)
        {
            for (int i = _sections.count - 1; i >= 0; i--)
            {
                TSNavigationStripComponentInfo *sectionInfo = [_sections objectAtIndex:i];
                CGRect rect = sectionInfo.container.frame;
                rect.size.width = [self sectionWidthAtIndex:i];
                rect.origin.x = _sectionsScrollView.contentSize.width - originX - rect.size.width;
                sectionInfo.container.frame = rect;
                originX += rect.size.width;
            }
        }
        else
        {
            // if central aligment and first element selected then add offset in the beginning and fill it with EmptySpaceHolder image
            if(_sectionsAligment == UIViewContentModeCenter && _selectedSection == 0)
            {
                CGFloat width = [self sectionWidthAtIndex:_selectedSection];
                originX = (sectionsContainerWidth - width)/2;
            }
            
            for (int i = 0; i < _sections.count; ++i)
            {
                TSNavigationStripComponentInfo *sectionInfo = [_sections objectAtIndex:i];
                CGRect rect = sectionInfo.container.frame;
                rect.origin.x = originX;
                rect.size.width = [self sectionWidthAtIndex:i];
                sectionInfo.container.frame = rect;
                originX += rect.size.width;
            }
        }
    }
    
    [self updateSelectionMarkerLayout];
}

- (void)updateSectionsScrollSizeOnlyIfNewSizeGreater:(BOOL)onlyIfGreater
{
    VerboseLog();
    // update sections layout
    CGFloat originX = 0;
    CGFloat sectionsContainerWidth = [self sectionsContainerWidth];
    // if central aligment and first element selected then add offset in the beginning
    if(_sectionsAligment == UIViewContentModeCenter && _selectedSection == 0 && _sections.count)
    {
        CGFloat width = [self sectionWidthAtIndex:_selectedSection];
        originX = (sectionsContainerWidth - width)/2;
    }
    
    // update sections width
    for (int i = 0; i < _sections.count; ++i)
    {
        CGFloat width = [self sectionWidthAtIndex:i];
        originX += width;
    }
    
    if(_sectionsAligment == UIViewContentModeCenter && _selectedSection == _sections.count - 1 && _sections.count)
    {
        CGFloat width = [self sectionWidthAtIndex:_selectedSection];
        originX += (sectionsContainerWidth - width)/2;
    }
    
    // ContentWidth shouldn't be less then container width.
    // Tweak: in case of UIViewContentModeCenter aligment add +1 unit to sectionsContainerWidth to allow scrolling.
    CGFloat contentWidth = MAX(sectionsContainerWidth + (_sectionsAligment == UIViewContentModeCenter ? 1 : 0),originX);
    // change content scrollView size
    if(!onlyIfGreater || contentWidth > _sectionsScrollView.contentSize.width)
    {
        _sectionsScrollView.contentSize = CGSizeMake(contentWidth, _sectionsScrollView.contentSize.height);
    }
}

- (void)updateSectionsScrollPosition
{
    VerboseLog();
    if(_sections.count)
    {
        CGFloat sectionsContainerWidth = [self sectionsContainerWidth];
        CGFloat newOriginX = _sectionsScrollView.contentOffset.x;
        newOriginX = MAX(0,newOriginX);
        newOriginX = MIN(newOriginX,_sectionsScrollView.contentSize.width - sectionsContainerWidth);
        
        TSNavigationStripComponentInfo *sectionInfo = [_sections objectAtIndex:_selectedSection];
        CGRect rect = sectionInfo.container.frame;
        // calculate new scrollPosition
        if(_sectionsAligment == UIViewContentModeLeft || _sectionsAligment == UIViewContentModeRight)
        {
            if(rect.origin.x < newOriginX)
            {
                newOriginX = rect.origin.x;
            }
            else if(rect.origin.x + rect.size.width > newOriginX + sectionsContainerWidth)
            {
                newOriginX = rect.origin.x + rect.size.width - sectionsContainerWidth;
            }
        }
        else if(_sectionsAligment == UIViewContentModeCenter)
        {
            newOriginX = MAX(0,rect.origin.x - (sectionsContainerWidth - rect.size.width)/2);
        }
        
        _sectionsScrollView.contentOffset = CGPointMake(newOriginX, 0);
    }
    else
    {
        _sectionsScrollView.contentOffset = CGPointZero;
    }
}

- (void)updateSectionsSelectionBeforeAnimation
{
    VerboseLog();
    // Check selection
    for (int i = 0; i < _sections.count; ++i)
    {
        TSNavigationStripComponentInfo *sectionInfo = _sections[i];
        sectionInfo.container.tag = sectionInfo.control.tag = i;
        sectionInfo.control.selected = (i == _selectedSection);
        sectionInfo.tapGesture.enabled = sectionInfo.control.selected;
        sectionInfo.control.userInteractionEnabled = !sectionInfo.control.selected;
        sectionInfo.control.backgroundColor = (sectionInfo.control.selected ? sectionInfo.defaultSelectedBackgroundColor : sectionInfo.defaultBackgroundColor);
        sectionInfo.control.titleLabel.font = (sectionInfo.control.selected ? sectionInfo.defaultSelectedFont : sectionInfo.defaultFont);
        if(self.sectionsAligment == UIViewContentModeCenter && i < _selectedSection) // change aligment to left
        {
            sectionInfo.control.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            CGFloat leftOffset = sectionInfo.control.frame.origin.x;
            [sectionInfo.control setContentEdgeInsets:UIEdgeInsetsMake(0, 8 + (leftOffset < 0 ? -leftOffset : 0), 0, 0)];
            [sectionInfo.control setTitleEdgeInsets:UIEdgeInsetsMake(0, 4, 0, 0)];
            [sectionInfo.control setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        }
        else if(self.sectionsAligment == UIViewContentModeCenter && i > _selectedSection) // change aligment to right
        {
            sectionInfo.control.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            CGFloat rightOffset = sectionInfo.control.frame.origin.x + sectionInfo.control.frame.size.width - sectionInfo.container.frame.size.width;
            [sectionInfo.control setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 8 + (rightOffset > 0 ? rightOffset : 0))];
            [sectionInfo.control setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            [sectionInfo.control setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 4)];
        }
    }
    
    for(int i = 0; i < _sections.count; ++i)
    {
        int j = _selectedSection + i;
        if(0 <= j && j < _sections.count)
        {
            TSNavigationStripComponentInfo *info = _sections[j];
            [_sectionsScrollView sendSubviewToBack:info.container];
        }
        j = _selectedSection - i;
        if(0 <= j && j < _sections.count)
        {
            TSNavigationStripComponentInfo *info = _sections[j];
            [_sectionsScrollView sendSubviewToBack:info.container];
        }
    }
    
    // Send back utility subviews
    [_sectionsScrollView sendSubviewToBack:_emptySpaceHolderLeftImageView];
    [_sectionsScrollView sendSubviewToBack:_emptySpaceHolderLeftImageView];
    if(_selectionMarker)
    {
        [_sectionsScrollView sendSubviewToBack:_selectionMarker];
    }
}

- (void)updateSectionsSelectionAfterAnimation
{
    VerboseLog();
    // Check selection
    for (int i = 0; i < _sections.count; ++i)
    {
        TSNavigationStripComponentInfo *sectionInfo = _sections[i];
        if(!(self.sectionsAligment == UIViewContentModeCenter && i < _selectedSection) &&
           !(self.sectionsAligment == UIViewContentModeCenter && i > _selectedSection))
        {
            sectionInfo.control.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            [sectionInfo.control setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            [sectionInfo.control setTitleEdgeInsets:UIEdgeInsetsMake(0, 4, 0, 0)];
            [sectionInfo.control setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        }
    }
}

#pragma mark - Actions

- (void)sideButtonPressed:(UIButton *)sender
{
    VerboseLog();
    if(sender.tag == LEFT_SIDE_BUTTON_TAG)
    {
        [self selectSectionAtIndex:_selectedSection - 1 animated:YES internal:YES];
    }
    else
    {
        [self selectSectionAtIndex:_selectedSection + 1 animated:YES internal:YES];
    }
}

- (void)sectionButtonPressed:(UIButton *)sender
{
    VerboseLog();
    [self selectSectionAtIndex:sender.tag animated:YES internal:YES];
}

- (void)itemButtonPressed:(UIButton *)sender
{
    VerboseLog();
    NSInteger index = abs(sender.tag) - 1;
    BOOL leftSide = (sender.tag < 0);
    if(sender.selected)
    {
        [self deselectItemAtIndex:index fromLeftSide:leftSide];
    }
    else
    {
        [self selectItemAtIndex:index fromLeftSide:leftSide];
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(navigationStrip:itemAtIndex:fromLeftSide:didChangeState:)])
    {
        [self.delegate navigationStrip:self itemAtIndex:index fromLeftSide:leftSide didChangeState:sender.selected];
    }
}

- (void)sectionTapGestureRecognizer:(UITapGestureRecognizer *)recognizer
{
    int sectionIndex = recognizer.view.tag;
    if(sectionIndex == _selectedSection)
    {
        if(self.delegate && [self.delegate respondsToSelector:@selector(navigationStripDidRecognizeTapOnSelectedSection:)])
        {
            [self.delegate navigationStripDidRecognizeTapOnSelectedSection:self];
        }
    }
}

#pragma mark - Selection changed

- (void)selectSectionAtIndex:(NSInteger)index animated:(BOOL)animated internal:(BOOL)internal
{
    VerboseLog();
    int sectionsCount = [_dataSource numberOfSections];
    if( 0 <= index && index < sectionsCount)
    {
        if(internal && self.delegate && [self.delegate respondsToSelector:@selector(navigationStrip:willSelectSectionAtIndex:animated:)])
        {
            [self.delegate navigationStrip:self willSelectSectionAtIndex:index animated:animated];
        }
        
        _selectedSection = index;
        CGFloat scrollContainerWidthBefore = [self sectionsContainerWidth];
        [self updateSectionsSelectionBeforeAnimation];
        [self updateNavigationButtonsStateWithAnimation:animated];
        CGFloat scrollContainerWidthAfter = [self sectionsContainerWidth];
        
        [self updateSectionsScrollSizeOnlyIfNewSizeGreater:YES];
        
        [TSUtils performViewAnimationBlock:^{
            [self updateSectionsLayout];
            [self updateEmptySpaceHolderLayout];
            [self updateSectionsScrollPosition];
            [self updateSectionsSelectionAfterAnimation];
        } withCompletion:^{
            [self updateSectionsScrollSizeOnlyIfNewSizeGreater:NO];
            [self updateEmptySpaceHolderLayout];
            if(scrollContainerWidthBefore >= scrollContainerWidthAfter)
            {
                [self updateSectionsViewMaskLayout];
            }
            if(internal && self.delegate && [self.delegate respondsToSelector:@selector(navigationStrip:didSelectSectionAtIndex:)])
            {
                [self.delegate navigationStrip:self didSelectSectionAtIndex:_selectedSection];
            }
        } animated:animated];
       
        if(scrollContainerWidthBefore < scrollContainerWidthAfter)
        {
           [self updateSectionsViewMaskLayout];
        }
    }
}

#pragma mark - Public API

- (void)selectItemAtIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide
{
    VerboseLog();
    NSArray *items = (leftSide ? _leftItems : _rightItems);
    if(0 <= index && index < items.count)
    {
        TSNavigationStripComponentInfo *itemInfo = items[index];
        itemInfo.control.selected = YES;
        itemInfo.control.backgroundColor = itemInfo.defaultSelectedBackgroundColor;
        itemInfo.control.titleLabel.font = itemInfo.defaultSelectedFont;
        [self updateContainerLayoutAfterItemSelection:index fromLeftSide:leftSide animated:YES];
    }
}

- (void)deselectItemAtIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide
{
    VerboseLog();
    NSArray *items = (leftSide ? _leftItems : _rightItems);
    if(0 <= index && index < items.count)
    {
        TSNavigationStripComponentInfo *itemInfo = items[index];
        itemInfo.control.selected = NO;
        itemInfo.control.backgroundColor = itemInfo.defaultBackgroundColor;
        itemInfo.control.titleLabel.font = itemInfo.defaultFont;
        [self updateContainerLayoutAfterItemSelection:index fromLeftSide:leftSide animated:YES];
    }
}

- (BOOL)isItemSelectedAtIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide
{
    VerboseLog();
    NSArray *items = (leftSide ? _leftItems : _rightItems);
    if(0 <= index && index < items.count)
    {
        TSNavigationStripComponentInfo *itemInfo = items[index];
        return itemInfo.control.selected;
    }
    return NO;
}

- (void)selectSectionAtIndex:(NSInteger)index animated:(BOOL)animated
{
    VerboseLog();
    [self selectSectionAtIndex:index animated:animated internal:NO];
}

#pragma mark - Modify content

- (void)insertSectionAtIndex:(NSInteger)index animated:(BOOL)animated
{
    VerboseLog();
    TSNavigationStripComponentInfo *sectionInfo = [self createSectionForIndex:index];
    if(sectionInfo)
    {
        [_sectionsScrollView insertSubview:sectionInfo.container aboveSubview:_emptySpaceHolderRightImageView];
        NSInteger realIndex = MIN(MAX(0, index), _sections.count);
        [_sections insertObject:sectionInfo atIndex:realIndex];
        
        NSAssert([self.dataSource numberOfSections] == _sections.count, @"Number of sections in NavigationStrip should be equal to the number of entities in DataSource");
        
        // Make sure that selection remain on the old item
        if(_selectedSection >= index)
        {
            _selectedSection = MIN(_sections.count - 1, _selectedSection + 1);
        }
        
        CGFloat sectionsContainerWidthBefore = [self sectionsContainerWidth];
        [self updateSectionsSelectionBeforeAnimation];
        [self updateNavigationButtonsStateWithAnimation:animated];
        
        CGFloat sectionsContainerWidthAfter = [self sectionsContainerWidth];
        
        // correct start positions to ensure smooth insert animation
        if(_sections.count > 1)
        {
            int idx;
            if(_sectionsAligment == UIViewContentModeLeft ||
              (_sectionsAligment == UIViewContentModeCenter && index > _selectedSection))
            {
                idx = (realIndex - 1 < 0 ? realIndex + 1 : realIndex - 1);
            }
            else
            {
                idx = (realIndex + 1 < _sections.count ? realIndex + 1 : realIndex - 1);
            }
            CGFloat x = 0;
            TSNavigationStripComponentInfo *sInfo = _sections[idx];
            x = sInfo.container.frame.origin.x;
            sectionInfo.container.frame = CGRectMake(x, 0, sectionInfo.container.frame.size.width, sectionInfo.container.frame.size.height);
        }
        
        [self updateSectionsScrollSizeOnlyIfNewSizeGreater:YES];
        
        sectionInfo.container.alpha = 0;
        [TSUtils performViewAnimationBlock:^{
            sectionInfo.container.alpha = 1;
            [self updateSectionsLayout];
            [self updateEmptySpaceHolderLayout];
            [self updateSectionsScrollPosition];
            [self updateSectionsSelectionAfterAnimation];
        } withCompletion:^{
            if(sectionsContainerWidthBefore >= sectionsContainerWidthAfter)
            {
                [self updateSectionsViewMaskLayout];
            }
            [self updateSectionsScrollSizeOnlyIfNewSizeGreater:NO];
            [self updateEmptySpaceHolderLayout];
        } animated:animated && _sections.count > 1];
        
        if(sectionsContainerWidthBefore < sectionsContainerWidthAfter)
        {
            [self updateSectionsViewMaskLayout];
        }
    }
}

- (void)removeSectionAtIndex:(NSInteger)index animated:(BOOL)animated
{
    VerboseLog();
    if(0 <= index && index < _sections.count)
    {
        TSNavigationStripComponentInfo *sectionInfo = _sections[index];
        [sectionInfo.container removeFromSuperview];
        [_sections removeObjectAtIndex:index];
        
        NSAssert([self.dataSource numberOfSections] == _sections.count, @"Number of sections in NavigationStrip should be equal to the number of entities in DataSource");
        
        // Make sure that selection remain on the old item
        if(_selectedSection >= index)
        {
            _selectedSection = MAX(0, _selectedSection - 1);
        }
    
        CGFloat sectionsContainerWidthBefore = [self sectionsContainerWidth];
        [self updateSectionsSelectionBeforeAnimation];
        [self updateNavigationButtonsStateWithAnimation:animated];
        [self updateSectionsScrollSizeOnlyIfNewSizeGreater:YES];
        
        CGFloat sectionsContainerWidthAfter = [self sectionsContainerWidth];
        
        [TSUtils performViewAnimationBlock:^{
            [self updateSectionsLayout];
            [self updateEmptySpaceHolderLayout];
            [self updateSectionsScrollPosition];
            [self updateSectionsSelectionAfterAnimation];
        } withCompletion:^{
            if(sectionsContainerWidthBefore >= sectionsContainerWidthAfter)
            {
                [self updateSectionsViewMaskLayout];
            }
            [self updateSectionsScrollSizeOnlyIfNewSizeGreater:NO];
            [self updateEmptySpaceHolderLayout];
        } animated:animated];
        
        if(sectionsContainerWidthBefore < sectionsContainerWidthAfter)
        {
            [self updateSectionsViewMaskLayout];
        }
    }
}

- (void)insertItemAtIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide animated:(BOOL)animated
{
    VerboseLog();
    UIView *parentContainer = (leftSide ? _leftContainerView : _rightContainerView);
    NSMutableArray *items = (leftSide ? _leftItems : _rightItems);
    TSNavigationStripComponentInfo *itemInfo = [self createItemForIndex:index fromLeftSide:leftSide];
    [parentContainer insertSubview:itemInfo.container atIndex:0];
    
    // Determine insertion position
    NSInteger realIndex = MIN(MAX(0, index), items.count);
    [items insertObject:itemInfo atIndex:realIndex];
    
    // Iterate through items that remain on their places
    CGFloat originX = 0;
    for (int i = 0; i < realIndex; ++i)
    {
        TSNavigationStripComponentInfo *info = items[i];
        originX += info.container.frame.size.width;
    }
    
    // Set new item original position 
    itemInfo.container.frame = CGRectMake(originX - (leftSide ? itemInfo.container.frame.size.width : 0), itemInfo.container.frame.origin.y, itemInfo.container.frame.size.width, itemInfo.container.frame.size.height);

    [TSUtils performViewAnimationBlock:^{
        // Iterate through items that are going to move right
        CGFloat x = originX;
        for (int i = realIndex; i < items.count; ++i)
        {
            TSNavigationStripComponentInfo *info = items[i];
            info.container.frame = CGRectMake(x, info.container.frame.origin.y, info.container.frame.size.width, info.container.frame.size.height);
            x += info.container.frame.size.width;
            
            // Update index
            info.container.tag = info.control.tag = (leftSide ? -(i + 1) : (i + 1));
        }
        
        // Update items container size
        if(leftSide)
        {
            [self updateLeftContainerLayoutWithNewWidth:x];
        }
        else
        {
            [self updateRightContainerLayoutWithNewWidth:x];
        }
        [self updateCenterContainerLayout];
        [self updateSectionsScrollSizeOnlyIfNewSizeGreater:YES];
        [self updateSectionsLayout];
        [self updateEmptySpaceHolderLayout];
        
    } withCompletion:^{
        [self updateSectionsScrollSizeOnlyIfNewSizeGreater:NO];
        [self updateEmptySpaceHolderLayout];
        [self updateSectionsViewMaskLayout];
    } animated:animated];
}

- (void)removeItemAtIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide animated:(BOOL)animated
{
    VerboseLog();
    NSMutableArray *items = (leftSide ? _leftItems : _rightItems);
    if(0 <= index && index < items.count)
    {
        TSNavigationStripComponentInfo *itemInfo = items[index];
        [itemInfo.container removeFromSuperview];
        [items removeObjectAtIndex:index];
        
        // Iterate through items that remain on their places
        CGFloat originX = 0;
        for (int i = 0; i < index; ++i)
        {
            TSNavigationStripComponentInfo *info = items[i];
            originX += info.container.frame.size.width;
        }
        
        _sectionsScrollView.contentSize = CGSizeMake(_sectionsScrollView.contentSize.width + itemInfo.container.frame.size.width, _sectionsScrollView.contentSize.height);
        
        [TSUtils performViewAnimationBlock:^{
            
            CGFloat x = originX;
            // Iterate through items that are going to move left
            for (int i = index; i < items.count; ++i)
            {
                TSNavigationStripComponentInfo *info = items[i];
                info.container.frame = CGRectMake(x, info.container.frame.origin.y, info.container.frame.size.width, info.container.frame.size.height);
                x += info.container.frame.size.width;
                
                // Update index
                info.container.tag = info.control.tag = (leftSide ? -(i + 1) : (i + 1));
            }
            
            // Update items container size
            if(leftSide)
            {
                [self updateLeftContainerLayoutWithNewWidth:x];
            }
            else
            {
                [self updateRightContainerLayoutWithNewWidth:x];
            }
            [self updateCenterContainerLayout];
            [self updateSectionsScrollSizeOnlyIfNewSizeGreater:YES];
            [self updateSectionsLayout];
            [self updateEmptySpaceHolderLayout];
            
        } withCompletion:^{
            [self updateSectionsScrollSizeOnlyIfNewSizeGreater:NO];
            [self updateEmptySpaceHolderLayout];
        } animated:animated];

        [self updateSectionsViewMaskLayout];
    }
}

- (void)updateSectionsAtIndexes:(NSArray *)indexes animated:(BOOL)animated
{
    [indexes enumerateObjectsUsingBlock:^(NSNumber *index, NSUInteger idx, BOOL *stop) {
        TSNavigationStripComponentInfo *itemInfo = [_sections objectAtIndex:[index integerValue]];
        [self setSectionAppearance:itemInfo atIndex:[index integerValue]];
    }];
}

- (void)updateItemsAtIndexes:(NSArray *)indexes fromLeftSide:(BOOL)leftSide animated:(BOOL)animated
{
    NSMutableArray *items = (leftSide ? _leftItems : _rightItems);
    [indexes enumerateObjectsUsingBlock:^(NSNumber *index, NSUInteger idx, BOOL *stop) {
        TSNavigationStripComponentInfo *itemInfo = [items objectAtIndex:[index integerValue]];
        [self setItemAppearance:itemInfo atIndex:[index integerValue] fromLeftSide:leftSide];
    }];
}

- (void)insertSectionsAtIndexes:(NSArray *)indexes animated:(BOOL)animated
{
    NSAssert(FALSE, @"Not implemented");
}

- (void)removeSectionsAtIndexes:(NSArray *)indexes animated:(BOOL)animated
{
    NSAssert(FALSE, @"Not implemented");
}

- (void)insertItemsAtIndexes:(NSArray *)indexes fromLeftSide:(BOOL)leftSide animated:(BOOL)animated
{
    NSAssert(FALSE, @"Not implemented");
}

- (void)removeItemsAtIndexes:(NSArray *)indexes fromLeftSide:(BOOL)leftSide animated:(BOOL)animated
{
    NSAssert(FALSE, @"Not implemented");
}

@end
