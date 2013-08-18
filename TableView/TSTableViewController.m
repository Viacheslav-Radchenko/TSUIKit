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
    TSTableView *_tableView2;
    TSTableViewModel *_model1;
    TSTableViewModel *_model2;
}

@end

@implementation TSTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSArray *columns = @[
                              @{ @"title" : @"Column 1", @"subtitle" : @"This is first column"},
                              @{ @"title" : @"Column 2", @"color" : @"FF1F3F1F"},
                              @{ @"title" : @"Column", @"subcolumns" : @[
                                         @{ @"title" : @"Column 3"},
                                         @{ @"title" : @"Column 4", @"subcolumns" : @[
                                                    @{ @"title" : @"Column 4.1",
                                                       @"titleFontSize" : @"10",
                                                       @"headerHeight" : @24,
                                                       @"defWidth" : @64,
                                                       @"titleColor" : @"FF9F0000"},
                                                    @{ @"title" : @"Column 4.2",
                                                       @"titleFontSize" : @"10",
                                                       @"headerHeight" : @24,
                                                       @"defWidth" : @64,
                                                       @"titleColor" : @"FF009F00"},
                                                    @{ @"title" : @"Column 4.3",
                                                       @"headerHeight" : @24,
                                                       @"defWidth" : @64,
                                                       @"titleFontSize" : @"10",
                                                       @"titleColor" : @"FF0000CF"}
                                                    ]
                                            }
                                         ]
                                 },
                              @{ @"title" : @"Column 5", @"subtitle" : @"This is last column with icon", @"icon" : @"NavigationStripIcon.png"},
     ];
    
    NSArray *columns1 = @[
                         @{ @"title" : @"Column 1", @"subtitle" : @"This is first column"},
                         @{ @"title" : @"Column 2", @"color" : @"FFCFFFCF"},
                         @{ @"title" : @"Column", @"subcolumns" : @[
                                    @{ @"title" : @"Column 3"},
                                    @{ @"title" : @"Column 4", @"subcolumns" : @[
                                               @{ @"title" : @"Column 4.1",
                                                  @"titleFontSize" : @"10",
                                                  @"headerHeight" : @24,
                                                  @"defWidth" : @64,
                                                  @"titleColor" : @"FFFF0000"},
                                               @{ @"title" : @"Column 4.2",
                                                  @"titleFontSize" : @"10",
                                                  @"headerHeight" : @24,
                                                  @"defWidth" : @64,
                                                  @"titleColor" : @"FF00FF00"},
                                               @{ @"title" : @"Column 4.3",
                                                  @"headerHeight" : @24,
                                                  @"defWidth" : @64,
                                                  @"titleFontSize" : @"10",
                                                  @"titleColor" : @"FF0000FF"}
                                               ]
                                       }
                                    ]
                            },
                         @{ @"title" : @"Column 5", @"subtitle" : @"This is last column with icon", @"icon" : @"NavigationStripIcon.png"},
                         ];

    NSArray *rows = @[
                      @{ @"cells" : @[
                                 @{ @"value" : @"Category 1"},
                                 @{ @"value" : @"Value 1"},
                                 @{ @"value" : @1},
                                 @{ @"value" : @1},
                                 @{ @"value" : @"?"},
                                 @{ @"value" : @1},
                                 @{ @"value" : @1}
                                 ]
                         },
                      @{ @"cells" : @[
                                 @{ @"value" :  @"Category 2"},
                                 @{ @"value" : @"Value 2"},
                                 @{ @"value" : @2},
                                 @{ @"value" : @2},
                                 @{ @"value" : @"?"},
                                 @{ @"value" : @2},
                                 @{ @"value" : @2}
                                 ],
                         @"subrows" : @[
                                 @{ @"cells" : @[
                                            @{ @"value" : [NSNull null]},
                                            @{ @"value" : @"Value 2"},
                                            @{ @"value" : @2},
                                            @{ @"value" : @2},
                                            @{ @"value" : @12},
                                            @{ @"value" : @4},
                                            @{ @"value" : @2}
                                            ],
                                    },
                                 @{ @"cells" : @[
                                            @{ @"value" : [NSNull null]},
                                            @{ @"value" : @"Value 2"},
                                            @{ @"value" : @2},
                                            @{ @"value" : @5},
                                            @{ @"value" : @12},
                                            @{ @"value" : @232},
                                            @{ @"value" : @2}
                                            ],
                                    @"subrows" : @[
                                            @{ @"cells" : @[
                                                       @{ @"value" : @""},
                                                       @{ @"value" : @"Value 2"},
                                                       @{ @"value" : @2},
                                                       @{ @"value" : @221},
                                                       @{ @"value" : @2},
                                                       @{ @"value" : @122},
                                                       @{ @"value" : @2}
                                                       ],
                                               },
                                            @{ @"cells" : @[
                                                       @{ @"value" : @""},
                                                       @{ @"value" : @"Value 2"},
                                                       @{ @"value" : @2},
                                                       @{ @"value" : @2},
                                                       @{ @"value" : @123},
                                                       @{ @"value" : @23},
                                                       @{ @"value" : @2}
                                                       ],
                                               },
                                            @{ @"cells" : @[
                                                       @{ @"value" : @""},
                                                       @{ @"value" : @"Value 2"},
                                                       @{ @"value" : @2},
                                                       @{ @"value" : @2},
                                                       @{ @"value" : @34},
                                                       @{ @"value" : @2345},
                                                       @{ @"value" : @72}
                                                       ],
                                               }
                                            ]
                                    },
                                 @{ @"cells" : @[
                                            @{ @"value" : [NSNull null]},
                                            @{ @"value" : @"Value 2"},
                                            @{ @"value" : @2},
                                            @{ @"value" : @42},
                                            @{ @"value" : @123},
                                            @{ @"value" : @2},
                                            @{ @"value" : @12}
                                            ],
                                    @"subrows" : @[
                                            @{ @"cells" : @[
                                                       @{ @"value" : @""},
                                                       @{ @"value" : @"Value 2"},
                                                       @{ @"value" : @2},
                                                       @{ @"value" : @2},
                                                       @{ @"value" : @1},
                                                       @{ @"value" : @1},
                                                       @{ @"value" : @28}
                                                       ],
                                               },
                                            @{ @"cells" : @[
                                                       @{ @"value" : @""},
                                                       @{ @"value" : @"Value 2"},
                                                       @{ @"value" : @2},
                                                       @{ @"value" : @18},
                                                       @{ @"value" : @27},
                                                       @{ @"value" : @999},
                                                       @{ @"value" : @25}
                                                       ],
                                               },
                                            @{ @"cells" : @[
                                                       @{ @"value" : @""},
                                                       @{ @"value" : @"Value 2"},
                                                       @{ @"value" : @2},
                                                       @{ @"value" : @1},
                                                       @{ @"value" : @27},
                                                       @{ @"value" : @87},
                                                       @{ @"value" : @5}
                                                       ],
                                               }
                                            ]
                                    }
                                 ]
                         },
                      @{ @"cells" : @[
                                 @{ @"value" : @"Category 3"},
                                 @{ @"value" : @"Value 2"},
                                 @{ @"value" : @2},
                                 @{ @"value" : @2},
                                 @{ @"value" : @12},
                                 @{ @"value" : @12},
                                 @{ @"value" : @62}
                                 ]
                         },
    ];
    
    
    /***Second set of data****************/
    
    NSArray *columns2 = @[
                          @{ @"title" : @"Column 1", @"subtitle" : @"This is first column", @"headerHeight" : @48},
                          @{ @"title" : @"Column 2", @"subtitle" : @"This is second column"},
                          @{ @"title" : @"Column 3", @"subtitle" : @"This is third column"}
                          ];
    
    NSArray *rows2 = @[
                       @{ @"cells" : @[
                                  @{ @"value" : @"Value 1"},
                                  @{ @"value" : @123},
                                  @{ @"value" : @4431}
                                ]
                          },
                       @{ @"cells" : @[
                                  @{ @"value" : @"Value 2"},
                                  @{ @"value" : @122},
                                  @{ @"value" : @2431}
                                  ]
                          },
                       @{ @"cells" : @[
                                  @{ @"value" : @"Value 3"},
                                  @{ @"value" : @123},
                                  @{ @"value" : @4431}
                                  ]
                          },
                       @{ @"cells" : @[
                                  @{ @"value" : @"Value 4"},
                                  @{ @"value" : @123},
                                  @{ @"value" : @4431}
                                  ]
                          },
                       @{ @"cells" : @[
                                  @{ @"value" : @"Value 5"},
                                  @{ @"value" : @123},
                                  @{ @"value" : @4431}
                                  ]
                          },
                       @{ @"cells" : @[
                                  @{ @"value" : @"Value 6"},
                                  @{ @"value" : @123},
                                  @{ @"value" : @4431}
                                  ]
                          },
                       @{ @"cells" : @[
                                  @{ @"value" : @"Value 7"},
                                  @{ @"value" : @123},
                                  @{ @"value" : @4431}
                                  ]
                          },
                       @{ @"cells" : @[
                                  @{ @"value" : @"Value 8"},
                                  @{ @"value" : @123},
                                  @{ @"value" : @4431}
                                  ]
                          },
                       @{ @"cells" : @[
                                  @{ @"value" : @"Value 9"},
                                  @{ @"value" : @123},
                                  @{ @"value" : @4431}
                                  ]
                          },
                       @{ @"cells" : @[
                                  @{ @"value" : @"Value 10"},
                                  @{ @"value" : @123},
                                  @{ @"value" : @4431}
                                  ]
                          },
                       @{ @"cells" : @[
                                  @{ @"value" : @"Value 11"},
                                  @{ @"value" : @123},
                                  @{ @"value" : @4431}
                                  ]
                          },
                       @{ @"cells" : @[
                                  @{ @"value" : @"Value 12"},
                                  @{ @"value" : @123},
                                  @{ @"value" : @4431}
                                  ]
                          },
                       @{ @"cells" : @[
                                  @{ @"value" : @"Value 1"},
                                  @{ @"value" : @123},
                                  @{ @"value" : @4431}
                                  ]
                          },
                       @{ @"cells" : @[
                                  @{ @"value" : @"Value 2"},
                                  @{ @"value" : @122},
                                  @{ @"value" : @2431}
                                  ]
                          },
                       @{ @"cells" : @[
                                  @{ @"value" : @"Value 3"},
                                  @{ @"value" : @123},
                                  @{ @"value" : @4431}
                                  ]
                          },
                       @{ @"cells" : @[
                                  @{ @"value" : @"Value 4"},
                                  @{ @"value" : @123},
                                  @{ @"value" : @4431}
                                  ]
                          },
                       @{ @"cells" : @[
                                  @{ @"value" : @"Value 5"},
                                  @{ @"value" : @123},
                                  @{ @"value" : @4431}
                                  ]
                          },
                       @{ @"cells" : @[
                                  @{ @"value" : @"Value 6"},
                                  @{ @"value" : @123},
                                  @{ @"value" : @4431}
                                  ]
                          },
                       @{ @"cells" : @[
                                  @{ @"value" : @"Value 7"},
                                  @{ @"value" : @123},
                                  @{ @"value" : @4431}
                                  ]
                          },
                       @{ @"cells" : @[
                                  @{ @"value" : @"Value 8"},
                                  @{ @"value" : @123},
                                  @{ @"value" : @4431}
                                  ]
                          },
                       @{ @"cells" : @[
                                  @{ @"value" : @"Value 9"},
                                  @{ @"value" : @123},
                                  @{ @"value" : @4431}
                                  ]
                          },
                       @{ @"cells" : @[
                                  @{ @"value" : @"Value 10"},
                                  @{ @"value" : @123},
                                  @{ @"value" : @4431}
                                  ]
                          },
                       @{ @"cells" : @[
                                  @{ @"value" : @"Value 11"},
                                  @{ @"value" : @123},
                                  @{ @"value" : @4431}
                                  ]
                          },
                       @{ @"cells" : @[
                                  @{ @"value" : @"Value 12"},
                                  @{ @"value" : @123},
                                  @{ @"value" : @4431}
                                  ]
                          },
                       ];
    
    /*************************************/
    
    
    _tableView1 = [[TSTableView alloc] initWithFrame:CGRectMake(20, 20, self.view.frame.size.width - 40, self.view.frame.size.height/2 - 30)];
    _tableView1.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_tableView1];
    
    _model1 = [[TSTableViewModel alloc] initWithTableView:_tableView1 andStyle:TSTableViewStyleDark];
    [_model1 setColumnsInfo:columns andRowsInfo:rows];
    
    _tableView2 = [[TSTableView alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height/2 + 10, self.view.frame.size.width - 40, self.view.frame.size.height/2 - 30)];
    _tableView2.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_tableView2];
    
    _model2 = [[TSTableViewModel alloc] initWithTableView:_tableView2 andStyle:TSTableViewStyleLight];
    [_model2 setColumnsInfo:columns1 andRowsInfo:rows];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
