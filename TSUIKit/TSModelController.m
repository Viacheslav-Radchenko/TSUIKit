//
//  TSModelController.m
//  TSUIKit
//
//  Created by Viacheslav Radchenko on 6/21/13.
//  Copyright (c) 2013 Viacheslav Radchenko. All rights reserved.
//

#import "TSModelController.h"

@interface TSModelController()

@property (nonatomic, strong, readwrite) NSArray *pages;
@property (nonatomic, strong) NSMutableDictionary *controllers;

@end

@implementation TSModelController

- (id)initWithPages:(NSArray *)pages
{
    self = [super init];
    if (self)
    {
        // Create the data model.
        _pages = pages;
        _controllers = [[NSMutableDictionary alloc] initWithCapacity:_pages.count];
    }
    return self;
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{   
    // Return the data view controller for the given index.
    if (([_pages count] == 0) || (index >= [_pages count]))
    {
        return nil;
    }
    
    NSString *viewControllerName = _pages[index];
    
    UIViewController *viewController = _controllers[viewControllerName];
    if(!viewController)
    {
        viewController = [[NSClassFromString(viewControllerName) alloc] initWithNibName:viewControllerName bundle:nil];
        _controllers[viewControllerName] = viewController;
    }
    
    return viewController;
}

- (NSUInteger)indexOfViewController:(UIViewController *)viewController
{   
     // Return the index of the given data view controller.
     // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
    NSString *viewControllerName = NSStringFromClass([viewController class]);
    return [_pages indexOfObject:viewControllerName];
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:viewController];
    if ((index == 0) || (index == NSNotFound))
    {
        return nil;
    }
    
    --index;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:viewController];
    if (index == NSNotFound)
    {
        return nil;
    }
    
    ++index;
    if (index == [_pages count])
    {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

@end
