//
//  TSTableViewModel.m
//  TSUIKit
//
//  Created by Viacheslav Radchenko on 8/14/13.
//  Copyright (c) 2013 Viacheslav Radchenko. All rights reserved.
//

#import "TSTableViewModel.h"
#import "TSTableView.h"
#import "TSTableViewCell.h"
#import "TSTableViewHeaderSectionView.h"
#import "TSDefines.h"

#ifndef VerboseLog
#define VerboseLog(fmt, ...)  (void)0
#endif

@implementation TSColumn 

+ (id)columnWithTitle:(NSString *)title
{
    return [[TSColumn alloc] initWithTitle:title];
}

+ (id)columnWithTitle:(NSString *)title andSubcolumns:(NSArray *)sublolumns
{
    return [[TSColumn alloc] initWithTitle:title andSubcolumns:sublolumns];
}

+ (id)columnWithDictionary:(NSDictionary *)info
{
    return [[TSColumn alloc] initWithDictionary:info];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ - %@", [super description], self.title];
}

- (id)initWithTitle:(NSString *)title
{
    if(self = [super init])
    {
        _title = title;
    }
    return self;
}

- (id)initWithTitle:(NSString *)title andSubcolumns:(NSArray *)subcolumns
{
    if(self = [super init])
    {
        _title = title;
        
        NSMutableArray *columns = [[NSMutableArray alloc] initWithCapacity:subcolumns.count];
        for(id subcolumn in subcolumns)
        {
            if([subcolumn isKindOfClass:[TSColumn class]])
            {
                [columns addObject:subcolumn];
            }
            else if([subcolumn isKindOfClass:[NSString class]])
            {
                [columns addObject:[[TSColumn alloc] initWithTitle:title]];
            }
            else
            {
                NSAssert(FALSE, @"Type is not supported");
            }
        }
        _subcolumns = columns;
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)info
{
    if(self = [super init])
    {
        _title = info[@"title"];
        
        NSArray *subcolumns = info[@"subcolumns"];
#warning check empty array
        if(subcolumns.count)
        {
            NSMutableArray *tmpColumns = [[NSMutableArray alloc] initWithCapacity:subcolumns.count];
            for(NSDictionary *subcolumnInfo in subcolumns)
            {
                if([subcolumnInfo isKindOfClass:[NSDictionary class]])
                {
                    [tmpColumns addObject:[[TSColumn alloc] initWithDictionary:subcolumnInfo]];
                }
                else
                {
                    NSAssert(FALSE, @"Type is not supported");
                }
            }
            _subcolumns = tmpColumns;
        }
    }
    return self;
}

@end

/**
 *  @abstract
 */

@implementation TSRow 

+ (id)rowWithCells:(NSArray *)cells
{
    return [[TSRow alloc] initWithCells:cells];
}

+ (id)rowWithCells:(NSArray *)cells andSubrows:(NSArray *)subrows
{
    return [[TSRow alloc] initWithCells:cells andSubrows:subrows];
}

+ (id)rowWithDictionary:(NSDictionary *)info
{
    return [[TSRow alloc] initWithDictionary:info];
}

- (id)initWithCells:(NSArray *)cells
{
    return [self initWithCells:cells andSubrows:nil];
}

- (id)initWithCells:(NSArray *)cells andSubrows:(NSArray *)subrows
{
    if(self = [super init])
    {
        if(cells)
        {
            NSMutableArray *tmpCells = [[NSMutableArray alloc] initWithCapacity:cells.count];
            for(id cell in cells)
            {
                if([cell isKindOfClass:[TSCell class]])
                {
                    [tmpCells addObject:cell];
                }
                else 
                {
                    [tmpCells addObject:[[TSCell alloc] initWithValue:cell]];
                }
            }
            _cells = tmpCells;
        }
        
        if(subrows)
        {
            NSMutableArray *tmpRows = [[NSMutableArray alloc] initWithCapacity:subrows.count];
            for(id row in subrows)
            {
                if([row isKindOfClass:[TSRow class]])
                {
                    [tmpRows addObject:row];
                }
                else if([row isKindOfClass:[NSArray class]])
                {
                    [tmpRows addObject:[[TSRow alloc] initWithCells:row]];
                }
                else
                {
                    NSAssert(FALSE, @"Type is not supported");
                }
            }
            _subrows = tmpRows;
        }
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)info
{
    if(self = [super init])
    {
        NSArray *cells = info[@"cells"];
        if(cells)
        {
            NSMutableArray *tmpCells = [[NSMutableArray alloc] initWithCapacity:cells.count];
            for(NSDictionary *cellInfo in cells)
            {
                if([cellInfo isKindOfClass:[NSDictionary class]])
                {
                    [tmpCells addObject:[[TSCell alloc] initWithDictionary:cellInfo]];
                }
                else
                {
                    NSAssert(FALSE, @"Type is not supported");
                }
            }
            _cells = tmpCells;
        }
        
        NSArray *subrows = info[@"subrows"];
        if(subrows)
        {
            NSMutableArray *tmpRows = [[NSMutableArray alloc] initWithCapacity:subrows.count];
            for(NSDictionary *rowInfo in subrows)
            {
                if([rowInfo isKindOfClass:[NSDictionary class]])
                {
                    [tmpRows addObject:[[TSRow alloc] initWithDictionary:rowInfo]];
                }
                else
                {
                    NSAssert(FALSE, @"Type is not supported");
                }
            }
            _subrows = tmpRows;
        }
    }
    return self;
}

@end

/**
 *  @abstract
 */

@implementation TSCell 

+ (id)cellWithValue:(NSObject *)value
{
    return [[TSCell alloc] initWithValue:value];
}

+ (id)cellWithDictionary:(NSDictionary *)info
{
    return [[TSCell alloc] initWithDictionary:info];
}

- (id)initWithValue:(NSObject *)value
{
    if(self = [super init])
    {
        _value = value;
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)info
{
    if(self = [super init])
    {
        _value = info[@"value"];
    }
    return self;
}

@end

/**
 *  @abstract
 */

@implementation TSTableViewModel

- (id)initWithTableView:(TSTableView *)tableView
{
    if(self = [super init])
    {
        _tableView = tableView;
        _tableView.dataSource = self;
        
        _rows = [[NSMutableArray alloc] init];
        _columns = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setColumns:(NSArray *)columns andRows:(NSArray *)rows
{
    VerboseLog();
    [_columns removeAllObjects];
    [_rows removeAllObjects];
    
    for(id column in columns)
    {
        if([column isKindOfClass:[TSColumn class]])
        {
            [_columns addObject:column];
        }
        else if([column isKindOfClass:[NSString class]])
        {
            [_columns addObject:[[TSColumn alloc] initWithTitle:column]];
        }
        else
        {
            NSAssert(FALSE, @"Type is not supported");
        }
    }
    
    for(id row in rows)
    {
        if([row isKindOfClass:[TSRow class]])
        {
            [_rows addObject:row];
        }
        else if([row isKindOfClass:[NSArray class]])
        {
            [_rows addObject:[[TSRow alloc] initWithCells:row]];
        }
        else
        {
            NSAssert(FALSE, @"Type is not supported");
        }
    }
    
    [_tableView reloadData];
}

- (void)setColumnsInfo:(NSArray *)columns andRowsInfo:(NSArray *)rows
{
    VerboseLog();
    [_columns removeAllObjects];
    [_rows removeAllObjects];
    
    for(NSDictionary *columnInfo in columns)
    {
        if([columnInfo isKindOfClass:[NSDictionary class]])
        {
            [_columns addObject:[TSColumn columnWithDictionary:columnInfo]];
        }
        else
        {
            NSAssert(FALSE, @"Type is not supported");
        }
    }
    
    for(NSDictionary *rowInfo in rows)
    {
        if([rowInfo isKindOfClass:[NSDictionary class]])
        {
            [_rows addObject:[TSRow rowWithDictionary:rowInfo]];
        }
        else
        {
            NSAssert(FALSE, @"Type is not supported");
        }
    }
    [_tableView reloadData];
}


- (TSRow *)rowAtPath:(NSIndexPath *)indexPath
{
    VerboseLog();
    TSRow *row;
    NSArray *rows = _rows;
    for(int i = 0; i < indexPath.length; i++)
    {
        NSInteger index = [indexPath indexAtPosition:i];
        row = rows[index];
        rows = row.subrows;
    }
    return row;
}


- (TSColumn *)columnAtPath:(NSIndexPath *)indexPath
{
    VerboseLog();
    TSColumn *column;
    NSArray *columns = _columns;
    for(int i = 0; i < indexPath.length; i++)
    {
        NSInteger index = [indexPath indexAtPosition:i];
        column = columns[index];
        columns = column.subcolumns;
    }
    return column;
}

- (TSCell *)cellAtRowPath:(NSIndexPath *)rowPath atIndex:(NSInteger)index
{
    VerboseLog();
    TSRow *row = [self rowAtPath:rowPath];
    TSCell *cell = row.cells[index];
    return cell;
}

#pragma mark - TSTableViewDataSource

- (NSInteger)numberOfColumns
{
    VerboseLog();
    return [self calcNumberOfColumns:_columns];
}

- (NSInteger)calcNumberOfColumns:(NSArray *)columns
{
    VerboseLog();
    NSInteger columnsCount = columns.count;
    for(TSColumn *column in columns)
    {
        if(column.subcolumns.count)
        {
            columnsCount += [self calcNumberOfColumns:column.subcolumns] - 1;
        }
    }
    return columnsCount;
}

- (NSInteger)numberOfRows
{
    VerboseLog();
    return [self calcNumberOfRows:_rows];
}

- (NSInteger)calcNumberOfRows:(NSArray *)rows
{
    VerboseLog();
    NSInteger rowsCount = rows.count;
    for(TSRow *row in rows)
    {
        rowsCount += [self calcNumberOfRows:row.subrows];
    }
    return rowsCount;
}

- (NSInteger)numberOfColumnsAtPath:(NSIndexPath *)indexPath
{
    VerboseLog(@"%@", indexPath);
    TSColumn *column;
    NSArray *columns = _columns;
    for(int i = 0; i < indexPath.length; i++)
    {
        NSInteger index = [indexPath indexAtPosition:i];
        column = columns[index];
        columns = column.subcolumns;
    }
    return columns.count;
}

- (NSInteger)numberOfRowsAtPath:(NSIndexPath *)indexPath
{
    VerboseLog();
    TSRow *row;
    NSArray *rows = _rows;
    for(int i = 0; i < indexPath.length; i++)
    {
        NSInteger index = [indexPath indexAtPosition:i];
        row = rows[index];
        rows = row.subrows;
    }
    return rows.count;
}

- (CGFloat)heightForRowAtPath:(NSIndexPath *)indexPath
{
    VerboseLog();
    return 44;
}

- (CGFloat)heightForHeaderSectionAtPath:(NSIndexPath *)columnPath
{
    VerboseLog();
    return 44;
}

- (CGFloat)defaultWidthForColumnAtPath:(NSIndexPath *)columnPath
{
    VerboseLog();
    return 128;
}

- (TSTableViewCell *)tableView:(TSTableView *)tableView cellViewForRowAtPath:(NSIndexPath *)indexPath cellIndex:(NSInteger)index
{
    VerboseLog();
    TSCell *cellInfo = [self cellAtRowPath:indexPath atIndex:index];
    TSTableViewCell *cell = [[TSTableViewCell alloc] init];
    if([cellInfo.value isKindOfClass:[NSNull class]])
    {
        cell.textLabel.text = @"";
        cell.alpha = 0.8f;
    }
    else
    {
        cell.textLabel.text = [cellInfo.value description];
        cell.alpha = 1;
    }
    return cell;
}

- (TSTableViewHeaderSectionView *)tableView:(TSTableView *)tableView headerSectionViewForColumnAtPath:(NSIndexPath *)indexPath
{
    VerboseLog();
    TSColumn *column = [self columnAtPath:indexPath];
    TSTableViewHeaderSectionView *section = [[TSTableViewHeaderSectionView alloc] init];
    section.textLabel.text = column.title;
    return section;
}

@end
