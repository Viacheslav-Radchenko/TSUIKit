//
//  TSTableViewHeaderPanel.h
//  TSUIKit
//
//  Created by Viacheslav Radchenko on 8/9/13.
//  Copyright (c) 2013 Viacheslav Radchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSTableViewHeaderPanel;

@protocol TSTableViewHeaderPanelDelegate <NSObject>

- (void)tableViewHeader:(TSTableViewHeaderPanel *)header columnWidthDidChange:(NSInteger)columnIndex oldWidth:(CGFloat)oldWidth newWidth:(CGFloat)newWidth;

@end

@protocol TSTableViewDataSource;
@protocol TSTableViewAppearanceCoordinator;

@interface TSTableViewHeaderPanel : UIScrollView

@property(nonatomic, weak) id<TSTableViewHeaderPanelDelegate> headerDelegate;
@property(nonatomic, weak) id<TSTableViewDataSource, TSTableViewAppearanceCoordinator> dataSource;

@property (nonatomic, assign) CGFloat minColumnWidth;
@property (nonatomic, assign) CGFloat maxColumnWidth;

- (void)reloadData;
- (void)changeColumnWidthOnAmount:(CGFloat)delta forColumn:(NSInteger)columnIndex animated:(BOOL)animated;


/**
 *  @abstract Width of the table 
 */
- (CGFloat)tableTotalWidth;

/**
 *  @abstract Width of the specified column
 */
- (CGFloat)widthForColumnAtIndex:(NSInteger)index;

/**
 *  @abstract Width of the specified column
 */
- (CGFloat)widthForColumnAtPath:(NSIndexPath *)indexPath;

/**
 *  @abstract Height of the table's header
 */
- (CGFloat)headerHeight;

@end
