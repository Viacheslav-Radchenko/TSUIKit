//
//  TSTableViewModel.h
//  TSUIKit
//
//  Created by Viacheslav Radchenko on 8/14/13.
//  Copyright (c) 2013 Viacheslav Radchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSTableView.h"

/**
 *  @abstract
 */

@interface TSColumn : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *subcolumns;

+ (id)columnWithTitle:(NSString *)title;
+ (id)columnWithTitle:(NSString *)title andSubcolumns:(NSArray *)sublolumns;
+ (id)columnWithDictionary:(NSDictionary *)info;

- (id)initWithTitle:(NSString *)title;
- (id)initWithTitle:(NSString *)title andSubcolumns:(NSArray *)sublolumns;
- (id)initWithDictionary:(NSDictionary *)info;

@end

/**
 *  @abstract
 */

@interface TSRow : NSObject

@property (nonatomic, strong) NSArray *cells;
@property (nonatomic, strong) NSArray *subrows;

+ (id)rowWithCells:(NSArray *)cells;
+ (id)rowWithCells:(NSArray *)cells andSubrows:(NSArray *)subrows;
+ (id)rowWithDictionary:(NSDictionary *)info;
- (id)initWithCells:(NSArray *)cells;
- (id)initWithCells:(NSArray *)cells andSubrows:(NSArray *)subrows;
- (id)initWithDictionary:(NSDictionary *)info;

@end

/**
 *  @abstract
 */

@interface TSCell : NSObject

@property (nonatomic, strong) NSObject *value;

+ (id)cellWithValue:(NSObject *)value;
+ (id)cellWithDictionary:(NSDictionary *)info;
- (id)initWithValue:(NSObject *)value;
- (id)initWithDictionary:(NSDictionary *)info;

@end

/**
 *  @abstract
 */

@class TSTableView;

@interface TSTableViewModel : NSObject <TSTableViewDataSource>
{
    NSMutableArray *_columns;
    NSMutableArray *_rows;
    TSTableView *_tableView;
}

@property (nonatomic, strong, readonly) NSArray *columns;
@property (nonatomic, strong, readonly) NSArray *rows;
@property (nonatomic, strong, readonly) TSTableView *tableView;

- (id)initWithTableView:(TSTableView *)tableView;
- (void)setColumns:(NSArray *)columns andRows:(NSArray *)rows;
- (void)setColumnsInfo:(NSArray *)columns andRowsInfo:(NSArray *)rows;

@end



//TSTableViewModel *model = [[TSTableViewModel alloc] initWithTableView:tableView];
//[model setColumns:@[@"Column 1", @"Column 2", [TSColumn  columnWithTitle:@"Column" andSubcolumns:@[@"Column 3", @"Column 4"]]]
//          andRows:@[@[@"Category 1", @"Value 1", @1, @1],
//                     [TSRow rowWithCells:@[@"Category 2", @"Value 2", @2, @2] andSubrows:@[
//                          @[[NSNull null], @"Value 2", @2, @2],
//                          @[[NSNull null], @"Value 3", @3, @5],
//                          @[[NSNull null], @"Value 4", @4, @5]
//                      ]],
//                    @[@"Category 3", @"Value 3", @3, @3],
//                    @[@"Category 4", @"Value 4", @4, @4]
// ]];
//
//TSTableViewModel *model1 = [[TSTableViewModel alloc] initWithTableView:tableView];
//[model1 setColumnsInfo:@[
//         @{ @"title" : @"Column 1"},
//         @{ @"title" : @"Column 2"},
//         @{ @"title" : @"Column", @"subcolumns" : @[
//                                                        @{ @"title" : @"Column 3"},
//                                                        @{ @"title" : @"Column 4"}
//                                                    ]
//          }
//       ]
//           andRowsInfo:@[
//         @{ @"cells" : @[
//                         @{ @"value" : @"Category 1"},
//                         @{ @"value" : @"Value 1"},
//                         @{ @"value" : @1},
//                         @{ @"value" : @1}
//                        ]
//         },
//        @{ @"cells" : @[
//                         @{ @"value" :  @"Category 2"},
//                         @{ @"value" : @"Value 2"},
//                         @{ @"value" : @2},
//                         @{ @"value" : @2}
//                        ],
//            @"subrows" : @[
//                         @{ @"cells" : @[
//                                 @{ @"value" : [NSNull null]},
//                                 @{ @"value" : @"Value 2"},
//                                 @{ @"value" : @2},
//                                 @{ @"value" : @2}
//                                 ],
//                         },
//                         @{ @"cells" : @[
//                                 @{ @"value" : [NSNull null]},
//                                 @{ @"value" : @"Value 2"},
//                                 @{ @"value" : @2},
//                                 @{ @"value" : @2}
//                                 ],
//                         },
//                         @{ @"cells" : @[
//                                 @{ @"value" : [NSNull null]},
//                                 @{ @"value" : @"Value 2"},
//                                 @{ @"value" : @2},
//                                 @{ @"value" : @2}
//                                 ],
//                          }
//                        ]
//         },
//         @{ @"cells" : @[
//                         @{ @"value" : @"Category 2"},
//                         @{ @"value" : @"Value 2"},
//                         @{ @"value" : @2},
//                         @{ @"value" : @2}
//                        ]
//         },
//    ]
// ];
