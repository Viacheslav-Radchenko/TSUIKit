TSUIKit
=======

Set of extended UI components for iOS.

## TSTableView

`TSTableView` is UI component for displaying multi columns tabular data with support of hierarchical rows and columns structure.
It provides smooth animations for item selection and dynamic content modification. Some features are listed below:

* Suport muti columns data structure.
* Support hierarchical column definition (i.e. column may have subsections).
* Support hierarchical row definition (i.e. row may have expand subrows).
* Optimized to display big sets of data: row and cell views are cached internally and reused during scrolling.
* Support row and column selection.
* Allow modification of column width by sliding column border.
* Allow expand/collapse subrows content.
* Support simple declarative syntax for columns and rows content definition.
* Providing your own implementation of TSTableViewDataSource protocol will allow you fully customise structure and appearance of the table.
* Default TSTableViewModel implements TSTableViewDataSource protocol and includes two built in styles (see screenshots).
            
<img src="https://raw.github.com/Viacheslav-Radchenko/TSUIKit/master/Screenshots/TSTableView_SCreenshot1.png" alt="TSTableView examples" width="360" height="480" />
<img src="https://raw.github.com/Viacheslav-Radchenko/TSUIKit/master/Screenshots/TSTableView_Screenshot4.png" alt="TSTableView examples" width="360" height="480" />

Example of TSTableView object instantiation provided below. See more complex examples in project.
```
    NSArray *columns = @[
                         @{ @"title" : @"Column 1", @"subtitle" : @"This is first column"},
                         @{ @"title" : @"Column 2", @"subcolumns" : @[
                                    @{ @"title" : @"Column 2.1", @"headerHeight" : @20},
                                    @{ @"title" : @"Column 2.2", @"headerHeight" : @20}]},
                         @{ @"title" : @"Column 3", @"titleColor" : @"FF00CF00"}
                         ];

    NSArray *rows = @[
                      @{ @"cells" : @[
                                 @{ @"value" : @"Value 1"},
                                 @{ @"value" : @1},
                                 @{ @"value" : @2},
                                 @{ @"value" : @3}
                                 ]
                         },
                      @{ @"cells" : @[
                                 @{ @"value" : @"Value 2"},
                                 @{ @"value" : @2},
                                 @{ @"value" : @3},
                                 @{ @"value" : @4}
                                 ]
                         }
                      ];

    TSTableView *tableView = [[TSTableView alloc] initWithFrame:self.view.bounds];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    
    TSTableViewModel  *dataModel = [[TSTableViewModel alloc] initWithTableView:tableView andStyle:kTSTableViewStyleDark];
    [dataModel setColumns:columns andRows:rows];

```

## TSNavigationStripView

`TSNavigationStripView` is a navigation menu control with highly customizable design and flexible structure.
It provides smooth animations for item selection and dynamic content modification. Some features are listed below:

* Display set of section titles (tabs).
* Select section (tab) from list.
* Scroll between sections (tabs).
* Left and right navigation buttons on sides.
* Fully customized appearance (see examples).
* Support different types of layout and alignment: alignment to left side, alignment to right side, autofill available space, central alignment (which imitate behaviour of ViewPager component on Android).
* Additinal not scrolled menu items can be added on left and right sides.
            
<img src="https://raw.github.com/Viacheslav-Radchenko/TSUIKit/master/Screenshots/TSNavigationStripView_Screenshot1.jpg" alt="TSNavigationStripView examples" width="360" height="480" />
<img src="https://raw.github.com/Viacheslav-Radchenko/TSUIKit/master/Screenshots/TSNavigationStripView_Screenshot2.jpg" alt="TSNavigationStripView examples" width="360" height="480" />

## TSTabView

`TSTabView` UI component that allows to flip left and right through pages of data. Pages content provided to TSTabView by implementing TSTabViewDataSource protocol. TSTabView can manage set of UIView or UIViewController objects. TSNavigationStripView control is used to display available pages titles/tabs and navigate between them.
 Custom TSNavigationStripView entity should be provided to TSTabView during initialisation. Some features are listed below:

* Navigates through set of UIView or UIViewController objects.
* Support far jumps between pages.
* Tabs list in TSNavigationStripView support different types of layout and alignment, including: alignment to left side, alignment to right side, autofill available space, central alignment (which imitate behaviour of ViewPager component on Android).
* Tabs list in TSNavigationStripView can be scrollable.
* TSNavigationStripView can display additional menu items on left or right sides.
* TSNavigationStripView provide great flexibility for appearance  customisation.
* All view transitions are done with smooth animations.

<img src="https://raw.github.com/Viacheslav-Radchenko/TSUIKit/master/Screenshots/TSTabView_Screenshot1.jpg" alt="TSTabView examples" width="360" height="480" />
<img src="https://raw.github.com/Viacheslav-Radchenko/SSUIKit/master/Screenshots/TSTabView_Screenshot2.jpg" alt="TSTabView examples" width="360" height="480" />

Example of TSTabView object instantiation provided below.
```
TSNavigationStripView *navigationStripView = [[TSNavigationStripView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 32)];
// Customize navigation view appearance...

TSTabView *tabView = [[TSTabView alloc] initWithFrame:self.view.bounds navigationMenu:navigationStripView];
tabView.delegate = self;
[self.view addSubview: tabView];

TSTabViewModel *tabViewModel = [[TSTabViewModel alloc] initWithTabView:tabView];
[tabViewModel setTabs:@[
	[[TSTabViewSection alloc] initWithTitle:@"Tab 1" andView: /* Provide view */],
	[[TSTabViewSection alloc] initWithTitle:@"Tab 2" andView: /* Provide view */]]
];
```

## TSTabViewWithDropDownPanel

`TSTabViewWithDropDownPanel` extends `TSTabView`. Custom view can be attached to drop down panel which pull down/up on top of tabs container.

<img src="https://raw.github.com/Viacheslav-Radchenko/TSUIKit/master/Screenshots/TSTabViewWithDropDownPanel_Screenshot1.jpg" alt="TSTabViewWithDropDownPanel examples" width="360" height="480" />

## Requirements

* Xcode 4.5 or higher
* Apple LLVM compiler
* iOS 5.0 or higher
* ARC
* QuartzCore.framework

## Demo

Build and run the `TSUIKit` project in Xcode to see examples of each component.
Right now better way to see components functionality is to compile examples provided with project, they fully display structure and dynamics of controls, as well as possible use cases.

* Demo video [TSTableView](http://youtu.be/Zd2CGbj0yUU).
* Demo video [TSTabView](http://youtu.be/GvTfKJM43uQ).

## Installation

The easiest way to integrate TSUIKit is using CocoaPods. Just add this to your Podfile:
```
	pod 'TSUIKit', '~> 0.1' 
```

Other option is to drop `TSUIKit` source files into your project and add corresponding `#include "*.h"` to the top of classes that will use particular component.
`TS*Models` are optional part of `TSUIKit` infrastructure. They provide ready-to-use examples of corresponding data source implementations. You may use them or implement your own data sources.
`TSUIKit` use `QuartzCore.framework`, so you might need to add it as well.

## Contact

Viacheslav Radchenko

- https://github.com/Viacheslav-Radchenko
- radchencko.v.i@gmail.com

## License

TSUKit is available under the MIT license.

Copyright © 2013 Viacheslav Radchenko.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
