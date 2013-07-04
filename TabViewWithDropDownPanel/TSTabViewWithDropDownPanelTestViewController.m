//
//  TSTabViewWithDropDownPanelTestViewController.m
//  TabViewWithDropDownPanel
//
//  Created by Viacheslav Radchenko on 7/2/13.
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

#import "TSTabViewWithDropDownPanelTestViewController.h"
#import "TSTabViewWithDropDownPanel.h"
#import "TSTabViewWithDropDownPanelModel.h"
#import "TSDefines.h"

#import <QuartzCore/QuartzCore.h>

@interface TSTabViewWithDropDownPanelTestViewController () <TSTabViewWithDropDownPanelDelegate, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate>
{
    TSTabViewWithDropDownPanel *_tabView1;
    TSTabViewWithDropDownPanel *_tabView2;
    TSTabViewWithDropDownPanel *_tabView3;
    TSTabViewWithDropDownPanelModel *_tabViewModel1;
    TSTabViewWithDropDownPanelModel *_tabViewModel2;
    TSTabViewWithDropDownPanelModel *_tabViewModel3;
}

@property (nonatomic, strong) NSArray *dataSources;
@property (nonatomic, strong) NSArray *tabViews;

@end

@implementation TSTabViewWithDropDownPanelTestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _tabView1 = [self createTabView1WithFrame:CGRectMake(20, (IS_IPAD ? 20 : 20), self.view.frame.size.width - 40, (IS_IPAD ? 240 : 120))];
    _tabView1.backgroundColor = [UIColor grayColor];
    _tabView1.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _tabView1.delegate = self;
    _tabView1.attachedPanel = [self createDropDownMenu];
    [self.view addSubview:_tabView1];
    
    _tabView2 = [self createTabView2WithFrame:CGRectMake(20, (IS_IPAD ? 280 : 140), self.view.frame.size.width - 40, (IS_IPAD ? 240 : 120))];
    _tabView2.backgroundColor = [UIColor grayColor];
    _tabView2.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _tabView2.delegate = self;
    _tabView2.attachedPanel = [self createDropDownMenu2];
    [self.view addSubview:_tabView2];
    
    _tabView3 = [self createTabView3WithFrame:CGRectMake(20, (IS_IPAD ? 540 : 280), self.view.frame.size.width - 40, (IS_IPAD ? 240 : 120))];
    _tabView3.backgroundColor = [UIColor grayColor];
    _tabView3.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _tabView3.delegate = self;
    _tabView3.showPanelBelowNavigationMenu = NO;
    _tabView3.attachedPanel = [self createDropDownMenu3];
    [self.view addSubview:_tabView3];
    
    _tabViewModel1 = [[TSTabViewWithDropDownPanelModel alloc] initWithTabView:_tabView1];
    [_tabViewModel1 setTabs:@[[self createSection1WithIndex:@0],
                [self createSection1WithIndex:@1],
                [self createSection1WithIndex:@2]]];
    
    [_tabViewModel1 setItems:@[[self createItem1WithIndex:@0]] fromLeft:YES];

    
    _tabViewModel2 = [[TSTabViewWithDropDownPanelModel alloc] initWithTabView:_tabView2];
    [_tabViewModel2 setTabs:@[[self createSection2WithIndex:@0],
                             [self createSection2WithIndex:@1],
                             [self createSection2WithIndex:@2]]];
    [_tabViewModel2 insertNewItem:[self createItem2WithIndex:@0] atIndex:0 fromLeft:YES animated:NO];
    
    _tabViewModel3 = [[TSTabViewWithDropDownPanelModel alloc] initWithTabView:_tabView3];
    _tabViewModel3.useEdgeInsetsForSections = YES;
    [_tabViewModel3 setTabs:@[[self createSection3WithIndex:@0],
                             [self createSection3WithIndex:@1],
                             [self createSection3WithIndex:@2]]];
    [_tabViewModel3 insertNewItem:[self createItem2WithIndex:@0] atIndex:0 fromLeft:YES animated:NO];
    
    self.dataSources = @[
                         _tabViewModel1,
                         _tabViewModel2,
                         _tabViewModel3
                         ];
    self.tabViews = @[
                         _tabView1,
                         _tabView2,
                         _tabView3
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

- (UIView *)createTabWithTitle:(NSString *)title
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
    

    // Add gesture for drop down menu
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandler:)];
    gesture.delegate = self;
    [tabView addGestureRecognizer:gesture];
    return tabView;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint translation = [panGestureRecognizer translationInView:panGestureRecognizer.view];
    return fabs(translation.y) > fabs(translation.x);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return YES;
}

#pragma mark - Gesture Handler for TabView1 & TabView2

- (void)panGestureHandler:(UIGestureRecognizer *)gesture
{
    CGPoint pos = [gesture locationInView:self.view];
    
    TSTabViewWithDropDownPanel *tabViewInFocus;
    for (TSTabViewWithDropDownPanel *tabView in self.tabViews)
    {
        if(CGRectContainsPoint(tabView.frame,pos))
        {
            tabViewInFocus = tabView;
            break;
        }
    }
    
    if(tabViewInFocus)
    {
        static CGPoint lastPos;
        pos = [gesture locationInView:tabViewInFocus];
        CGFloat delta = pos.y - lastPos.y;
        if(gesture.state == UIGestureRecognizerStateBegan)
        {
            lastPos = [gesture locationInView:tabViewInFocus];
        }
        else if(gesture.state == UIGestureRecognizerStateChanged)
        {
            [tabViewInFocus movePanel:delta finished:NO];
        }
        else
        {
            [tabViewInFocus movePanel:delta finished:YES];
        }
        lastPos = pos;
    }
}

#pragma mark - TabView 1

- (TSTabViewWithDropDownPanel *)createTabView1WithFrame:(CGRect)rect
{
    TSNavigationStripView *navagationStripView = [self createNavigationStripView1WithFrame:CGRectMake(0, 0, 128, 32)];
    return [[TSTabViewWithDropDownPanel alloc] initWithFrame:rect navigationMenu:navagationStripView];
}

- (TSNavigationStripView *)createNavigationStripView1WithFrame:(CGRect)rect
{
    TSNavigationStripView *stripView = [[TSNavigationStripView alloc] initWithFrame:rect];
    
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

- (TSTabViewSection *)createSection1WithIndex:(NSNumber *)index
{
    TSTabViewSection *section = [[TSTabViewSection alloc] init];
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
    section.tabContent = [self createTabWithTitle:[NSString stringWithFormat:@"Tab %@",index]];
    return section;
}

- (TSTabViewItem *)createItem1WithIndex:(NSNumber *)index
{
    TSTabViewItem *item = [[TSTabViewItem alloc] init];
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

- (UIView *)createDropDownMenu
{
    UIView *tabView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    tabView.backgroundColor = [UIColor clearColor];
    tabView.layer.shadowOffset = CGSizeMake(0, 4);
    tabView.layer.shadowColor = [UIColor blackColor].CGColor;
    tabView.layer.shadowRadius = 4;
    tabView.layer.shadowOpacity = 0.8;
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tabView.frame.size.width, tabView.frame.size.height)];
    UIImage *img = [UIImage imageNamed:@"NavigationStripHeaderBackground"];
    img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(img.size.height/2, img.size.width/2, img.size.height/2, img.size.width/2)];
    imgView.image = img;
    imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [tabView addSubview:imgView];
    UILabel *label = [[UILabel alloc] initWithFrame:tabView.bounds];
    label.text = @"Menu";
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

#pragma mark - TabView 2

- (TSTabViewWithDropDownPanel *)createTabView2WithFrame:(CGRect)rect
{
    TSNavigationStripView *navagationStripView = [self createNavigationStripView2WithFrame:CGRectMake(0, 0, 128, 32)];
    TSTabViewWithDropDownPanel *tabView = [[TSTabViewWithDropDownPanel alloc] initWithFrame:rect navigationMenu:navagationStripView];
    tabView.navigationMenuEdgeInsets = UIEdgeInsetsMake(10, 10, 0, 10);
    return tabView;
}

- (TSNavigationStripView *)createNavigationStripView2WithFrame:(CGRect)rect
{
    TSNavigationStripView *stripView = [[TSNavigationStripView alloc] initWithFrame:rect];
    
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

- (TSTabViewSection *)createSection2WithIndex:(NSNumber *)index
{
    TSTabViewSection *section = [[TSTabViewSection alloc] init];
    section.title = [NSString stringWithFormat:@"Section %@",index];
    section.selectedTitle = section.title;
    section.font = [UIFont boldSystemFontOfSize:15];
    section.selectedFont = [UIFont boldSystemFontOfSize:15];
    section.color = [UIColor colorWithWhite:0.3f alpha:1];
    section.selectedColor = [UIColor colorWithWhite:1.0f alpha:1];
    
    // Create tab view
    section.tabContent = [self createTabWithTitle:[NSString stringWithFormat:@"Tab %@",index]];
    return section;
}

- (TSNavigationStripItem *)createItem2WithIndex:(NSNumber *)index
{
    TSNavigationStripItem *item = [[TSNavigationStripItem alloc] init];
    item.icon = [UIImage imageNamed: @"NavigationStripItem"];
    item.selectedIcon = [UIImage imageNamed: @"NavigationStripItem-Selected"];
    item.font = [UIFont systemFontOfSize:15];
    item.selectedFont = [UIFont systemFontOfSize:15];
    item.color = [UIColor colorWithWhite:0.3f alpha:1];
    item.selectedColor = [UIColor colorWithWhite:0.6f alpha:1];
    return item;
}

- (UIView *)createDropDownMenu2
{
    UIView *tabView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    tabView.backgroundColor = [UIColor clearColor];
    
    CGSize size = tabView.bounds.size;
    CGFloat cornerRadius = 16;
    UIGraphicsBeginImageContext(size);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    [arrowPath moveToPoint:CGPointMake(0, 0)];
    [arrowPath addLineToPoint:CGPointMake(size.width, 0)];
    [arrowPath addArcWithCenter:CGPointMake(size.width, cornerRadius) radius:cornerRadius startAngle:M_PI_2 endAngle:M_PI clockwise:NO];
    [arrowPath addLineToPoint:CGPointMake(size.width - cornerRadius, size.height - cornerRadius)];
    [arrowPath addArcWithCenter:CGPointMake(size.width - 2*cornerRadius, size.height - cornerRadius) radius:cornerRadius startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [arrowPath addLineToPoint:CGPointMake(2*cornerRadius, size.height)];
    [arrowPath addArcWithCenter:CGPointMake(2*cornerRadius, size.height - cornerRadius) radius:cornerRadius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    [arrowPath addLineToPoint:CGPointMake(cornerRadius, cornerRadius)];
    [arrowPath addArcWithCenter:CGPointMake(0, cornerRadius) radius:cornerRadius startAngle:0 endAngle:M_PI_2 clockwise:NO];
    CGContextSetFillColorWithColor(currentContext, [UIColor colorWithWhite:0.0 alpha:0.75f].CGColor);
    CGContextAddPath(currentContext, [arrowPath CGPath]);
    CGContextDrawPath(currentContext, kCGPathFill);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(img.size.height/2, img.size.width/2, img.size.height/2, img.size.width/2)];

    UIImageView *subView = [[UIImageView alloc] initWithFrame:CGRectInset(tabView.bounds, 20, 0)];
    subView.image = img;
    subView.clipsToBounds = YES;
    subView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [tabView addSubview:subView];
 
    UILabel *label = [[UILabel alloc] initWithFrame:tabView.bounds];
    label.text = @"Menu";
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

#pragma mark - TabView 3

- (TSTabViewWithDropDownPanel *)createTabView3WithFrame:(CGRect)rect
{
    TSNavigationStripView *navagationStripView = [self createNavigationStripView3WithFrame:CGRectMake(0, 0, 128, 32)];
    return [[TSTabViewWithDropDownPanel alloc] initWithFrame:rect navigationMenu:navagationStripView];
}

- (TSNavigationStripView *)createNavigationStripView3WithFrame:(CGRect)rect
{
    TSNavigationStripView *stripView = [[TSNavigationStripView alloc] initWithFrame:rect];
    
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

- (UIView *)createDropDownMenu3
{
    UIView *tabView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    tabView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1];

    UILabel *label = [[UILabel alloc] initWithFrame:tabView.bounds];
    label.text = @"Menu";
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

- (UITableView *)createTableView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(slideGestureHandler:)];
    gesture.delegate = self;
    [tableView addGestureRecognizer:gesture];
    return tableView;
}

- (TSTabViewSection *)createSection3WithIndex:(NSNumber *)index
{
    TSTabViewSection *section = [[TSTabViewSection alloc] init];
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
    section.tabContent = [self createTableView];
    return section;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *kCell = @"kCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCell];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"Row %d",indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  20;
}

#pragma mark - UIPanGestureRecognizer for TabView 3

- (void)slideGestureHandler:(UIPanGestureRecognizer *)gesture
{
    UITableView *tableView = (UITableView *)gesture.view;
    
    static CGPoint lastPos;
    CGPoint pos = [gesture locationInView:_tabView3];
    CGFloat delta = pos.y - lastPos.y;
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        lastPos = [gesture locationInView:_tabView3];
    }
    else if(gesture.state == UIGestureRecognizerStateChanged)
    {
        if((delta > 0 && tableView.contentOffset.y <= 0) ||
           ( delta < 0))
        {
            [_tabView3 movePanel:delta finished:NO];
        }
    }
    else
    {
        [_tabView3 movePanel:-delta finished:YES];
    }
    lastPos = pos;
}

#pragma mark - TSTabViewDelegate

- (void)tabView:(TSTabView *)tabView menuItemAtIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide didChangeState:(BOOL)selected
{
    VerboseLog(@"index = %d leftSide = %@ selected = %@",index,@(leftSide),@(selected));
    TSTabViewWithDropDownPanel *tabViewWithPanel = (TSTabViewWithDropDownPanel *)tabView;
    if(selected)
    {
        [tabViewWithPanel showDropDownPanelWithAnimation:YES];
    }
    else
    {
        [tabViewWithPanel hideDropDownPanelWithAnimation:YES];
    }
}

- (void)tabView:(TSTabView *)tabView willSelectSectionAtIndex:(NSInteger)index
{
    VerboseLog(@"index = %d",index);
}

- (void)tabView:(TSTabView *)tabView didSelectSectionAtIndex:(NSInteger)index
{
    VerboseLog(@"index = %d",index);
}

- (void)tabView:(TSTabView *)tabView didScrollTo:(CGFloat)normScrollOffset
{
    VerboseLog(@"normScrollOffset = %f",normScrollOffset);
}

- (void)tabViewWithDropDownPanel:(TSTabViewWithDropDownPanel *)tabView willShowPanel:(UIView *)panel animated:(BOOL)animated
{
    VerboseLog();
    [tabView.navigationMenu selectItemAtIndex:0 fromLeftSide:YES];
}

- (void)tabViewWithDropDownPanel:(TSTabViewWithDropDownPanel *)tabView didShowPanel:(UIView *)panel
{
    VerboseLog();
}

- (void)tabViewWithDropDownPanel:(TSTabViewWithDropDownPanel *)tabView willHidePanel:(UIView *)panel animated:(BOOL)animated
{
    VerboseLog();
}

- (void)tabViewWithDropDownPanel:(TSTabViewWithDropDownPanel *)tabView didHidePanel:(UIView *)panel
{
    VerboseLog();
    [tabView.navigationMenu deselectItemAtIndex:0 fromLeftSide:YES];
}

@end
