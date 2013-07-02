//
//  TSNavigationStripTestViewController.m
//  NavigationStripTest
//
//  Created by Viacheslav Radchenko on 4/20/13.
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
#import "TSNavigationStripTestViewController.h"
#import "TSNavigationStripView.h"
#import "TSNavigationStripModel.h"
#import "TSDefines.h"
#import "TSTestSectionButton.h"

@interface TSNavigationStripTestViewController () <TSNavigationStripViewDelegate>
{
    TSNavigationStripModel *_dataSource1;
    TSNavigationStripModel *_dataSource2;
    TSNavigationStripModel *_dataSource3;
    TSNavigationStripModel *_dataSource4;
    TSNavigationStripModel *_dataSource5;
    TSNavigationStripModel *_dataSource6;
    TSNavigationStripView *_navagationStripView1;
    TSNavigationStripView *_navagationStripView2;
    TSNavigationStripView *_navagationStripView3;
    TSNavigationStripView *_navagationStripView4;
    TSNavigationStripView *_navagationStripView5;
    TSNavigationStripView *_navagationStripView6;
}

@property (nonatomic, strong) NSArray *navigationStrips;
@property (nonatomic, strong) NSArray *dataSources;

@end

@implementation TSNavigationStripTestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.settingsView.layer.cornerRadius = 4;
    self.settingsView.layer.shadowOpacity = 0.5;
    self.settingsView.layer.shadowOffset = CGSizeMake(2, 4);
    
	// Do any additional setup after loading the view, typically from a nib.
    _navagationStripView1 = [self createNavigationStripView1WithFrame:CGRectMake(20, (IS_IPAD ? 220 : 110), self.view.frame.size.width - 40, 32)];
    _navagationStripView1.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _navagationStripView1.delegate = self;
    [self.view addSubview:_navagationStripView1];
    
    _navagationStripView2 = [self createNavigationStripView2WithFrame:CGRectMake(20, (IS_IPAD ? 320 : 150), self.view.frame.size.width - 40, 32)];
    _navagationStripView2.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _navagationStripView2.delegate = self;
    [self.view addSubview:_navagationStripView2];
    
    _navagationStripView3 = [self createNavigationStripView3WithFrame:CGRectMake(20, (IS_IPAD ? 420 : 190), self.view.frame.size.width - 40, 32)];
    _navagationStripView3.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _navagationStripView3.delegate = self;
    [self.view addSubview:_navagationStripView3];
    
    _navagationStripView4 = [self createNavigationStripView4WithFrame:CGRectMake(20, (IS_IPAD ? 520 : 230), self.view.frame.size.width - 40, 32)];
    _navagationStripView4.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _navagationStripView4.delegate = self;
    [self.view addSubview:_navagationStripView4];
    
    _navagationStripView5 = [self createNavigationStripView5WithFrame:CGRectMake(20, (IS_IPAD ? 620 : 270), self.view.frame.size.width - 40, 32)];
    _navagationStripView5.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _navagationStripView5.delegate = self;
    [self.view addSubview:_navagationStripView5];
    
    _navagationStripView6 = [self createNavigationStripView6WithFrame:CGRectMake(20, (IS_IPAD ? 720 : 310), self.view.frame.size.width - 40, 32)];
    _navagationStripView6.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _navagationStripView6.delegate = self;
    [self.view addSubview:_navagationStripView6];
    
    _dataSource1 = [[TSNavigationStripModel alloc] initWithNavigationStrip:_navagationStripView1];
    _dataSource2 = [[TSNavigationStripModel alloc] initWithNavigationStrip:_navagationStripView2];
    _dataSource3 = [[TSNavigationStripModel alloc] initWithNavigationStrip:_navagationStripView3];
    _dataSource4 = [[TSNavigationStripModel alloc] initWithNavigationStrip:_navagationStripView4];
    _dataSource4.useEdgeInsetsForSections = YES;
    _dataSource5 = [[TSNavigationStripModel alloc] initWithNavigationStrip:_navagationStripView5];
    _dataSource5.customClassForSection = NSStringFromClass([TSTestSectionButton class]);
    _dataSource6 = [[TSNavigationStripModel alloc] initWithNavigationStrip:_navagationStripView6];
    
    self.navigationStrips = @[
        _navagationStripView1,
        _navagationStripView2,
        _navagationStripView3,
        _navagationStripView4,
        _navagationStripView5,
        _navagationStripView6
    ];
    
    self.dataSources = @[
        _dataSource1,
        _dataSource2,
        _dataSource3,
        _dataSource4,
        _dataSource5,
        _dataSource6
    ];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark - Actions

- (IBAction)navigationButtonsAutohideValueChanged
{
    [self.navigationStrips enumerateObjectsUsingBlock:^(TSNavigationStripView *stripView, NSUInteger idx, BOOL *stop) {
        stripView.autohideNavigationButtons = self.navigationButtonsAutohide.isOn;
        [stripView reloadData];
    }];
}

- (IBAction)sectionsScrollEnabledValueChanged
{
    [self.navigationStrips enumerateObjectsUsingBlock:^(TSNavigationStripView *stripView, NSUInteger idx, BOOL *stop) {
        stripView.navigationButtonsHidden = self.sectionsScrollEnabled.isOn;
        [stripView reloadData];
    }];
}

- (IBAction)debugModeValueChanged
{
    [self.navigationStrips enumerateObjectsUsingBlock:^(TSNavigationStripView *stripView, NSUInteger idx, BOOL *stop) {
        stripView.debugMode = self.debugMode.isOn;
    }];
}

- (IBAction)maskSectionsViewValueChanged
{
    [self.navigationStrips enumerateObjectsUsingBlock:^(TSNavigationStripView *stripView, NSUInteger idx, BOOL *stop) {
        stripView.maskSectionsContainerEdges = self.maskSectionsView.isOn;
    }];
}

- (IBAction)numberOfLeftItemsValueChanged
{
    int count = [_dataSource1 numberOfItemsFromLeftSide:YES];
    int index = (count ? arc4random() % count : 0);
    if(self.numberOfLeftItems.value > count) // increase
    {
        SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING(
        [self.dataSources enumerateObjectsUsingBlock:^(TSNavigationStripModel *dataSource, NSUInteger idx, BOOL *stop) {
            TSNavigationStripItem *item = [self performSelector:NSSelectorFromString([NSString stringWithFormat:@"createItem%dWithIndex:",idx + 1]) withObject:@(index)];
            [dataSource insertNewItem:item atIndex:index fromLeft:YES animated:YES];
        }];
                                               );
    }
    else //decrease
    {
        [self.dataSources enumerateObjectsUsingBlock:^(TSNavigationStripModel *dataSource, NSUInteger idx, BOOL *stop) {
            [dataSource removeItemAtIndex:index fromLeft:YES animated:YES];
        }];
    }
}

- (IBAction)numberOfSectionsValueChanged
{
    int count = [_dataSource1 numberOfSections];
    int index = (count ? arc4random() % count : 0);
    if(self.numberOfSections.value > count) // increase
    {
        SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING(
        [self.dataSources enumerateObjectsUsingBlock:^(TSNavigationStripModel *dataSource, NSUInteger idx, BOOL *stop) {
            TSNavigationStripSection *section = [self performSelector:NSSelectorFromString([NSString stringWithFormat:@"createSection%dWithIndex:",idx + 1]) withObject:@(index)];
            [dataSource insertNewSection:section atIndex:index animated:YES];
        }];
                                               );
    }
    else //decrease
    {
        [self.dataSources enumerateObjectsUsingBlock:^(TSNavigationStripModel *dataSource, NSUInteger idx, BOOL *stop) {
            [dataSource removeSectionAtIndex:index animated:YES];
        }];
    }
}

- (IBAction)numberOfRightItemsValueChanged
{
    int count = [_dataSource1 numberOfItemsFromLeftSide:NO];
    int index = (count ? arc4random() % count : 0);
    if(self.numberOfRightItems.value > count) // increase
    {
        SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING(
        [self.dataSources enumerateObjectsUsingBlock:^(TSNavigationStripModel *dataSource, NSUInteger idx, BOOL *stop) {
            TSNavigationStripItem *item = [self performSelector:NSSelectorFromString([NSString stringWithFormat:@"createItem%dWithIndex:",idx + 1]) withObject:@(index)];
            [dataSource insertNewItem:item atIndex:index fromLeft:NO animated:YES];
        }];
                                               );
    }
    else //decrease
    {
        [self.dataSources enumerateObjectsUsingBlock:^(TSNavigationStripModel *dataSource, NSUInteger idx, BOOL *stop) {
            [dataSource removeItemAtIndex:index fromLeft:NO animated:YES];
        }];
    }
}

- (IBAction)sectionAligmentValueChanged
{
    [self.navigationStrips enumerateObjectsUsingBlock:^(TSNavigationStripView *stripView, NSUInteger idx, BOOL *stop) {
        
        switch (self.sectionAligment.selectedSegmentIndex)
        {
            case 0: stripView.sectionsAligment = UIViewContentModeLeft; break;
            case 1: stripView.sectionsAligment = UIViewContentModeCenter; break;
            case 2: stripView.sectionsAligment = UIViewContentModeRight; break;
            case 3: stripView.sectionsAligment = UIViewContentModeScaleAspectFill; break;
            default: break;
        }
        [stripView reloadSectionsData];
    }];
}

#pragma mark - NavigationStrip 1

- (TSNavigationStripView *)createNavigationStripView1WithFrame:(CGRect)rect
{
    TSNavigationStripView *stripView = [[TSNavigationStripView alloc] initWithFrame:rect];
    
    stripView.backgroundColor = [UIColor blackColor];
    stripView.layer.shadowOffset = CGSizeMake(0, 4);
    stripView.layer.shadowColor = [UIColor blackColor].CGColor;
    stripView.layer.shadowRadius = 4;
    stripView.layer.shadowOpacity = 0.8;
    stripView.clipsToBounds = NO;
    
    UIImage *img = [UIImage imageNamed:@"NavigationStripHeaderBackground_1"];
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

- (TSNavigationStripSection *)createSection1WithIndex:(NSNumber *)index
{
    TSNavigationStripSection *section = [[TSNavigationStripSection alloc] init];
    section.title = [NSString stringWithFormat:@"Section %@",index];
    section.selectedTitle = section.title;
    section.icon = [UIImage imageNamed: @"NavigationStripIcon"];
    section.selectedIcon = [UIImage imageNamed: @"NavigationStripIcon-Selected"];
    section.font = [UIFont systemFontOfSize:15];
    section.selectedFont = [UIFont boldSystemFontOfSize:15];
    section.color = [UIColor colorWithWhite:0.3f alpha:1];
    section.selectedColor = [UIColor colorWithWhite:0.6f alpha:1];
    UIImage *img = [UIImage imageNamed:@"NavigationStripHeaderBackground_1"];
    img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(img.size.height/2, img.size.width/2, img.size.height/2, img.size.width/2)];
    section.backgroundImage = img;
    section.selectedBackgroundImage = img;
    return section;
}

- (TSNavigationStripItem *)createItem1WithIndex:(NSNumber *)index
{
    TSNavigationStripItem *item = [[TSNavigationStripItem alloc] init];
    item.icon = [UIImage imageNamed: @"NavigationStripItem"];
    item.selectedIcon = [UIImage imageNamed: @"NavigationStripItem-Selected"];
    item.font = [UIFont systemFontOfSize:15];
    item.selectedFont = [UIFont boldSystemFontOfSize:15];
    item.color = [UIColor colorWithWhite:0.3f alpha:1];
    item.selectedColor = [UIColor colorWithWhite:0.6f alpha:1];
    UIImage *img = [UIImage imageNamed:@"NavigationStripHeaderBackground_1"];
    img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(img.size.height/2, img.size.width/2, img.size.height/2, img.size.width/2)];
    item.backgroundImage = img;
    item.selectedBackgroundImage = img;
    return item;
}

#pragma mark - NavigationStrip 2

- (TSNavigationStripView *)createNavigationStripView2WithFrame:(CGRect)rect
{
    TSNavigationStripView *stripView = [[TSNavigationStripView alloc] initWithFrame:rect];
    
    stripView.backgroundColor = [UIColor blackColor];
    stripView.layer.cornerRadius = rect.size.height/2;
    stripView.clipsToBounds = YES;
    stripView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5f];
    
    [stripView.leftNavigationButton setImage:[UIImage imageNamed:@"NavigationStripLeftSideButton"] forState:UIControlStateNormal];
    [stripView.leftNavigationButton setImage:[UIImage imageNamed:@"NavigationStripLeftSideButton-Selected"] forState:UIControlStateHighlighted];
    [stripView.leftNavigationButton setImage:[UIImage imageNamed:@"NavigationStripLeftSideButton-Selected"] forState:UIControlStateDisabled];
    
    [stripView.rightNavigationButton setImage:[UIImage imageNamed:@"NavigationStripRightSideButton"] forState:UIControlStateNormal];
    [stripView.rightNavigationButton setImage:[UIImage imageNamed:@"NavigationStripRightSideButton-Selected"] forState:UIControlStateHighlighted];
    [stripView.rightNavigationButton setImage:[UIImage imageNamed:@"NavigationStripRightSideButton-Selected"] forState:UIControlStateDisabled];
    
    return stripView;
}

- (TSNavigationStripSection *)createSection2WithIndex:(NSNumber *)index
{
    TSNavigationStripSection *section = [[TSNavigationStripSection alloc] init];
    section.title = [NSString stringWithFormat:@"Section %@",index];
    section.selectedTitle = section.title;
    section.icon = [UIImage imageNamed: @"NavigationStripIcon"];
    section.selectedIcon = [UIImage imageNamed: @"NavigationStripIcon-Selected"];
    section.font = [UIFont systemFontOfSize:15];
    section.selectedFont = [UIFont boldSystemFontOfSize:15];
    section.color = [UIColor colorWithWhite:0.3f alpha:1];
    section.selectedColor = [UIColor colorWithWhite:0.6f alpha:1];
    return section;
}

- (TSNavigationStripItem *)createItem2WithIndex:(NSNumber *)index
{
    TSNavigationStripItem *item = [[TSNavigationStripItem alloc] init];
    item.title = @"Item";
    item.selectedTitle = @"Item!";
    item.icon = [UIImage imageNamed: @"NavigationStripItem"];
    item.selectedIcon = [UIImage imageNamed: @"NavigationStripItem-Selected"];
    item.font = [UIFont systemFontOfSize:15];
    item.selectedFont = [UIFont systemFontOfSize:15];
    item.color = [UIColor colorWithWhite:0.3f alpha:1];
    item.selectedColor = [UIColor colorWithWhite:0.6f alpha:1];
    return item;
}

#pragma mark - NavigationStrip 3

- (TSNavigationStripView *)createNavigationStripView3WithFrame:(CGRect)rect
{
    TSNavigationStripView *stripView = [[TSNavigationStripView alloc] initWithFrame:rect];
    stripView.clipsToBounds = NO;
    stripView.backgroundColor = [UIColor blackColor];
    
    [stripView.leftNavigationButton setImage:[UIImage imageNamed:@"NavigationStripLeftSideButtonBlue"] forState:UIControlStateNormal];
    [stripView.leftNavigationButton setImage:[UIImage imageNamed:@"NavigationStripLeftSideButtonGrey"] forState:UIControlStateDisabled];
    
    [stripView.rightNavigationButton setImage:[UIImage imageNamed:@"NavigationStripRightSideButtonBlue"] forState:UIControlStateNormal];
    [stripView.rightNavigationButton setImage:[UIImage imageNamed:@"NavigationStripRightSideButtonGrey"] forState:UIControlStateDisabled];
    
    return stripView;
}

- (TSNavigationStripSection *)createSection3WithIndex:(NSNumber *)index
{
    TSNavigationStripSection *section = [[TSNavigationStripSection alloc] init];
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
    return section;
}

- (TSNavigationStripItem *)createItem3WithIndex:(NSNumber *)index
{
    TSNavigationStripItem *item = [[TSNavigationStripItem alloc] init];
    item.icon = [UIImage imageNamed: @"NavigationStripItemGrey"];
    item.selectedIcon = [UIImage imageNamed: @"NavigationStripItemBlue"];
    item.color = [UIColor colorWithWhite:0.3f alpha:1];
    item.selectedColor = [UIColor colorWithWhite:0.6f alpha:1];
    return item;
}

#pragma mark - NavigationStrip 4

- (TSNavigationStripView *)createNavigationStripView4WithFrame:(CGRect)rect
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

- (TSNavigationStripSection *)createSection4WithIndex:(NSNumber *)index
{
    TSNavigationStripSection *section = [[TSNavigationStripSection alloc] init];
    section.title = [NSString stringWithFormat:@"Section %@",index];
    section.selectedTitle = [NSString stringWithFormat:@"Section SELECTED %@",index]; //section.title;
    section.font = [UIFont systemFontOfSize:15];
    section.selectedFont = [UIFont boldSystemFontOfSize:15];
    section.color = [UIColor grayColor];
    section.selectedColor = [UIColor grayColor];
    UIImage *img = [UIImage imageNamed:@"NavigationStripSectionBackground_2"];
    section.backgroundImage = [img resizableImageWithCapInsets:UIEdgeInsetsMake(img.size.height/2, img.size.width/2, img.size.height/2, img.size.width/2)];
     img = [UIImage imageNamed:@"NavigationStripSectionBackground_2-Selected"];
     section.selectedBackgroundImage = [img resizableImageWithCapInsets:UIEdgeInsetsMake(img.size.height/2, img.size.width/2, img.size.height/2, img.size.width/2)];
    return section;
}

- (TSNavigationStripItem *)createItem4WithIndex:(NSNumber *)index
{
    TSNavigationStripItem *item = [[TSNavigationStripItem alloc] init];
    item.icon = [UIImage imageNamed: @"NavigationStripItem"];
    item.selectedIcon = [UIImage imageNamed: @"NavigationStripItem-Selected"];
    return item;
}

#pragma mark - NavigationStrip 5

- (TSNavigationStripView *)createNavigationStripView5WithFrame:(CGRect)rect
{
    TSNavigationStripView *stripView = [[TSNavigationStripView alloc] initWithFrame:rect];
   
    CGFloat arrowHeight = 4;
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

- (TSNavigationStripSection *)createSection5WithIndex:(NSNumber *)index
{
    TSNavigationStripSection *section = [[TSNavigationStripSection alloc] init];
    section.title = [NSString stringWithFormat:@"Section %@",index];
    section.selectedTitle = [NSString stringWithFormat:@"Section SELECTED %@",index];
    section.font = [UIFont systemFontOfSize:12];
    section.selectedFont = [UIFont systemFontOfSize:12];
    section.color = [UIColor lightGrayColor];
    section.selectedColor = [UIColor whiteColor];
    section.backgroundColor = [UIColor blackColor];
    section.selectedBackgroundColor = [UIColor blackColor];

    return section;
}

- (TSNavigationStripItem *)createItem5WithIndex:(NSNumber *)index
{
    TSNavigationStripItem *item = [[TSNavigationStripItem alloc] init];
    item.icon = [UIImage imageNamed: @"NavigationStripItem"];
    item.selectedIcon = [UIImage imageNamed: @"NavigationStripItem-Selected"];
    return item;
}

#pragma mark - NavigationStrip 6

- (TSNavigationStripView *)createNavigationStripView6WithFrame:(CGRect)rect
{
    TSNavigationStripView *stripView = [[TSNavigationStripView alloc] initWithFrame:rect];
    
    CGFloat arrowHeight = 4;
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
    
    
    TSTestSectionButton *marker = [[TSTestSectionButton alloc] initWithFrame:CGRectMake(0, 0, rect.size.height, rect.size.height)];
    marker.selected = YES;
    marker.backgroundColor = [UIColor redColor];
    stripView.selectionMarker = marker;
    
    return stripView;
}

- (TSNavigationStripSection *)createSection6WithIndex:(NSNumber *)index
{
    TSNavigationStripSection *section = [[TSNavigationStripSection alloc] init];
    section.title = [NSString stringWithFormat:@"Section %@",index];
    section.selectedTitle = section.title;
    section.font = [UIFont systemFontOfSize:12];
    section.selectedFont = [UIFont systemFontOfSize:12];
    section.color = [UIColor lightGrayColor];
    section.selectedColor = [UIColor whiteColor];
    section.backgroundColor = [UIColor clearColor];
    section.selectedBackgroundColor = [UIColor clearColor];
    
    return section;
}

- (TSNavigationStripItem *)createItem6WithIndex:(NSNumber *)index
{
    TSNavigationStripItem *item = [[TSNavigationStripItem alloc] init];
    item.icon = [UIImage imageNamed: @"NavigationStripItem"];
    item.selectedIcon = [UIImage imageNamed: @"NavigationStripItem-Selected"];
    return item;
}

#pragma mark - TSNavigationStripViewDelegate

- (void)navigationStrip:(TSNavigationStripView *)navigationStripView itemAtIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide didChangeState:(BOOL)selected
{
    VerboseLog(@"index = %d leftSide = %@ selected = %@",index,@(leftSide),@(selected));
}

- (void)navigationStrip:(TSNavigationStripView *)navigationStripView willSelectSectionAtIndex:(NSInteger)index
{
    VerboseLog(@"index = %d",index);
}

- (void)navigationStrip:(TSNavigationStripView *)navigationStripView didSelectSectionAtIndex:(NSInteger)index
{
    VerboseLog(@"index = %d",index);
//    Invoke callback on selection changed
//    TSNavigationStripModel *model =  (TSNavigationStripModel *)navigationStripView.dataSource;
//    TSNavigationStripSection *sectionInfo = model.sections[index];
//    sectionInfo.selectionHandler();
//    [sectionInfo.target perfromSelector:sectionInfo.action];
}

- (void)navigationStrip:(TSNavigationStripView *)navigationStripView didScrollTo:(CGFloat)normScrollOffset
{
    VerboseLog(@"normScrollOffset = %f",normScrollOffset);
}

@end