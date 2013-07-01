//
//  TSRootViewController.h
//  TSUIKit
//
//  Created by Viacheslav Radchenko on 6/21/13.
//  Copyright (c) 2013 Viacheslav Radchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSRootViewController : UIViewController <UIPageViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;

@property (nonatomic, strong) UIPageViewController *pageViewController;

@end
