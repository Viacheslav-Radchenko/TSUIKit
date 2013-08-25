//
//  TSTableViewController.m
//  TableView
//
//  Created by Viacheslav Radchenko on 8/15/13.
//  Copyright (c) 2013 Viacheslav Radchenko. All rights reserved.
//

#import "TSTableViewController.h"
#import "TSTableViewModel.h"
#import "TSDefines.h"
#import "TSTableViewController+TestDataDefinition.h"
#import <QuartzCore/QuartzCore.h>

@interface TSTableViewController () <TSTableViewDelegate>
{
    TSTableView *_tableView1;
    TSTableView *_tableView2;
    TSTableViewModel *_model1;
    TSTableViewModel *_model2;
    
    NSArray *_tables;
    NSArray *_dataModels;
    NSArray *_rowExamples;
    
    NSInteger _stepperPreviousValue;
}

@end

@implementation TSTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.settingsView.layer.cornerRadius = 4;
    self.settingsView.layer.shadowOpacity = 0.5;
    self.settingsView.layer.shadowOffset = CGSizeMake(2, 4);
    
    // Top table
    NSArray *columns1 = [self columnsInfo1];
    NSArray *rows1 = [self rowsInfo1];

    _tableView1 = [[TSTableView alloc] initWithFrame:CGRectMake(20, 80, self.view.frame.size.width - 40, self.view.frame.size.height/2 - 70)];
    _tableView1.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView1.delegate = self;
    [self.view addSubview:_tableView1];
    
    _model1 = [[TSTableViewModel alloc] initWithTableView:_tableView1 andStyle:kTSTableViewStyleDark];
    [_model1 setColumnsInfo:columns1 andRowsInfo:rows1];
    
    // Bottom table
    NSArray *columns2 = [self columnsInfo2];
    NSArray *rows2 = [self rowsInfo2];
    
    _tableView2 = [[TSTableView alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height/2 + 50, self.view.frame.size.width - 40, self.view.frame.size.height/2 - 70)];
    _tableView2.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView2.delegate = self;
    
    [self.view addSubview:_tableView2];
    
    _model2 = [[TSTableViewModel alloc] initWithTableView:_tableView2 andStyle:kTSTableViewStyleLight];
    [_model2 setColumnsInfo:columns2 andRowsInfo:rows2];
    
    _dataModels = @[_model1, _model2];
    _tables = @[_tableView1, _tableView2];
    
    // Row examples should correspond to columnsInfo* and rowsInfo* used above
    _rowExamples = @[
                     [self rowExample1],
                     [self rowExample2],
                     ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 

- (IBAction)numberOfRowsValueChanged:(UIStepper *)stepper
{
    NSInteger val = [stepper value];
    if(val > _stepperPreviousValue)
    {
        for(int i = 0; i < _dataModels.count;  ++i)
        {
            TSTableView *table = _tables[i];
            TSTableViewModel *model = _dataModels[i];
            NSIndexPath *rowPath = [table pathToSelectedRow];
            if(!rowPath)
                rowPath = [NSIndexPath indexPathWithIndex:0];
            
            TSRow *row = _rowExamples[i];
            [model insertRow:row atPath:rowPath];
        }
    }
    else
    {
        for(int i = 0; i < _dataModels.count;  ++i)
        {
            TSTableView *table = _tables[i];
            TSTableViewModel *model = _dataModels[i];
            NSIndexPath *rowPath = [table pathToSelectedRow];
            if(rowPath)
                [model removeRowAtPath:rowPath];
            
        }
    }
    _stepperPreviousValue = val;
}

- (IBAction)expandAllButtonPressed
{
    for(TSTableView *table in _tables)
    {
        [table expandAllRowsWithAnimation:YES];
    }
}

- (IBAction)collapseAllButtonPressed
{
    for(TSTableView *table in _tables)
    {
        [table collapseAllRowsWithAnimation:YES];
    }
}

- (IBAction)resetSelectionButtonPressed
{
    for(TSTableView *table in _tables)
    {
        [table resetColumnSelectionWithAnimtaion:YES];
        [table resetRowSelectionWithAnimtaion:YES];
    }
}

#pragma mark - TSTableViewDelegate

- (void)tableView:(TSTableView *)tableView willSelectRowAtPath:(NSIndexPath *)rowPath animated:(BOOL)animated
{
    VerboseLog();
}

- (void)tableView:(TSTableView *)tableView didSelectRowAtPath:(NSIndexPath *)rowPath
{
    VerboseLog();
}

- (void)tableView:(TSTableView *)tableView willSelectColumnAtPath:(NSIndexPath *)columnPath animated:(BOOL)animated
{
    VerboseLog();
}

- (void)tableView:(TSTableView *)tableView didSelectColumnAtPath:(NSIndexPath *)columnPath
{
    VerboseLog();
}

- (void)tableView:(TSTableView *)tableView widthDidChangeForColumnAtIndex:(NSInteger)columnIndex
{
    VerboseLog();
}

- (void)tableView:(TSTableView *)tableView expandStateDidChange:(BOOL)expand forRowAtPath:(NSIndexPath *)rowPath
{
    VerboseLog();
}

@end
