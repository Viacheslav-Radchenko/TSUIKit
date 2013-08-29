//
//  TSNavigationStripModel.h
//  TSUIKit
//
//  Created by Viacheslav Radchenko on 6/17/13.
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

#import <Foundation/Foundation.h>
#import "TSNavigationStripView.h"


/**
    @abstract   Classes provided below implement prototype for TSNavigationStripDataSource.
                It is optional part of TSNavigationStripView infrastructure, inluded as an example of possible data source implementation.
                
                This prototype provides enough flexibility for building custom TSNavigationStripView controls. 
                If you need something completly different you can always implement your own data source entity.
 */

/**************************************************************************************************************************************/

/**
    @abstract   TSNavigationStripComponent is base class, which provides appearance information for TSNavigationStripView's section or item.
 */

@interface TSNavigationStripComponent : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *selectedTitle;

@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) UIImage *selectedIcon;

@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) UIImage *selectedBackgroundImage;

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIFont *selectedFont;

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIColor *selectedColor;

@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *selectedBackgroundColor;

@property (nonatomic, strong) UIColor *shadowColor;
@property (nonatomic, assign) CGSize  shadowOffset;

// Bind Strip Component with action.
//@property (nonatomic, weak) id target;
//@property (nonatomic, assign) SEL action;
//@property (nonatomic, copy) void (^selectionHandler)();

@end

/**************************************************************************************************************************************/

@interface TSNavigationStripItem : TSNavigationStripComponent

@end

/**************************************************************************************************************************************/

@interface TSNavigationStripSection : TSNavigationStripComponent

@end

/**************************************************************************************************************************************/

/**
    @abstract   TSNavigationStripModel is a prototype for TSNavigationStripDataSource
 */

@interface TSNavigationStripModel : NSObject <TSNavigationStripDataSource>
{
    NSMutableArray *_leftItems;
    NSMutableArray *_rightItems;
    NSMutableArray *_sections;
    TSNavigationStripView *_navigationStrip;
}

@property (nonatomic, strong, readonly) NSArray *leftItems;
@property (nonatomic, strong, readonly) NSArray *rightItems;
@property (nonatomic, strong, readonly) NSArray *sections;
@property (nonatomic, strong, readonly) TSNavigationStripView *navigationStrip;

/**
    @abstract   if YES edge insets are used for section's content. Need for some UI layouts where graphics from one section should overlap sibling sections 
    @def        NO
 */
@property (nonatomic, assign) BOOL useEdgeInsetsForSections;

/**
    @abstract   if not set then UIButton class is used
    @def        nil
 */
@property (nonatomic, strong) NSString *customClassForSection;

- (id)initWithNavigationStrip:(TSNavigationStripView *)navigationStrip;

/**
    @abstract Modify content
 */
- (void)setSections:(NSArray *)sections;
- (void)setItems:(NSArray *)sections fromLeft:(BOOL)fromLeft;
- (void)insertNewSection:(TSNavigationStripSection *)sectionInfo atIndex:(NSInteger)index animated:(BOOL)animated;
- (void)insertNewItem:(TSNavigationStripItem *)itemInfo atIndex:(NSInteger)index fromLeft:(BOOL)fromLeft animated:(BOOL)animated;
- (void)removeSectionAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)removeItemAtIndex:(NSInteger)index fromLeft:(BOOL)fromLeft animated:(BOOL)animated;

@end
