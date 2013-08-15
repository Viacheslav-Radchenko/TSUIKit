//
//  TSTableViewHeaderSection.h
//  TSUIKit
//
//  Created by Viacheslav Radchenko on 8/10/13.
//  Copyright (c) 2013 Viacheslav Radchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSTableViewHeaderSectionView;

@interface TSTableViewHeaderSection : UIView

@property (nonatomic, strong) TSTableViewHeaderSectionView *sectionView;
@property (nonatomic, strong) NSArray *subsections;
@property (nonatomic, assign) NSRange subcolumnsRange;


@end
