//
//  TSTableViewCell.m
//  TSUIKit
//
//  Created by Viacheslav Radchenko on 8/13/13.
//  Copyright (c) 2013 Viacheslav Radchenko. All rights reserved.
//

#import "TSTableViewCell.h"
#import "TSUtils.h"

@interface TSTableViewCell ()
{
    UIColor *_topColor;
    UIColor *_bottomColor;
    UIColor *_topBorderColor;
    UIColor *_bottomBorderColor;
    UIColor *_leftBorderColor;
    UIColor *_rightBorderColor;
}

@end

@implementation TSTableViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _topColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
        _bottomColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
        _topBorderColor = [UIColor whiteColor];
        _bottomBorderColor = [UIColor colorWithWhite:0.7f alpha:1.0f];
        _leftBorderColor = [UIColor whiteColor];
        _rightBorderColor = [UIColor colorWithWhite:0.7f alpha:1.0f];
    }
    return self;
}

- (UILabel *)textLabel
{
    if(!_textLabel)
    {
        _textLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _textLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.font = [UIFont systemFontOfSize:14.0f];
        [self addSubview:_textLabel];
    }
    return _textLabel;
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
                    startPoint:CGPointMake(0, 0)
                      endPoint:CGPointMake(0, self.bounds.size.height - 1)
                         color:_leftBorderColor.CGColor
                     lineWidth:0.5];
}

@end
