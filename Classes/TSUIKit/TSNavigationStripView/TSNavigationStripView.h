//
//  TSNavigationStripView.h
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

#import <UIKit/UIKit.h>
#import "TSNavigationStripViewDelegate.h"
#import "TSNavigationStripDataSource.h"

/**
    @abstract   TSNavigationStripView is navigation menu control with highly customizable design and flexible structure.
                Provides smooth animations for dynamic content modification.
                Basic layout shown below:
 
    +------------+---+--------------+---+-------------+
    | LEFT ITEMS | < |   SECTIONS   | > | RIGHT ITEMS |
    +------------+---+--------------+---+-------------+
 
                LEFT ITEMS and RIGHT ITEMS - containers for menu items.
                SECTIONS - container for tab sections strip.
 
    @limitations - When total width of LEFT ITEMS and RIGHT ITEMS exceeds view's frame width then layout of control is undefined.
                 - For central aligment (sectionsAligment = UIViewContentModeCenter) limitation described above is more stronger: 
                    SECTIONS part should have space no less then (sectionWidth + selectedSectionWidth + sectionWidth) or corresponding sizes specified in data source.
 */

@interface TSNavigationStripView : UIView

@property (nonatomic, weak) id<TSNavigationStripViewDelegate>   delegate;
@property (nonatomic, weak) id<TSNavigationStripDataSource>     dataSource;

/**
    @abstract Currently selected section.
 */
@property (nonatomic, assign, readonly) NSInteger               selectedSection;

/**
    @abstract   Default section width value. These values used in case if dataSource is not provide this information.
    @def        selectedSectionWidth = 256
                sectionWidth = 128
 */
@property (nonatomic, assign) CGFloat                           selectedSectionWidth;
@property (nonatomic, assign) CGFloat                           sectionWidth;          

/**
    @abstract   If YES funny colors set to backroundColor property of subviews.
    @def        NO
 */
@property (nonatomic, assign) BOOL debugMode;

/**
    @abstract   If YES alpha mask applied to sections container to add effect of transparency on edges. 
    @def        YES
 */
@property (nonatomic, assign) BOOL maskSectionsContainerEdges;


/**
    @abstract   Determine how sections aligned in container view.
    @supported
        UIViewContentModeCenter,
        UIViewContentModeLeft,
        UIViewContentModeRight,
        UIViewContentModeScaleAspectFill
    @def
        UIViewContentModeCenter
 */
@property (nonatomic, assign) UIViewContentMode sectionsAligment;


/**
    @abstract   If NO navigation buttons always displayed (if navigationButtonsHidden == NO)
                if YES visibility of each button determined dynamically and depends on currenct selectedSection
    @def        YES
 */
@property (nonatomic, assign) BOOL autohideNavigationButtons;

/**
    @abstract   If YES navigation buttons are not shown,
                if NO navigation buttons visibility depends on autohideNavigationButtons
    @def        NO
 */
@property (nonatomic, assign) BOOL navigationButtonsHidden;

/**
    @abstract   Customize appearance of default components
 */
@property (nonatomic, strong, readonly) UIButton *leftNavigationButton;
@property (nonatomic, strong, readonly) UIButton *rightNavigationButton;

/**
    @abstract   Customise appearance providing bacground image
    @def        nil
 */
@property (nonatomic, strong)           UIImage  *backgroundImage;

/**
    @abstract   If sections conatainer not full then emptySpaceHolderImage would be displayed on one of the edge.
                Set it if you need continious graphics layout.
    @def        nil
 */
@property (nonatomic, strong)           UIImage  *emptySpaceHolderImage;

/**
    @abstract   Tis view would be layouted under selected section and smoothly moved during selection animation
    @def        nil
 */
@property (nonatomic, strong)           UIView  *selectionMarker;


- (id)initWithFrame:(CGRect)frame;

/**
    @abstract   Reload content
 */
- (void)reloadData;
- (void)reloadSectionsData;
- (void)reloadItemsData;

/**
    @abstract   Change selection
 */
- (void)selectSectionAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)selectItemAtIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide;
- (void)deselectItemAtIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide;
- (BOOL)isItemSelectedAtIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide;

/**
    @abstract Applied only if sectionsAligment is set to UIViewContentAligmentCenter. Shift selected section to right/left side.
    @param    normOffset - in range [-1..1]
 */
- (void)scrollSelectedSectionTo:(CGFloat)normOffset;

/**
    @abstract   Modify content
 */
- (void)insertSectionAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)removeSectionAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)insertItemAtIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide animated:(BOOL)animated;
- (void)removeItemAtIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide animated:(BOOL)animated;
- (void)updateSectionsAtIndexes:(NSArray *)indexes animated:(BOOL)animated;
- (void)updateItemsAtIndexes:(NSArray *)indexes fromLeftSide:(BOOL)leftSide animated:(BOOL)animated;

// Not implemented yet
- (void)insertSectionsAtIndexes:(NSArray *)indexes animated:(BOOL)animated;
- (void)removeSectionsAtIndexes:(NSArray *)indexes animated:(BOOL)animated;
- (void)insertItemsAtIndexes:(NSArray *)indexes fromLeftSide:(BOOL)leftSide animated:(BOOL)animated;
- (void)removeItemsAtIndexes:(NSArray *)indexes fromLeftSide:(BOOL)leftSide animated:(BOOL)animated;

@end
