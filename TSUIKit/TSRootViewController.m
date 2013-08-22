//
//  TSRootViewController.m
//  TSUIKit
//
//  Created by Viacheslav Radchenko on 6/21/13.
//  Copyright (c) 2013 Viacheslav Radchenko. All rights reserved.
//

#import "TSRootViewController.h"
#import "TSModelController.h"

@interface TSRootViewController ()
@property (readonly, strong, nonatomic) TSModelController *modelController;
@end

@implementation TSRootViewController

@synthesize modelController = _modelController;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // Configure the page view controller and add it as a child view controller.
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.delegate = self;
    
    [[self.pageViewController gestureRecognizers] enumerateObjectsUsingBlock:^(UIGestureRecognizer *recognizer, NSUInteger idx, BOOL *stop) {
        if ([recognizer isKindOfClass:[UITapGestureRecognizer class]])
        {
            recognizer.enabled = NO;
        }
    }];

    UIViewController *startingViewController = [self.modelController viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];

    self.pageViewController.dataSource = self.modelController;

    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];

    // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
    CGRect pageViewRect = self.view.bounds;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        pageViewRect = CGRectInset(pageViewRect, 10, 20);
    }
    self.pageViewController.view.frame = pageViewRect;

    [self.pageViewController didMoveToParentViewController:self];

    // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
    self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
    
    self.pageControl.numberOfPages = self.modelController.pages.count;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (TSModelController *)modelController
{
     // Return the model controller object, creating it if necessary.
     // In more complex implementations, the model controller may be passed to the view controller.
    if (!_modelController)
    {
        _modelController = [[TSModelController alloc] initWithPages: @[
                            @"TSTableViewController",
                            @"TSNavigationStripTestViewController",
                            @"TSTabViewTestViewController",
                            @"TSTabViewWithDropDownPanelTestViewController"]
                            ];
    }
    return _modelController;
}

#pragma mark - UIPageViewController delegate methods


- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    UIViewController *currentViewController = self.pageViewController.viewControllers[0];
    self.pageControl.currentPage = [self.modelController indexOfViewController:currentViewController];
}
 

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    // In portrait orientation or on iPhone: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.
    
    UIViewController *currentViewController = self.pageViewController.viewControllers[0];
    NSArray *viewControllers = @[currentViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
    
    self.pageViewController.doubleSided = NO;
    return UIPageViewControllerSpineLocationMin;
}

@end
