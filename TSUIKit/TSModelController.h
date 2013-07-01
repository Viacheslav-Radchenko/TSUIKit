//
//  TSModelController.h
//  TSUIKit
//
//  Created by Viacheslav Radchenko on 6/21/13.
//  Copyright (c) 2013 Viacheslav Radchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSModelController : NSObject <UIPageViewControllerDataSource>

@property (nonatomic, strong, readonly) NSArray *pages;

- (id)initWithPages:(NSArray *)pages;

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfViewController:(UIViewController *)viewController;

@end
