//
//  TSTableViewDataSource.h
//  TSUIKit
//
//  Created by Viacheslav Radchenko on 8/10/13.
//  Copyright (c) 2013 Viacheslav Radchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TSTableViewCell;
@class TSTableViewHeaderSectionView;
@class TSTableView;

@protocol TSTableViewDataSource <NSObject>

/**
 *  @abstract Total number of columns (including subcolumns) in table
 */
- (NSInteger)numberOfColumns;

/**
 *  @abstract Total number of rows (including subrows) in table
 */
- (NSInteger)numberOfRows;

/**
 *  @abstract Number of subcolumns at specified path
 *  @param indexPath - if nil, return number top level columns
 */
- (NSInteger)numberOfColumnsAtPath:(NSIndexPath *)indexPath;

/**
 *  @abstract Number of subrows at specified path
 *  @param indexPath - if nil, return number top level rows
 */
- (NSInteger)numberOfRowsAtPath:(NSIndexPath *)indexPath;

/**
 *  @abstract Return height for row at specified path
 */
- (CGFloat)heightForRowAtPath:(NSIndexPath *)indexPath;

/**
 *  @abstract Return height for header section at specified path
 */
- (CGFloat)heightForHeaderSectionAtPath:(NSIndexPath *)columnPath;

/**
 *  @abstract Return default/prefered width for column at specified path
 */
- (CGFloat)defaultWidthForColumnAtPath:(NSIndexPath *)columnPath;

/**
 *  @abstract Return height for header section at specified path
 */
- (TSTableViewCell *)tableView:(TSTableView *)tableView cellViewForRowAtPath:(NSIndexPath *)indexPath cellIndex:(NSInteger)index;

/**
 *  @abstract Return height for header section at specified path
 */
- (TSTableViewHeaderSectionView *)tableView:(TSTableView *)tableView headerSectionViewForColumnAtPath:(NSIndexPath *)indexPath;

@end
