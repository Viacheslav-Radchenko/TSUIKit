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

/** TSNavigationStripComponent provides content and appearance information for TSNavigationStripView's section or item. */
@interface TSNavigationStripComponent : NSObject

/** Title string which is displaying in TSNavigationStrip when section isn't selected. */
@property (nonatomic, strong) NSString *title;
/** Title string which is displaying in TSNavigationStrip when section is selected. Optional, if nil title is used. */
@property (nonatomic, strong) NSString *selectedTitle;
/** Icon image which is displaying in TSNavigationStrip when section isn't selected. Optional. */
@property (nonatomic, strong) UIImage *icon;
/** Icon image which is displaying in TSNavigationStrip when section is selected. Optional. */
@property (nonatomic, strong) UIImage *selectedIcon;
/** Background image which is displaying in TSNavigationStrip when section isn't selected. Optional. */
@property (nonatomic, strong) UIImage *backgroundImage;
/** Background image which is displaying in TSNavigationStrip when section is selected. Optional. */
@property (nonatomic, strong) UIImage *selectedBackgroundImage;
/** Font which is used when section is selected. Default is [UIFont systemFontOfSize:15.0f]. */
@property (nonatomic, strong) UIFont *font;
/** Font which is used when section isn't selected. Default is [UIFont boldSystemFontOfSize:15.0f]. */
@property (nonatomic, strong) UIFont *selectedFont;
/** Text color which is used when section isn't selected. Default is [UIColor darkGrayColor]. */
@property (nonatomic, strong) UIColor *color;
/** Text color which is used when section is selected. Default is [UIColor blackColor]. */
@property (nonatomic, strong) UIColor *selectedColor;
/** Background color which is used when section isn't selected. Default is [UIColor clearColor]. */
@property (nonatomic, strong) UIColor *backgroundColor;
/** Background color which is used when section is selected. Default is [UIColor clearColor]. */
@property (nonatomic, strong) UIColor *selectedBackgroundColor;
/** Text shadow color. Default is [UIColor clearColor]. */
@property (nonatomic, strong) UIColor *shadowColor;
/** Text shadow offset. Default is CGSizeZero. */
@property (nonatomic, assign) CGSize  shadowOffset;

// Bind Strip Component with action.
//@property (nonatomic, weak) id target;
//@property (nonatomic, assign) SEL action;
//@property (nonatomic, copy) void (^selectionHandler)();

/** Initialize TSNavigationStripComponent with section title 
    @param title Section title. 
 */
- (id)initWithTitle:(NSString *)title;

/** Initialize TSNavigationStripComponent with dictionary. 
    @param info Dictionary with values for named properties.
 */
- (id)initWithDictionary:(NSDictionary *)info;

@end

/**************************************************************************************************************************************/

/** Provide information about menu item in  TSNavigationStripView. */
@interface TSNavigationStripItem : TSNavigationStripComponent

@end

/**************************************************************************************************************************************/

/** Provide information about section in  TSNavigationStripView. */
@interface TSNavigationStripSection : TSNavigationStripComponent

@end

/**************************************************************************************************************************************/

/** TSNavigationStripModel is a prototype for TSNavigationStripDataSource. */
@interface TSNavigationStripModel : NSObject <TSNavigationStripDataSource>
{
    NSMutableArray *_leftItems;
    NSMutableArray *_rightItems;
    NSMutableArray *_sections;
    TSNavigationStripView *_navigationStrip;
}

/** Menu items located on the left side of TSNavigationStripView. */
@property (nonatomic, strong, readonly) NSArray *leftItems;
/** Menu items located on the right side of TSNavigationStripView. */
@property (nonatomic, strong, readonly) NSArray *rightItems;
/** Navigation sections. */
@property (nonatomic, strong, readonly) NSArray *sections;
/** Instance of TSNavigationStripView which is managed by this data model. */
@property (nonatomic, strong, readonly) TSNavigationStripView *navigationStrip;

/** If YES edge insets are used for section's content. Need for some UI layouts where graphics from one section should overlap sibling sections. 
    @def        NO
 */
@property (nonatomic, assign) BOOL useEdgeInsetsForSections;

/** If not set then UIButton class is used. Specify if you want to provide specific draw implementation or additional functionalit for section view.
    @warning If you provide custom class it should inherit from UIButton.
    @def        nil
 */
@property (nonatomic, strong) NSString *customClassForSection;

/** Initialize TSNavigationStripModel and provide instance of TSNavigationStripView which would display content of the data model.
    @param navigationStrip Instance of TSNavigationStripView.
 */
- (id)initWithNavigationStrip:(TSNavigationStripView *)navigationStrip;

/** Set sections information. TSNavigationStripView would be notified about changes in data model.
    @param sections Array of TSNavigationStripSection objects.
 */
- (void)setSections:(NSArray *)sections;
/** Set menu items information. TSNavigationStripView would be notified about changes in data model.
    @param items Array of TSNavigationStripItem objects.
    @param fromLeft Specify on which side menu items should be updated.
 */
- (void)setItems:(NSArray *)items fromLeft:(BOOL)fromLeft;
/** Insert new section at specified position. TSNavigationStripView would be notified about changes in data model.
    @param sectionInfo Information about new section.
    @param index Insert position.
    @param animated If YES section will be appear with animation.
 */
- (void)insertNewSection:(TSNavigationStripSection *)sectionInfo atIndex:(NSInteger)index animated:(BOOL)animated;
/** Insert new menu item at specified position. TSNavigationStripView would be notified about changes in data model.
    @param itemInfo Information about new menu item.
    @param index Insert position.
    @param fromLeft Specify on which side menu item should be inserted.
    @param animated If YES item will be appear with animation.
 */
- (void)insertNewItem:(TSNavigationStripItem *)itemInfo atIndex:(NSInteger)index fromLeft:(BOOL)fromLeft animated:(BOOL)animated;
/** Remove section at specified position. TSNavigationStripView would be notified about changes in data model.
     @param index Remove position.
     @param animated If YES section will be removed with animation.
 */
- (void)removeSectionAtIndex:(NSInteger)index animated:(BOOL)animated;
/** Remove menu item at specified position. TSNavigationStripView would be notified about changes in data model.
     @param index Remove position.
     @param fromLeft Specify on which side menu item should be removed.
     @param animated If YES item will be removed with animation.
 */
- (void)removeItemAtIndex:(NSInteger)index fromLeft:(BOOL)fromLeft animated:(BOOL)animated;

@end
