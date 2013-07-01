//
//  TSTestSectionButton.m
//  TSUIKit
//
//  Created by Viacheslav Radchenko on 6/28/13.
//
//  The MIT License (MIT)
//  Copyright © 2013 Viacheslav Radchenko
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "TSTestSectionButton.h"

@implementation TSTestSectionButton

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    _bgColor = backgroundColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGFloat arrowWidth = 8;
    CGFloat arrowHeight = 4;
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    [arrowPath moveToPoint:CGPointMake(0, arrowHeight)];
    [arrowPath addLineToPoint:CGPointMake(rect.size.width, arrowHeight)];
    [arrowPath addLineToPoint:CGPointMake(rect.size.width, rect.size.height - arrowHeight)];
    [arrowPath addLineToPoint:CGPointMake(rect.size.width/2 + arrowWidth/2, rect.size.height - arrowHeight)];
    [arrowPath addLineToPoint:CGPointMake(rect.size.width/2, rect.size.height - (self.selected ? 0 : arrowHeight))];
    [arrowPath addLineToPoint:CGPointMake(rect.size.width/2 - arrowWidth/2, rect.size.height - arrowHeight)];
    [arrowPath addLineToPoint:CGPointMake(0, rect.size.height - arrowHeight)];
    CGContextSetFillColorWithColor(currentContext, _bgColor.CGColor);
    CGContextAddPath(currentContext, [arrowPath CGPath]);
    CGContextDrawPath(currentContext, kCGPathFill);
    
    [super drawRect:rect];
}

@end

