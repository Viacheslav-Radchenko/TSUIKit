//
//  TSTableView.h
//  TSUIKit
//
//  Created by Viacheslav Radchenko on 8/9/13.
//  Copyright (c) 2013 Viacheslav Radchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TSTableViewDataSource.h"
#import "TSTableViewDelegate.h"

/**
 *  @abstract   TSTableView UI component for displying multicolumns tabular data.
 *              Basic layout shown below:
 *
 *  +-----+-------------------------------------------+
 *  |     |          TSTableViewHeaderPanel           |  
 *  +-----+-------------------------------------------+
 *  |     |                                           |
 *  |  T  |                                           |
 *  |  S  |                                           |
 *  |  S  |                                           | 
 *  |  i  |                                           |
 *  |  d  |                                           |
 *  |  e  |                                           |
 *  |  C  |                                           |
 *  |  o  |        TSTableViewContentHolder           |
 *  |  n  |                                           |
 *  |  t  |                                           |
 *  |  r  |                                           |
 *  |  o  |                                           |
 *  |  l  |                                           |
 *  |     |                                           |
 *  +-----+-------------------------------------------+
 */


@interface TSTableView : UIView

@property (nonatomic, weak) id<TSTableViewDataSource> dataSource;
@property (nonatomic, weak) id<TSTableViewDelegate> delegate;

@property (nonatomic, assign) CGFloat contentAdditionalSize;
@property (nonatomic, assign) CGFloat minColumnWidth;
@property (nonatomic, assign) CGFloat maxColumnWidth;

- (void)reloadData;

- (void)changeExpandStateForRow:(NSIndexPath *)rowPath toValue:(BOOL)expanded animated:(BOOL)animated;
- (void)expandAllRowsWithAnimation:(BOOL)animated;
- (void)collapseAllRowsWithAnimation:(BOOL)animated;

@end
