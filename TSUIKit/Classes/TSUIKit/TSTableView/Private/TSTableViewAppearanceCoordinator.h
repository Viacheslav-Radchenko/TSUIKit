//
//  TSTableViewAppearanceCoordinator.h
//  TSUIKit
//
//  Created by Viacheslav Radchenko on 8/15/13.
//  Copyright (c) 2013 Viacheslav Radchenko. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol TSTableViewAppearanceCoordinator <NSObject>

/**
 *  @abstract Return YES if subrows of row at specified path should be visible
 */
- (BOOL)isRowExpanded:(NSIndexPath *)indexPath;

- (CGFloat)controlPanelExpandItemWidth;

/**
 *  @abstract Return total width of all columns
 */
- (CGFloat)tableTotalWidth;
- (CGFloat)tableTotalHeight;

///**
// *  @abstract Return height for row at specified path
// */
//- (CGFloat)heightForRowAtPath:(NSIndexPath *)indexPath;

///**
// *  @abstract Return height for header section at specified path
// */
//- (CGFloat)heightForHeaderSectionAtPath:(NSIndexPath *)columnPath;

/**
 *  @abstract Return width for column at specified path
 */
- (CGFloat)widthForColumnAtIndex:(NSInteger)columnIndex;
- (CGFloat)widthForColumnAtPath:(NSIndexPath *)columnPath;

- (CGFloat)defaultWidthForColumnAtPath:(NSIndexPath *)columnPath;


/**
 *  @abstract Return height for header section at specified path
 */
- (TSTableViewCell *)cellViewForRowAtPath:(NSIndexPath *)indexPath cellIndex:(NSInteger)index;

/**
 *  @abstract Return height for header section at specified path
 */
- (TSTableViewHeaderSectionView *)headerSectionViewForColumnAtPath:(NSIndexPath *)indexPath;

@end