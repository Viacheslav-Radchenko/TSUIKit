//
//  TSTableView.h
//  TSUIKit
//
//  Created by Viacheslav Radchenko on 8/9/13.
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

#import "TSTableViewDataSource.h"
#import "TSTableViewDelegate.h"

/* Default appearance styles of TSTableView provided by TSTableViewModel */
typedef enum {
    kTSTableViewStyleDark,  /* Dark color scheme is used for backgrounds and light colors for font */
    kTSTableViewStyleLight  /* Light color scheme is used for backgrounds and dark colors for font */
} TSTableViewStyle;


/**
 @abstract   Classes provided below implement prototype for TSTableViewDataSource.
 It is optional part of TSTableView infrastructure, inluded as an example of possible data source implementation.
 
 This prototype provides enough flexibility for building custom TSTableView containers.
 If you need something completly different you can always implement your own data source entity.
 */

/**************************************************************************************************************************************/

/** TSColumn provides infromation about content and appearance of TSTableViewHederSectionView component. Initialization dictionary can contain values for properties specified in  TSColumn interface. Example:
 
 ```
 NSDictionary *columnInfo = @{
 @"title" : @"Column 1",
 @"subtitle" : @"This is first column",
 @"subcolumns" : @[
 @{ @"title" : @"Subcolumn 1.1"},
 @{ @"title" : @"Subcolumn 1.2"}
 ]
 };
 ```
 */
@interface TSColumn : NSObject

/** Array of subcolumns/subsections. */
@property (nonatomic, strong) NSArray *subcolumns;
/** Column title. */
@property (nonatomic, strong) NSString *title;
/** Column details. */
@property (nonatomic, strong) NSString *subtitle;
/** Column icon. */
@property (nonatomic, strong) UIImage *icon;
/** Tint color for background. */
@property (nonatomic, strong) UIColor *color;
/** Color for title. */
@property (nonatomic, strong) UIColor *titleColor;
/** Color for details. */
@property (nonatomic, strong) UIColor *subtitleColor;
/** Title font size. */
@property (nonatomic, assign) CGFloat titleFontSize;
/** Details font size. */
@property (nonatomic, assign) CGFloat subtitleFontSize;
/** Default (or initial) column width. */
@property (nonatomic, assign) CGFloat defWidth;
/** Minimal column width. */
@property (nonatomic, assign) CGFloat minWidth;
/** Maximal column width. */
@property (nonatomic, assign) CGFloat maxWidth;
/** Column header height. */
@property (nonatomic, assign) CGFloat headerHeight;
/** Text aligment used for title and details. */
@property (nonatomic, assign) NSTextAlignment textAlignment;

/** Create column with title.
 @param title Title displayed in column header.
 */
+ (id)columnWithTitle:(NSString *)title;
/** Create column with title and subcolumns.
 @param title Title displayed in column header.
 @param sublolumns Array of TSColumn objects or NSString titles for subcolumns.
 */
+ (id)columnWithTitle:(NSString *)title andSubcolumns:(NSArray *)sublolumns;
/** Create column with dictionary which define content and properties of TSColumn.
 @param info Dictionary containes values for named properties of TSColumn.
 
 ```
 NSDictionary *columnInfo = @{
 @"title" : @"Column 1",
 @"subtitle" : @"This is first column",
 @"subcolumns" : @[
 @{ @"title" : @"Subcolumn 1.1"},
 @{ @"title" : @"Subcolumn 1.2"}
 ]
 };
 ```
 */
+ (id)columnWithDictionary:(NSDictionary *)info;

/** Initialize column with title.
 @param title Title displayed in column header.
 */
- (id)initWithTitle:(NSString *)title;
/** Initialize column with title and subcolumns.
 @param title Title displayed in column header.
 @param sublolumns Array of TSColumn objects or NSString titles for subcolumns.
 */
- (id)initWithTitle:(NSString *)title andSubcolumns:(NSArray *)sublolumns;
/** Initialize column with dictionary which define content and properties of TSColumn.
 @param info Dictionary containes values for named properties of TSColumn.
 
 ```
 NSDictionary *columnInfo = @{
 @"title" : @"Column 1",
 @"subtitle" : @"This is first column",
 @"subcolumns" : @[
 @{ @"title" : @"Subcolumn 1.1"},
 @{ @"title" : @"Subcolumn 1.2"}
 ]
 };
 ```
 */
- (id)initWithDictionary:(NSDictionary *)info;

@end

/**************************************************************************************************************************************/

/** TSRow provides information about table row content (cells) and hierarchy (subrows). */
@interface TSRow : NSObject

/** Array of TSCell objects. */
@property (nonatomic, strong) NSArray *cells;
/** Array of TSRow objects (subrows). */
@property (nonatomic, strong) NSMutableArray *subrows;

/** Create row with set of cells.
 @param cells Array may contain mix of TSCell objects and any other NSObject value (which would be converted to TSCell).
 */
+ (id)rowWithCells:(NSArray *)cells;
/** Create row with set of cells.
 @param cells Array may contain mix of TSCell objects and any other NSObject value (which would be converted to TSCell).
 @param subrows Array may contain mix of TSRow and NSArray objects.
 */
+ (id)rowWithCells:(NSArray *)cells andSubrows:(NSArray *)subrows;
/** Create row with dictionary which define content TSRow.
 @param info Dictionary containes values for cells and subrows.
 
 ```
 NSDictionary *rowInfo = @{
 @"cells" : @[
 @{ @"value" : @1 },
 @{ @"value" : @1 },
 @{ @"value" : @1 }
 ],
 @"subrows" : @[
 @{ @"cells" : @[
 @{ @"value" : @1 },
 @{ @"value" : @1 },
 @{ @"value" : @1 } ] },
 @{ @"cells" : @[
 @{ @"value" : @1 },
 @{ @"value" : @1 },
 @{ @"value" : @1 } ] },
 ]
 };
 ```
 */
+ (id)rowWithDictionary:(NSDictionary *)info;
/** Initialize row with set of cells.
 @param cells Array may contain mix of TSCell objects and any other NSObject value (which would be converted to TSCell).
 */
- (id)initWithCells:(NSArray *)cells;
/** Initialize row with set of cells.
 @param cells Array may contain mix of TSCell objects and any other NSObject value (which would be converted to TSCell).
 @param subrows Array may contain mix of TSRow and NSArray objects.
 */
- (id)initWithCells:(NSArray *)cells andSubrows:(NSArray *)subrows;
/** Initialize row with dictionary which define content TSRow.
 @param info Dictionary containes values for cells and subrows.
 
 ```
 NSDictionary *rowInfo = @{
 @"cells" : @[
 @{ @"value" : @1 },
 @{ @"value" : @1 },
 @{ @"value" : @1 }
 ],
 @"subrows" : @[
 @{ @"cells" : @[
 @{ @"value" : @1 },
 @{ @"value" : @1 },
 @{ @"value" : @1 } ] },
 @{ @"cells" : @[
 @{ @"value" : @1 },
 @{ @"value" : @1 },
 @{ @"value" : @1 } ] },
 ]
 };
 ```
 */
- (id)initWithDictionary:(NSDictionary *)info;

@end

/**************************************************************************************************************************************/

/** TSCell provides inforamation about TableView cell content. */
@interface TSCell : NSObject

/** Value for cell (NSString, NSNumber etc). */
@property (nonatomic, strong) NSObject *value;
/** Details text for cell. */
@property (nonatomic, strong) NSString *details;
/** Icon image for cell. */
@property (nonatomic, strong) UIImage *icon;
/** Text aligment in cell. */
@property (nonatomic, assign) NSTextAlignment textAlignment;
/** Text color. */
@property (nonatomic, strong) UIColor *textColor;
/** Details color. */
@property (nonatomic, strong) UIColor *detailsColor;

/** Create cell with value.
 @param value NSObject value type. Provide NSString, NSNumber etc arguments.
 */
+ (id)cellWithValue:(NSObject *)value;
/** Create cell with dictionary which define content and properties of TSCell.
 @param info Dictionary containes values for named properties of TSCell.
 
 ```
 NSDictionary *cellInfo = @{
 @"value" : @1,
 @"icon" : @"image.png"
 };
 ```
 */
+ (id)cellWithDictionary:(NSDictionary *)info;
/** Initialize cell with value.
 @param value NSObject value type. Provide NSString, NSNumber etc arguments.
 */
- (id)initWithValue:(NSObject *)value;
/** Initialize cell with dictionary which define content and properties of TSCell.
 @param info Dictionary containes values for named properties of TSCell.
 
 ```
 NSDictionary *cellInfo = @{
 @"value" : @1,
 @"icon" : @"image.png"
 };
 ```
 */
- (id)initWithDictionary:(NSDictionary *)info;

@end


/**
    @abstract   TSTableView is UI component for displaying multicolumns tabular data. It supports hierarchical rows and columns structure.
                Component optimized to display big sets of data: row and cell views are cached internaly and reused during scrolling/expanding.
                Basic layout is shown below:
 *
    +-----+-------------------------------------------+
    |     |          TSTableViewHeaderPanel           |  
    +-----+-------------------------------------------+
    |     |                                           |
    |  T  |                                           |
    |  S  |                                           |
    |  S  |                                           | 
    |  i  |                                           |
    |  d  |                                           |
    |  e  |                                           |
    |  C  |                                           |
    |  o  |        TSTableViewContentHolder           |
    |  n  |                                           |
    |  t  |                                           |
    |  r  |                                           |
    |  o  |                                           |
    |  l  |                                           |
    |     |                                           |
    +-----+-------------------------------------------+
 *
 *
 */

@interface TSTableView : UIView

@property (nonatomic, weak) id<TSTableViewDelegate> delegate;

/**
    @abstract Maximum nesting level in rows hierarchy
 */
@property (nonatomic, assign, readonly) NSInteger maxNestingLevel;

/**
    @abstract Additionl scrollable content from right side and bottom side. Change applied after reloadData.
 */
@property (nonatomic, assign) CGFloat contentAdditionalSize;

/**
    @abstract Show hihlights when user taps control (slide control in header secrion and expand control in side panel)
 */
@property (nonatomic, assign) BOOL highlightControlsOnTap;

/**
    @abstract Allow row selection on tap
    @def YES
 */
@property (nonatomic, assign) BOOL allowRowSelection;

/**
    @abstract Allow column selection on tap
    @def YES
 */
@property (nonatomic, assign) BOOL allowColumnSelection;

/**
    @abstract If NO then line numbers are displayed in side panel
 */
@property (nonatomic, assign) BOOL lineNumbersHidden;

/**
    @abstract If YES then header niew isn't shown
    @def NO
 */
@property (nonatomic, assign) BOOL headerPanelHidden;

/**
    @abstract If YES then expand niew isn't shown
    @def NO
 */
@property (nonatomic, assign) BOOL expandPanelHidden;

/**
    @abstract Color for row line numbers in side panel
 */
@property (nonatomic, strong) UIColor *lineNumbersColor;

/**
    @abstract Set background image for header panel to customize appearance
 */
@property (nonatomic, strong) UIImage *headerBackgroundImage;

/**
    @abstract Set background image for expand panel to customize appearance
 */
@property (nonatomic, strong) UIImage *expandPanelBackgroundImage;

/**
    @abstract Set background image for top left panel to customize appearance
 */
@property (nonatomic, strong) UIImage *topLeftCornerBackgroundImage;

/**
    @abstract  This image is used for expand item control in normal (not expanded) state.
               Image wouldn't be stretched and will have bottom left alignment
 */
@property (nonatomic, strong) UIImage *expandItemNormalBackgroundImage;

/**
    @abstract  This image is used for expand item control in selected (expanded) state.
               Image wouldn't be stretched and will have bottom left alignment
 */
@property (nonatomic, strong) UIImage *expandItemSelectedBackgroundImage;

/**
    @abstract  Provide background image for expand section in side control panel.
               Image would be stretched depending on the size of section.
 */
@property (nonatomic, strong) UIImage *expandSectionBackgroundImage;

/**
    @abstract  Background color for header panel
 */
@property (nonatomic, strong) UIColor *headerBackgroundColor;

/**
    @abstract  Background color for expand panel
 */
@property (nonatomic, strong) UIColor *expandPanelBackgroundColor;

/** Readonly array with information about columns hierarchy. */
@property (nonatomic, strong, readonly) NSArray *columns;
/** Readonly array with information about rows data. */
@property (nonatomic, strong, readonly) NSArray *rows;

/** TSTableView style choosen during initialization */
@property (nonatomic, assign, readonly) TSTableViewStyle tableStyle;
/** Row height.
 @warning This data model use fixed row height. Override TSTableViewModel to provide varied row height functionality.  TSTableView support rows with varied height.
 */
@property (nonatomic, assign) CGFloat heightForRow;
/** Width of one nesting level in expand panel. Total panel width would be widthForExpandItem * maxRowNestingLevel. */
@property (nonatomic, assign) CGFloat widthForExpandItem;


/** Initialize with array of columns and rows.
 @param columns Array can contain objects of mixed types (TSColumn, NSDictionary, NSString). TSColumn objects would be constructed if needed.
 @param rows Array can contain objects of mixed types (TSRow, NSDictionary, NSString). TSRow objects would be constructed if needed.
 */
- (void)setColumns:(NSArray *)columns andRows:(NSArray *)rows;
/** Initialize with rows data. Columns hierarchy remains the same.
 @param rows  Array can contain objects of mixed types (TSRow, NSDictionary, NSString). TSRow objects would be constructed if needed.
 */
- (void)setRows:(NSArray *)rows;
/** Insert new row at specified path. TSTableView would be notified about changes in data model.
 @param rowInfo TSRow instance with new data.
 @param indexPath Insert positon.
 */
- (void)insertRow:(TSRow *)rowInfo atPath:(NSIndexPath *)indexPath;
/** Remove row at specified path. TSTableView would be notified about changes in data model.
 @param indexPath Remove positon.
 */
- (void)removeRowAtPath:(NSIndexPath *)indexPath;
/** Replace (update) information in row at specified path. TSTableView would be notified about changes in data model.
 @param indexPath Updated row positon.
 @param rowInfo TSRow instance with new data.
 */
- (void)replcaceRowAtPath:(NSIndexPath *)indexPath withRow:(TSRow *)rowInfo;

/**
    @abstract  //mark: add init with style
 */
- (id)initWithFrame:(CGRect)frame andStyle:(TSTableViewStyle)style;

/**
    @abstract Reload content. Both columns and rows are updated
 */
- (void)reloadData;

/**
    @abstract Reload rows data
 */
- (void)reloadRowsData;

/**
    @abstract Reuse cached instance of cell view with specified Id.
 */
- (TSTableViewCell *)dequeueReusableCellViewWithIdentifier:(NSString *)identifier;

/**
    @abstract Clear cached data (reusable rows, cells that aren't used at this moment).
 */
- (void)clearCachedData;

/**
    @abstract Change expand state of the row
 */
- (void)changeExpandStateForRow:(NSIndexPath *)rowPath toValue:(BOOL)expanded animated:(BOOL)animated;

/**
 @abstract Toggle expand state of the row
 */
- (void)toggleExpandStateForRow:(NSIndexPath *)rowPath animated:(BOOL)animated;

/**
    @abstract Expand all rows
 */
- (void)expandAllRowsWithAnimation:(BOOL)animated;

/**
    @abstract Collapse all rows
 */
- (void)collapseAllRowsWithAnimation:(BOOL)animated;

/**
    @abstract Select row at path
 */
- (void)selectRowAtPath:(NSIndexPath *)rowPath animated:(BOOL)animated;

/**
    @abstract Hide current selection
 */
- (void)resetRowSelectionWithAnimtaion:(BOOL)animated;

/**
    @abstract Select row at path
 */
- (void)selectColumnAtPath:(NSIndexPath *)rowPath animated:(BOOL)animated;

/**
    @abstract Hide current selection
 */
- (void)resetColumnSelectionWithAnimtaion:(BOOL)animated;

/**
    @abstract Return path to selected row. If no row currently selected return nil.
 */
- (NSIndexPath *)pathToSelectedRow;

/**
    @abstract Return path to selected column. If no column currently selected return nil.
 */
- (NSIndexPath *)pathToSelectedColumn;

/**
    @abstract Modify content
 */
- (void)insertRowAtPath:(NSIndexPath *)path animated:(BOOL)animated;
- (void)removeRowAtPath:(NSIndexPath *)path animated:(BOOL)animated;
- (void)updateRowAtPath:(NSIndexPath *)path;

// Not implemented yet
- (void)insertRowsAtPathes:(NSArray *)pathes animated:(BOOL)animated;
- (void)updateRowsAtPathes:(NSArray *)pathes animated:(BOOL)animated;
- (void)removeRowsAtPathes:(NSArray *)pathes animated:(BOOL)animated;

@end


