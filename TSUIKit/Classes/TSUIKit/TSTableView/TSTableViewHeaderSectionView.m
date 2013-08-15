//
//  TSTableViewHeaderSectionView.m
//  TSUIKit
//
//  Created by Viacheslav Radchenko on 8/10/13.
//  Copyright (c) 2013 Viacheslav Radchenko. All rights reserved.
//

#import "TSTableViewHeaderSectionView.h"
#import "TSUtils.h"
#import <QuartzCore/QuartzCore.h>

@interface TSTableViewHeaderSectionView ()
{
    UIColor *_topColor;
    UIColor *_bottomColor;
    UIColor *_topBorderColor;
    UIColor *_bottomBorderColor;
    UIColor *_leftBorderColor;
    UIColor *_rightBorderColor;
}

@end

@implementation TSTableViewHeaderSectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        _topColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
        _bottomColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
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
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        _textLabel.textColor = [UIColor darkGrayColor];
        _textLabel.layer.shadowColor = [UIColor whiteColor].CGColor;
        _textLabel.layer.shadowOpacity = 1;
        _textLabel.layer.shadowRadius = 1;
        _textLabel.layer.shadowOffset = CGSizeMake(1, 1);
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
