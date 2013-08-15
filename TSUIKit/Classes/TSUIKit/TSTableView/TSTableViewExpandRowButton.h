//
//  TSTableViewExpandRowButton.h
//  TSUIKit
//
//  Created by Viacheslav Radchenko on 8/13/13.
//  Copyright (c) 2013 Viacheslav Radchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSTableViewExpandRowButton : UIButton

@property (nonatomic, assign) BOOL expanded;
@property (nonatomic, strong) NSIndexPath *rowPath;

@end
