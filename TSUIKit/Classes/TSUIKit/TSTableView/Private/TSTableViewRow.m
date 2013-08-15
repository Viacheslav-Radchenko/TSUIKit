//
//  TSTableViewRow.m
//  TSUIKit
//
//  Created by Viacheslav Radchenko on 8/13/13.
//  Copyright (c) 2013 Viacheslav Radchenko. All rights reserved.
//

#import "TSTableViewRow.h"

@implementation TSTableViewRow

- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setSubrows:(NSArray *)subrows
{
    if(_subrows)
        for(UIView *v in _subrows)
            [v removeFromSuperview];
    
    _subrows = subrows;
    
    if(_subrows)
        for(UIView *v in _subrows)
            [self addSubview:v];
}


- (void)setCells:(NSArray *)cells
{
    if(_cells)
        for(UIView *v in _cells)
            [v removeFromSuperview];
    
    _cells = cells;
    
    if(_cells)
        for(UIView *v in _cells)
            [self addSubview:v];
}

@end
