//
//  TSUtils.m
//  TSUIKit
//
//  Created by Viacheslav Radchenko on 6/20/13.
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

#import "TSUtils.h"

#ifndef VerboseLog
#define VerboseLog(fmt, ...)  (void)0
#endif

#define ANIMATION_DURATION      0.3

@implementation TSUtils

+ (void)performViewAnimationBlock:(void (^)(void))block withCompletion:(void (^)(void))completion animated:(BOOL)animated
{
    VerboseLog();
    if(animated)
    {
        [UIView animateWithDuration:ANIMATION_DURATION
                         animations:^{
                             if(block)
                                 block();
                         } completion:^(BOOL finished) {
                             if(completion)
                                 completion();
                         }];
    }
    else
    {
        if(block)
            block();
        if(completion)
            completion();
    }
}

@end
