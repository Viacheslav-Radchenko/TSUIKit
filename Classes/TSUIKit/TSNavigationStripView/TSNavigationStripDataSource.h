//
//  TSNavigationStripDataSource.h
//  Created by Viacheslav Radchenko on 6/10/13.
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

#import <Foundation/Foundation.h>

@protocol TSNavigationStripDataSource <NSObject>

- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsFromLeftSide:(BOOL)leftSide;

@optional

// Sections.
// Provide custom control which extends UIButton. Futher parameters would be applied to this control.
// If method isn't defined then UIButton is used.
- (UIButton *)customSectionControlForIndex:(NSInteger)index;

// Section's content.
- (NSString *)titleForSectionAtIndex:(NSInteger)index forSelectedState:(BOOL)selected;
- (UIImage *)iconForSectionAtIndex:(NSInteger)index forSelectedState:(BOOL)selected;
- (CGFloat)sectionWidthAtIndex:(NSInteger)index forSelectedState:(BOOL)selected;

// Section's appearance.
- (UIColor *)titleColorForSectionAtIndex:(NSInteger)index forSelectedState:(BOOL)selected;
- (UIFont *)titleFontForSectionAtIndex:(NSInteger)index forSelectedState:(BOOL)selected;
- (UIColor *)shadowColorForSectionAtIndex:(NSInteger)index;
- (CGSize)shadowOffsetForSectionAtIndex:(NSInteger)index;
- (UIEdgeInsets)edgeInsetsForSectionAtIndex:(NSInteger)index;
- (UIImage *)backgroundImageForSectionAtIndex:(NSInteger)index forSelectedState:(BOOL)selected;
- (UIColor *)backgroundColorForSectionAtIndex:(NSInteger)index forSelectedState:(BOOL)selected;

// Items.
// Provide custom control which extends UIButton. Futher parameters would be applied to this control.
// If method isn't defined then UIButton is used.
- (UIButton *)customItemControlForIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide;

// Item's content.
- (NSString *)titleForItemAtIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide forSelectedState:(BOOL)selected;
- (UIImage *)iconForItemAtIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide forSelectedState:(BOOL)selected;
- (CGFloat)itemWidthAtIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide forSelectedState:(BOOL)selected;

// Item's appearance.
- (UIColor *)titleColorForItemAtIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide forSelectedState:(BOOL)selected;
- (UIFont *)titleFontForItemAtIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide forSelectedState:(BOOL)selected;
- (UIColor *)shadowColorForItemAtIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide;
- (CGSize)shadowOffsetForItemAtIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide;
- (UIEdgeInsets)edgeInsetsForItemAtIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide;
- (UIImage *)backgroundImageForItemAtIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide forSelectedState:(BOOL)selected;
- (UIColor *)backgroundColorForItemAtIndex:(NSInteger)index fromLeftSide:(BOOL)leftSide forSelectedState:(BOOL)selected;

@end


