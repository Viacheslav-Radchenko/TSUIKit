//
//  TSTableViewExpandRow.m
//  TSUIKit
//
//  Created by Viacheslav Radchenko on 8/13/13.
//  Copyright (c) 2013 Viacheslav Radchenko. All rights reserved.
//

#import "TSTableViewExpandRow.h"
#import "TSTableViewExpandRowButton.h"
#import "TSUtils.h"

@interface TSTableViewExpandRow ()
{
    UIColor *_topColor;
    UIColor *_bottomColor;
    UIColor *_topBorderColor;
    UIColor *_bottomBorderColor;
    UIColor *_leftBorderColor;
    UIColor *_rightBorderColor;
}

@end

@implementation TSTableViewExpandRow

- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        _topColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
        _bottomColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
        _topBorderColor = [UIColor whiteColor];
        _bottomBorderColor = [UIColor colorWithWhite:0.7f alpha:1.0f];
        _leftBorderColor = [UIColor colorWithWhite:0 alpha:0.1f];
        _rightBorderColor = [UIColor colorWithWhite:0.7f alpha:1.0f];
        
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setExpandButton:(TSTableViewExpandRowButton *)expandButton
{
    if(_expandButton)
        [_expandButton removeFromSuperview];
    
    _expandButton = expandButton;
    
    if(_expandButton)
        [self addSubview:_expandButton];
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [TSUtils drawLinearGradientInContext:context
                                    rect:self.bounds
                              startColor:_topColor.CGColor
                                endColor:_bottomColor.CGColor];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(0, 0)
                      endPoint:CGPointMake(self.bounds.size.width - 1, 0)
                         color:_topBorderColor.CGColor
                     lineWidth:0.5];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(0, self.bounds.size.height - 1)
                      endPoint:CGPointMake(self.bounds.size.width - 1, self.bounds.size.height - 1)
                         color:_bottomBorderColor.CGColor
                     lineWidth:0.5];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(self.bounds.size.width - 1, 0)
                      endPoint:CGPointMake(self.bounds.size.width - 1, self.bounds.size.height - 1)
                         color:_rightBorderColor.CGColor
                     lineWidth:0.5];
    [TSUtils drawLineInContext:context
                    startPoint:CGPointMake(4, 0)
                      endPoint:CGPointMake(4, self.bounds.size.height - 1)
                         color:_leftBorderColor.CGColor
                     lineWidth:8];
}

@end
