//
//  SSTabViewTestViewController.m
//  TabViewTest
//
//  Created by Viacheslav Radchenko on 6/20/13.
//
//  The MIT License (MIT)
//  Copyright © 2013 Viacheslav Radchenko
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <QuartzCore/QuartzCore.h>
#import "SSTabViewTestViewController.h"
#import "SSTabView.h"
#import "SSTabViewModel.h"
#import "SSDefines.h"
#import "SSTestSectionButton.h"

@interface SSTabViewTestViewController () <SSTabViewDelegate>
{
    SSTabView *_tabView1;
    SSTabView *_tabView2;
    SSTabView *_tabView3;
    SSTabView *_tabView4;
    SSTabView *_tabView5;
    SSTabViewModel *_tabViewModel1;
    SSTabViewModel *_tabViewModel2;
    SSTabViewModel *_tabViewModel3;
    SSTabViewModel *_tabViewModel4;
    SSTabViewModel *_tabViewModel5;
}

@property (nonatomic, strong) NSArray *dataSources;

@end

@implementation SSTabViewTestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.settingsView.layer.cornerRadius = 4;
    self.settingsView.layer.shadowOpacity = 0.5;
    self.settingsView.layer.shadowOffset = CGSizeMake(2, 4);
    
    _tabView1 = [self createTabView1WithFrame:CGRectMake(20, (IS_IPAD ? 90 : 20), self.view.frame.size.width - 40, (IS_IPAD ? 110 : 100))];
    _tabView1.backgroundColor = [UIColor grayColor];
    _tabView1.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _tabView1.delegate = self;
    [self.view addSubview:_tabView1];
    
    _tabView2 = [self createTabView2WithFrame:CGRectMake(20, (IS_IPAD ? 230 : 160), self.view.frame.size.width - 40, (IS_IPAD ? 110 : 100))];
    _tabView2.backgroundColor = [UIColor grayColor];
    _tabView2.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _tabView2.delegate = self;
    [self.view addSubview:_tabView2];
    
    _tabView3 = [self createTabView3WithFrame:CGRectMake(20, (IS_IPAD ? 370 : 300), self.view.frame.size.width - 40, (IS_IPAD ? 110 : 100))];
    _tabView3.backgroundColor = [UIColor grayColor];
    _tabView3.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _tabView3.delegate = self;
    [self.view addSubview:_tabView3];
    
    _tabView4 = [self createTabView4WithFrame:CGRectMake(20, (IS_IPAD ? 510 : 440), self.view.frame.size.width - 40, (IS_IPAD ? 110 : 100))];
    _tabView4.backgroundColor = [UIColor lightGrayColor];
    _tabView4.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _tabView4.delegate = self;
    [self.view addSubview:_tabView4];
    
    _tabView5 = [self createTabView5WithFrame:CGRectMake(20, (IS_IPAD ? 650 : 440), self.view.frame.size.width - 40, (IS_IPAD ? 110 : 100))];
    _tabView5.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _tabView5.delegate = self;
    [self.view addSubview:_tabView5];
    
    _tabViewModel1 = [[SSTabViewModel alloc] initWithTabView:_tabView1];
    [_tabViewModel1 setTabs:@[[self createSection1WithIndex:@0],
                             [self createSection1WithIndex:@1],
                             [self createSection1WithIndex:@2]]];
    
    _tabViewModel2 = [[SSTabViewModel alloc] initWithTabView:_tabView2];
    [_tabViewModel2 setTabs:@[[self createSection2WithIndex:@0],
                              [self createSection2WithIndex:@1],
                              [self createSection2WithIndex:@2]]];
    
    [_tabViewModel2 insertNewItem:[self createItem2WithIndex:@0] atIndex:0 fromLeft:YES animated:NO];
    [_tabViewModel2 insertNewItem:[self createItem2WithIndex:@1] atIndex:1 fromLeft:YES animated:NO];
    [_tabViewModel2 insertNewItem:[self createItem2WithIndex:@2] atIndex:0 fromLeft:NO animated:NO];
    
    _tabViewModel3 = [[SSTabViewModel alloc] initWithTabView:_tabView3];
    [_tabViewModel3 setTabs:@[[self createSection3WithIndex:@0],
                              [self createSection3WithIndex:@1],
                              [self createSection3WithIndex:@2]]];
    
    _tabViewModel4 = [[SSTabViewModel alloc] initWithTabView:_tabView4];
    _tabViewModel4.useEdgeInsetsForSections = YES;
    [_tabViewModel4 setTabs:@[[self createSection4WithIndex:@0],
                        [self createSection4WithIndex:@1],
                        [self createSection4WithIndex:@2]]];
    
    _tabViewModel5 = [[SSTabViewModel alloc] initWithTabView:_tabView5];
    _tabViewModel5.customClassForSection = NSStringFromClass([SSTestSectionButton class]);
    [_tabViewModel5 setTabs:@[[self createSection5WithIndex:@0],
                            [self createSection5WithIndex:@1],
                            [self createSection5WithIndex:@2]]];
    
    self.dataSources = @[
                         _tabViewModel1,
                         _tabViewModel2,
                         _tabViewModel3,
                         _tabViewModel4,
                         _tabViewModel5
                         ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark - Create tab view

- (UIView *)createTabViewWithTitle:(NSString *)title
{
    UIView *tabView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    tabView.backgroundColor = [UIColor colorWithRed:(arc4random() / (float)RAND_MAX) green:(arc4random() / (float)RAND_MAX) blue:(arc4random() / (float)RAND_MAX) alpha:1];
    UILabel *label = [[UILabel alloc] initWithFrame:tabView.bounds];
    label.text = title;
    label.font = [UIFont boldSystemFontOfSize:32];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
    label.shadowOffset = CGSizeMake(1, 1);
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label.textAlignment = NSTextAlignmentCenter;
    [tabView addSubview:label];
    return tabView;
}

#pragma mark - NavigationStrip 1

- (SSTabView *)createTabView1WithFrame:(CGRect)rect
{
    SSNavigationStripView *navagationStripView = [self createNavigationStripView1WithFrame:CGRectMake(0, 0, 128, 32)];
    return [[SSTabView alloc] initWithFrame:rect navigationMenu:navagationStripView];
}

- (SSNavigationStripView *)createNavigationStripView1WithFrame:(CGRect)rect
{
    SSNavigationStripView *stripView = [[SSNavigationStripView alloc] initWithFrame:rect];
    
    stripView.backgroundColor = [UIColor blackColor];
    stripView.layer.shadowOffset = CGSizeMake(0, 4);
    stripView.layer.shadowColor = [UIColor blackColor].CGColor;
    stripView.layer.shadowRadius = 4;
    stripView.layer.shadowOpacity = 0.8;
    stripView.clipsToBounds = NO;
    
    UIImage *img = [UIImage imageNamed:@"NavigationStripHeaderBackground"];
    img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(img.size.height/2, img.size.width/2, img.size.height/2, img.size.width/2)];
    
    stripView.backgroundImage = img;
    stripView.emptySpaceHolderImage = img;
    
    [stripView.leftNavigationButton setBackgroundImage:img forState:UIControlStateNormal];
    [stripView.leftNavigationButton setBackgroundImage:img forState:UIControlStateDisabled];
    [stripView.leftNavigationButton setImage:[UIImage imageNamed:@"NavigationStripLeftSideButton"] forState:UIControlStateNormal];
    [stripView.leftNavigationButton setImage:[UIImage imageNamed:@"NavigationStripLeftSideButton-Selected"] forState:UIControlStateHighlighted];
    [stripView.leftNavigationButton setImage:[UIImage imageNamed:@"NavigationStripLeftSideButton-Selected"] forState:UIControlStateDisabled];
    
    [stripView.rightNavigationButton setBackgroundImage:img forState:UIControlStateNormal];
    [stripView.rightNavigationButton setBackgroundImage:img forState:UIControlStateDisabled];
    [stripView.rightNavigationButton setImage:[UIImage imageNamed:@"NavigationStripRightSideButton"] forState:UIControlStateNormal];
    [stripView.rightNavigationButton setImage:[UIImage imageNamed:@"NavigationStripRightSideButton-Selected"] forState:UIControlStateHighlighted];
    [stripView.rightNavigationButton setImage:[UIImage imageNamed:@"NavigationStripRightSideButton-Selected"] forState:UIControlStateDisabled];
    
    return stripView;
}

- (SSTabViewSection *)createSection1WithIndex:(NSNumber *)index
{
    SSTabViewSection *section = [[SSTabViewSection alloc] init];
    section.title = [NSString stringWithFormat:@"Section %@",index];
    section.selectedTitle = section.title;
    section.icon = [UIImage imageNamed: @"NavigationStripIcon"];
    section.selectedIcon = [UIImage imageNamed: @"NavigationStripIcon-Selected"];
    section.font = [UIFont systemFontOfSize:15];
    section.selectedFont = [UIFont boldSystemFontOfSize:15];
    section.color = [UIColor colorWithWhite:0.3f alpha:1];
    section.selectedColor = [UIColor colorWithWhite:0.6f alpha:1];
    UIImage *img = [UIImage imageNamed:@"NavigationStripHeaderBackground"];
    img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(img.size.height/2, img.size.width/2, img.size.height/2, img.size.width/2)];
    section.backgroundImage = img;
    section.selectedBackgroundImage = img;
    
    // Create tab view
    section.tabContent = [self createTabViewWithTitle:[NSString stringWithFormat:@"Tab %@",index]];
    return section;
}

- (SSTabViewItem *)createItem1WithIndex:(NSNumber *)index
{
    SSTabViewItem *item = [[SSTabViewItem alloc] init];
    item.icon = [UIImage imageNamed: @"NavigationStripItem"];
    item.selectedIcon = [UIImage imageNamed: @"NavigationStripItem-Selected"];
    item.font = [UIFont systemFontOfSize:15];
    item.selectedFont = [UIFont boldSystemFontOfSize:15];
    item.color = [UIColor colorWithWhite:0.3f alpha:1];
    item.selectedColor = [UIColor colorWithWhite:0.6f alpha:1];
    UIImage *img = [UIImage imageNamed:@"NavigationStripHeaderBackground"];
    img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(img.size.height/2, img.size.width/2, img.size.height/2, img.size.width/2)];
    item.backgroundImage = img;
    item.selectedBackgroundImage = img;
    return item;
}

#pragma mark - NavigationStrip 2

- (SSTabView *)createTabView2WithFrame:(CGRect)rect
{
    SSNavigationStripView *navagationStripView = [self createNavigationStripView2WithFrame:CGRectMake(0, 0, 128, 32)];
    navagationStripView.sectionsAligment = UIViewContentModeLeft;
    navagationStripView.autohideNavigationButtons = NO;
    SSTabView *tabView = [[SSTabView alloc] initWithFrame:rect navigationMenu:navagationStripView];
    tabView.navigationMenuEdgeInsets = UIEdgeInsetsMake(10, 10, 0, 10);
    return tabView;
}

- (SSNavigationStripView *)createNavigationStripView2WithFrame:(CGRect)rect
{
    SSNavigationStripView *stripView = [[SSNavigationStripView alloc] initWithFrame:rect];
    
    stripView.backgroundColor = [UIColor blackColor];
    stripView.layer.cornerRadius = rect.size.height/2;
    stripView.clipsToBounds = YES;
    stripView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.75f];
    
    [stripView.leftNavigationButton setImage:[UIImage imageNamed:@"NavigationStripLeftSideButton"] forState:UIControlStateNormal];
    [stripView.leftNavigationButton setImage:[UIImage imageNamed:@"NavigationStripLeftSideButton-Selected"] forState:UIControlStateHighlighted];
    [stripView.leftNavigationButton setImage:[UIImage imageNamed:@"NavigationStripLeftSideButton-Selected"] forState:UIControlStateDisabled];
    
    [stripView.rightNavigationButton setImage:[UIImage imageNamed:@"NavigationStripRightSideButton"] forState:UIControlStateNormal];
    [stripView.rightNavigationButton setImage:[UIImage imageNamed:@"NavigationStripRightSideButton-Selected"] forState:UIControlStateHighlighted];
    [stripView.rightNavigationButton setImage:[UIImage imageNamed:@"NavigationStripRightSideButton-Selected"] forState:UIControlStateDisabled];
    
    return stripView;
}

- (SSTabViewSection *)createSection2WithIndex:(NSNumber *)index
{
    SSTabViewSection *section = [[SSTabViewSection alloc] init];
    section.title = [NSString stringWithFormat:@"Section %@",index];
    section.selectedTitle = section.title;
    section.font = [UIFont boldSystemFontOfSize:15];
    section.selectedFont = [UIFont boldSystemFontOfSize:15];
    section.color = [UIColor colorWithWhite:0.3f alpha:1];
    section.selectedColor = [UIColor colorWithWhite:1.0f alpha:1];
    
    // Create tab view
    section.tabContent = [self createTabViewWithTitle:[NSString stringWithFormat:@"Tab %@",index]];
    return section;
}

- (SSNavigationStripItem *)createItem2WithIndex:(NSNumber *)index
{
    SSNavigationStripItem *item = [[SSNavigationStripItem alloc] init];
    item.icon = [UIImage imageNamed: @"NavigationStripItem"];
    item.selectedIcon = [UIImage imageNamed: @"NavigationStripItem-Selected"];
    item.font = [UIFont systemFontOfSize:15];
    item.selectedFont = [UIFont systemFontOfSize:15];
    item.color = [UIColor colorWithWhite:0.3f alpha:1];
    item.selectedColor = [UIColor colorWithWhite:0.6f alpha:1];
    return item;
}

#pragma mark - NavigationStrip 3

- (SSTabView *)createTabView3WithFrame:(CGRect)rect
{
    SSNavigationStripView *navagationStripView = [self createNavigationStripView3WithFrame:CGRectMake(0, 0, 128, 32)];
    return [[SSTabView alloc] initWithFrame:rect navigationMenu:navagationStripView];
}

- (SSNavigationStripView *)createNavigationStripView3WithFrame:(CGRect)rect
{
    SSNavigationStripView *stripView = [[SSNavigationStripView alloc] initWithFrame:rect];
    
    stripView.backgroundColor = [UIColor blackColor];
    
    [stripView.leftNavigationButton setImage:[UIImage imageNamed:@"NavigationStripLeftSideButtonBlue"] forState:UIControlStateNormal];
    [stripView.leftNavigationButton setImage:[UIImage imageNamed:@"NavigationStripLeftSideButtonGrey"] forState:UIControlStateDisabled];
    
    [stripView.rightNavigationButton setImage:[UIImage imageNamed:@"NavigationStripRightSideButtonBlue"] forState:UIControlStateNormal];
    [stripView.rightNavigationButton setImage:[UIImage imageNamed:@"NavigationStripRightSideButtonGrey"] forState:UIControlStateDisabled];
    
    return stripView;
}

- (SSTabViewSection *)createSection3WithIndex:(NSNumber *)index
{
    SSTabViewSection *section = [[SSTabViewSection alloc] init];
    section.title = [NSString stringWithFormat:@"Section %@",index];
    section.selectedTitle = [NSString stringWithFormat:@"Section %@ SEL",index];
    section.icon = [UIImage imageNamed: @"NavigationStripIcon"];
    section.selectedIcon = [UIImage imageNamed: @"NavigationStripIcon-Selected"];
    section.font = [UIFont italicSystemFontOfSize:15];
    section.selectedFont = [UIFont italicSystemFontOfSize:15];
    section.color = [UIColor colorWithWhite:0.3f alpha:1];
    section.selectedColor = [UIColor colorWithWhite:0.6f alpha:1];
    UIImage *img = [UIImage imageNamed:@"NavigationStripSectionBackground"];
    section.backgroundImage = [img resizableImageWithCapInsets:UIEdgeInsetsMake(img.size.height/2, img.size.width/2, img.size.height/2, img.size.width/2)];
    img = [UIImage imageNamed:@"NavigationStripSectionBackground-Selected"];
    section.selectedBackgroundImage = [img resizableImageWithCapInsets:UIEdgeInsetsMake(img.size.height/2, img.size.width/2, img.size.height/2, img.size.width/2)];

    
    // Create tab view
    section.tabContent = [self createTabViewWithTitle:[NSString stringWithFormat:@"Tab %@",index]];
    return section;
}

#pragma mark - NavigationStrip 4

- (SSTabView *)createTabView4WithFrame:(CGRect)rect
{
    SSNavigationStripView *navagationStripView = [self createNavigationStripView4WithFrame:CGRectMake(0, 0, 128, 32)];
    return [[SSTabView alloc] initWithFrame:rect navigationMenu:navagationStripView];
}

- (SSNavigationStripView *)createNavigationStripView4WithFrame:(CGRect)rect
{
    SSNavigationStripView *stripView = [[SSNavigationStripView alloc] initWithFrame:rect];
    
    UIImage *img = [UIImage imageNamed:@"NavigationStripHeaderBackground_2"];
    
    stripView.backgroundImage = [img resizableImageWithCapInsets:UIEdgeInsetsMake(img.size.height/2, img.size.width/2, img.size.height/2, img.size.width/2)];
    
    [stripView.leftNavigationButton setImage:[UIImage imageNamed:@"NavigationStripLeftSideButton"] forState:UIControlStateNormal];
    [stripView.leftNavigationButton setImage:[UIImage imageNamed:@"NavigationStripLeftSideButton-Selected"] forState:UIControlStateHighlighted];
    [stripView.leftNavigationButton setImage:[UIImage imageNamed:@"NavigationStripLeftSideButton-Selected"] forState:UIControlStateDisabled];
    
    [stripView.rightNavigationButton setImage:[UIImage imageNamed:@"NavigationStripRightSideButton"] forState:UIControlStateNormal];
    [stripView.rightNavigationButton setImage:[UIImage imageNamed:@"NavigationStripRightSideButton-Selected"] forState:UIControlStateHighlighted];
    [stripView.rightNavigationButton setImage:[UIImage imageNamed:@"NavigationStripRightSideButton-Selected"] forState:UIControlStateDisabled];
    
    return stripView;
}

- (SSTabViewSection *)createSection4WithIndex:(NSNumber *)index
{
    SSTabViewSection *section = [[SSTabViewSection alloc] init];
    section.title = [NSString stringWithFormat:@"Section %@",index];
    section.selectedTitle = section.title;
    section.font = [UIFont systemFontOfSize:15];
    section.selectedFont = [UIFont boldSystemFontOfSize:15];
    section.color = [UIColor grayColor];
    section.selectedColor = [UIColor grayColor];
    UIImage *img = [UIImage imageNamed:@"NavigationStripSectionBackground_2"];
    section.backgroundImage = [img resizableImageWithCapInsets:UIEdgeInsetsMake(img.size.height/2, img.size.width/2, img.size.height/2, img.size.width/2)];
    img = [UIImage imageNamed:@"NavigationStripSectionBackground_2-Selected"];
    section.selectedBackgroundImage = [img resizableImageWithCapInsets:UIEdgeInsetsMake(img.size.height/2, img.size.width/2, img.size.height/2, img.size.width/2)];
    
    // Create tab view
    section.tabContent = [self createTabViewWithTitle:[NSString stringWithFormat:@"Tab %@",index]];
    return section;
}

#pragma mark - NavigationStrip 5

const CGFloat kArrowHeight = 4;

- (SSTabView *)createTabView5WithFrame:(CGRect)rect
{
    SSNavigationStripView *navagationStripView = [self createNavigationStripView5WithFrame:CGRectMake(0, 0, 128, 32)];
    SSTabView *tabView = [[SSTabView alloc] initWithFrame:rect navigationMenu:navagationStripView];
    tabView.navigationMenuEdgeInsets = UIEdgeInsetsMake(-kArrowHeight, 0, 0, 0);
    tabView.contentViewEdgeInsets = UIEdgeInsetsMake(navagationStripView.frame.size.height - 2 * kArrowHeight, 0, 0, 0);
    return tabView;
}

- (SSNavigationStripView *)createNavigationStripView5WithFrame:(CGRect)rect
{
    SSNavigationStripView *stripView = [[SSNavigationStripView alloc] initWithFrame:rect];
    
    CGFloat arrowHeight = kArrowHeight;
    UIGraphicsBeginImageContext(CGSizeMake(rect.size.height, rect.size.height));
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    [arrowPath moveToPoint:CGPointMake(0, arrowHeight)];
    [arrowPath addLineToPoint:CGPointMake(rect.size.width, arrowHeight)];
    [arrowPath addLineToPoint:CGPointMake(rect.size.width, rect.size.height - arrowHeight)];
    [arrowPath addLineToPoint:CGPointMake(0, rect.size.height - arrowHeight)];
    CGContextSetFillColorWithColor(currentContext, [UIColor blackColor].CGColor);
    CGContextAddPath(currentContext, [arrowPath CGPath]);
    CGContextDrawPath(currentContext, kCGPathFill);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    stripView.backgroundImage = [img resizableImageWithCapInsets:UIEdgeInsetsMake(img.size.height/2, img.size.width/2, img.size.height/2, img.size.width/2)];
    
    [stripView.leftNavigationButton setImage:[UIImage imageNamed:@"NavigationStripLeftSideButton"] forState:UIControlStateNormal];
    [stripView.leftNavigationButton setImage:[UIImage imageNamed:@"NavigationStripLeftSideButton-Selected"] forState:UIControlStateHighlighted];
    [stripView.leftNavigationButton setImage:[UIImage imageNamed:@"NavigationStripLeftSideButton-Selected"] forState:UIControlStateDisabled];
    
    [stripView.rightNavigationButton setImage:[UIImage imageNamed:@"NavigationStripRightSideButton"] forState:UIControlStateNormal];
    [stripView.rightNavigationButton setImage:[UIImage imageNamed:@"NavigationStripRightSideButton-Selected"] forState:UIControlStateHighlighted];
    [stripView.rightNavigationButton setImage:[UIImage imageNamed:@"NavigationStripRightSideButton-Selected"] forState:UIControlStateDisabled];
    
    return stripView;
}

- (SSTabViewSection *)createSection5WithIndex:(NSNumber *)index
{
    SSTabViewSection *section = [[SSTabViewSection alloc] init];
    section.title = [NSString stringWithFormat:@"Section %@",index];
    section.selectedTitle = [NSString stringWithFormat:@"Section SELECTED %@",index]; //section.title;
    section.font = [UIFont systemFontOfSize:12];
    section.selectedFont = [UIFont systemFontOfSize:12];
    section.color = [UIColor lightGrayColor];
    section.selectedColor = [UIColor whiteColor];
    section.backgroundColor = [UIColor blackColor];
    section.selectedBackgroundColor = [UIColor blackColor];
    
    // Create tab view
    section.tabContent = [self createTabViewWithTitle:[NSString stringWithFormat:@"Tab %@",index]];
    return section;
}

#pragma mark - SSTabViewDelegate

- (void)tabView:(SSTabView *)tabView menuItemAtIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide didChangeState:(BOOL)selected
{
    VerboseLog(@"index = %d leftSide = %@ selected = %@",index,@(leftSide),@(selected));
}

- (void)tabView:(SSTabView *)tabView willSelectSectionAtIndex:(NSInteger)index
{
    VerboseLog(@"index = %d",index);
}

- (void)tabView:(SSTabView *)tabView didSelectSectionAtIndex:(NSInteger)index
{
    VerboseLog(@"index = %d",index);
}

- (void)tabView:(SSTabView *)tabView didScrollTo:(CGFloat)normScrollOffset
{
    VerboseLog(@"normScrollOffset = %f",normScrollOffset);
}

#pragma mark - Actions

- (IBAction)numberOfTabsValueChanged
{
    int count = [_tabViewModel1 numberOfSections];
    int index = (count ? arc4random() % count : 0);
    if(self.numberOfTabs.value > count) // increase
    {
        SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING(
        [self.dataSources enumerateObjectsUsingBlock:^(SSTabViewModel *dataSource, NSUInteger idx, BOOL *stop) {
            SSTabViewSection *section = [self performSelector:NSSelectorFromString([NSString stringWithFormat:@"createSection%dWithIndex:",idx + 1]) withObject:@(index)];
            [dataSource insertNewTab:section atIndex:index animated:YES];
        }];
                                               );
    }
    else //decrease
    {
        [self.dataSources enumerateObjectsUsingBlock:^(SSTabViewModel *dataSource, NSUInteger idx, BOOL *stop) {
            [dataSource removeTabAtIndex:index animated:YES];
        }];
    }
}

- (IBAction)sectionAligmentValueChanged
{
    [self.dataSources enumerateObjectsUsingBlock:^(SSTabViewModel *dataSource, NSUInteger idx, BOOL *stop) {
        dataSource.tabView.navigationMenu.sectionsAligment = (self.sectionAligment.selectedSegmentIndex == 1 ? UIViewContentModeCenter :
                                      (self.sectionAligment.selectedSegmentIndex == 0 ? UIViewContentModeLeft : UIViewContentModeRight));
        [dataSource.tabView reloadData];
    }];
}


@end
