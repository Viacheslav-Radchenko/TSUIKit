//
//  TSTableViewContentHolder.h
//  TSUIKit
//
//  Created by Viacheslav Radchenko on 8/13/13.
//  Copyright (c) 2013 Viacheslav Radchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSTableViewContentHolder;

@protocol TSTableViewContentHolderDelegate <NSObject>

- (void)tableViewContentHolder:(TSTableViewContentHolder *)contentHolder contentOffsetDidChange:(CGPoint)contentOffset animated:(BOOL)animated;

@end

@protocol TSTableViewDataSource;
@protocol TSTableViewAppearanceCoordinator;

@interface TSTableViewContentHolder : UIScrollView
{
    NSMutableArray *_rows;
}

@property (nonatomic, weak) id<TSTableViewContentHolderDelegate> contentHolderDelegate;
@property (nonatomic, weak) id<TSTableViewDataSource, TSTableViewAppearanceCoordinator> dataSource;

- (void)reloadData;
- (void)changeColumnWidthOnAmount:(CGFloat)delta forColumn:(NSInteger)columnIndex animated:(BOOL)animated;
- (void)changeExpandStateForRow:(NSIndexPath *)rowPath toValue:(BOOL)expanded animated:(BOOL)animated;
- (void)expandAllRowsWithAnimation:(BOOL)animated;
- (void)collapseAllRowsWithAnimation:(BOOL)animated;

@end
