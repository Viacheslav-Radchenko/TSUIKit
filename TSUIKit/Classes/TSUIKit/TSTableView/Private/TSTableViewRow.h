//
//  TSTableViewRow.h
//  TSUIKit
//
//  Created by Viacheslav Radchenko on 8/13/13.
//  Copyright (c) 2013 Viacheslav Radchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSTableViewRow : UIView

@property (nonatomic, assign) CGFloat rowHeight;
@property (nonatomic, strong) NSArray *subrows;
@property (nonatomic, strong) NSArray *cells;

@end
