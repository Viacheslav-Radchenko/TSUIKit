//
//  TSTableViewHeaderSection.m
//  TSUIKit
//
//  Created by Viacheslav Radchenko on 8/10/13.
//  Copyright (c) 2013 Viacheslav Radchenko. All rights reserved.
//

#import "TSTableViewHeaderSection.h"
#import "TSTableViewHeaderSectionView.h"
#import <QuartzCore/QuartzCore.h>

@implementation TSTableViewHeaderSection

- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.layer.borderColor = [UIColor greenColor].CGColor;
     //   self.layer.borderWidth = 1;
    }
    return self;
}

- (void)setSectionView:(TSTableViewHeaderSectionView *)sectionView
{
    if(_sectionView)
        [_sectionView removeFromSuperview];
    
    _sectionView = sectionView;
    
    if(_sectionView)
        [self addSubview:_sectionView];
}

- (void)setSubsections:(NSArray *)subsections
{
    if(_subsections)
       for(UIView *v in _subsections)
           [v removeFromSuperview];
    
    _subsections = subsections;
    
    if(_subsections)
        for(UIView *v in _subsections)
            [self addSubview:v];
}

@end
