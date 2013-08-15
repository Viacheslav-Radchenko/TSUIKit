//
//  TSTableViewController.m
//  TableView
//
//  Created by Viacheslav Radchenko on 8/15/13.
//  Copyright (c) 2013 Viacheslav Radchenko. All rights reserved.
//

#import "TSTableViewController.h"
#import "TSTableViewModel.h"

@interface TSTableViewController ()
{
    TSTableView *_tableView1;
    TSTableViewModel *_model1;
}

@end

@implementation TSTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _tableView1 = [[TSTableView alloc] initWithFrame:CGRectMake(20, 20, self.view.frame.size.width - 40, self.view.frame.size.height - 40)];
    _tableView1.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_tableView1];
    
    _model1 = [[TSTableViewModel alloc] initWithTableView:_tableView1];
    [_model1 setColumnsInfo:@[
             @{ @"title" : @"Column 1"},
             @{ @"title" : @"Column 2"},
             @{ @"title" : @"Column", @"subcolumns" : @[
                                                            @{ @"title" : @"Column 3"},
                                                            @{ @"title" : @"Column 4", @"subcolumns" : @[
                                                                                         @{ @"title" : @"Column 4.1"},
                                                                                         @{ @"title" : @"Column 4.2"},
                                                                                         @{ @"title" : @"Column 4.3"}
                                                                                     ]
                                                            }
                                                        ]
              },
             @{ @"title" : @"Column 5"},
           ]
               andRowsInfo:@[
             @{ @"cells" : @[
                             @{ @"value" : @"Category 1"},
                             @{ @"value" : @"Value 1"},
                             @{ @"value" : @1},
                             @{ @"value" : @1},
                             @{ @"value" : @"Value 1"},
                             @{ @"value" : @1},
                             @{ @"value" : @1}
                            ]
             },
            @{ @"cells" : @[
                             @{ @"value" :  @"Category 2"},
                             @{ @"value" : @"Value 2"},
                             @{ @"value" : @2},
                             @{ @"value" : @2},
                             @{ @"value" : @"Value 2"},
                             @{ @"value" : @2},
                             @{ @"value" : @2}
                            ],
                @"subrows" : @[
                             @{ @"cells" : @[
                                     @{ @"value" : [NSNull null]},
                                     @{ @"value" : @"Value 2"},
                                     @{ @"value" : @2},
                                     @{ @"value" : @2},
                                     @{ @"value" : @"Value 2"},
                                     @{ @"value" : @2},
                                     @{ @"value" : @2}
                                     ],
                             },
                             @{ @"cells" : @[
                                     @{ @"value" : [NSNull null]},
                                     @{ @"value" : @"Value 2"},
                                     @{ @"value" : @2},
                                     @{ @"value" : @2},
                                     @{ @"value" : @"Value 2"},
                                     @{ @"value" : @2},
                                     @{ @"value" : @2}
                                     ],
                             },
                             @{ @"cells" : @[
                                     @{ @"value" : [NSNull null]},
                                     @{ @"value" : @"Value 2"},
                                     @{ @"value" : @2},
                                     @{ @"value" : @2},
                                     @{ @"value" : @"Value 2"},
                                     @{ @"value" : @2},
                                     @{ @"value" : @2}
                                     ],
                              }
                            ]
             },
             @{ @"cells" : @[
                             @{ @"value" : @"Category 3"},
                             @{ @"value" : @"Value 2"},
                             @{ @"value" : @2},
                             @{ @"value" : @2},
                             @{ @"value" : @"Value 2"},
                             @{ @"value" : @2},
                             @{ @"value" : @2}
                            ]
             },
        ]
     ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
