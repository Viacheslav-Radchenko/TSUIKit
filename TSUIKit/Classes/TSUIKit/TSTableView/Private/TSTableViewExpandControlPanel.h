//
//  TSTableViewExpandControlPanel.h
//  TSUIKit
//
//  Created by Viacheslav Radchenko on 8/12/13.
//  Copyright (c) 2013 Viacheslav Radchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSTableViewExpandControlPanel;

@protocol TSTableViewExpandControlPanelDelegate <NSObject>

- (void)tableViewSideControlPanel:(TSTableViewExpandControlPanel *)controlPanel expandStateDidChange:(BOOL)expand forRow:(NSIndexPath *)rowPath;

@end

@protocol TSTableViewDataSource;
@protocol TSTableViewAppearanceCoordinator;

@interface TSTableViewExpandControlPanel : UIScrollView

@property (nonatomic, weak) id<TSTableViewExpandControlPanelDelegate> controlPanelDelegate;
@property (nonatomic, weak) id<TSTableViewDataSource, TSTableViewAppearanceCoordinator> dataSource;

- (void)reloadData;
- (void)changeExpandStateForRow:(NSIndexPath *)rowPath toValue:(BOOL)expanded animated:(BOOL)animated;
- (void)expandAllRowsWithAnimation:(BOOL)animated;
- (void)collapseAllRowsWithAnimation:(BOOL)animated;
- (BOOL)isRowExpanded:(NSIndexPath *)rowPath;


/**
 *  @abstract Height of the table taking into account expanded/collapsed rows
 */
- (CGFloat)tableHeight;

/**
 *  @abstract Height of the table with all rows expanded
 */
- (CGFloat)tableTotalHeight;

- (CGFloat)expandControlPanelWidth;

@end
