//
//  ViewController.m
//  AITableMapView
//
//  Created by Alexey Ivanov on 30.05.15.
//  Copyright (c) 2015 Alexey Ivanov. All rights reserved.
//

#import "ViewController.h"

CGFloat const minTableHeaderViewHeight = 44.0;
CGFloat const defaulTableHeaderViewHeight = 160.0;


@interface ViewController () <UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewVerticalSpace;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (nonatomic,strong) UITapGestureRecognizer* tableHeaderViewGesture;
@property CGRect initialHeaderFrame;

@end

@implementation ViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _currentState = MapViewControllerClearState;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.initialHeaderFrame = self.headerView.frame;
    //temporaly
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapMapView:)];
    [tapGesture setNumberOfTapsRequired:1];
    [tapGesture setNumberOfTouchesRequired:1];
    [self.mapView addGestureRecognizer:tapGesture];
    
    
    [self animateToState];
}

-(void)didTapMapView:(UITapGestureRecognizer*)recognizer{
    switch (self.currentState) {
        case MapViewControllerClearState:
            _currentState = MapViewControllerMinDetailState;
            break;
        case MapViewControllerMinDetailState:
            _currentState = MapViewControllerFullDetailState;
            break;
        case MapViewControllerFullDetailState:
            _currentState = MapViewControllerClearState;
            break;
    }
    
    [self animateToState];
}

-(void)animateToState{
    switch (self.currentState) {
            
        case MapViewControllerClearState:{
            self.tableView.tableHeaderView = self.headerView;
            [self.headerView removeGestureRecognizer:self.tableHeaderViewGesture];
            [self.tableView layoutSubviews];
            
            [self.tableView setAllowsSelection:NO];
            [self.tableView setScrollEnabled:NO];
            
            CGFloat newVerticalSpace = self.view.frame.origin.y + self.view.frame.size.height;
            self.tableViewVerticalSpace.constant = newVerticalSpace;
            [self.tableView setNeedsUpdateConstraints];
            [UIView animateWithDuration:1.0 animations:^{
                [self.headerView setFrame:CGRectZero];
                [self.tableView layoutIfNeeded];
            }];
        }
            break;

        case MapViewControllerMinDetailState:{
            
            [self.headerView setFrame:CGRectZero];
            self.tableView.tableHeaderView = self.headerView;
            [self.headerView removeGestureRecognizer:self.tableHeaderViewGesture];
            
            [self.tableView setAllowsSelection:NO];
            [self.tableView setScrollEnabled:NO];
            
            CGFloat newVerticalSpace = self.view.frame.origin.y + self.view.frame.size.height - minTableHeaderViewHeight;
            self.tableViewVerticalSpace.constant = newVerticalSpace;
            [self.tableView setNeedsUpdateConstraints];
            [UIView animateWithDuration:1.0 animations:^{
                [self.tableView layoutIfNeeded];
            }];
        }
            break;
            
        case MapViewControllerFullDetailState:{
            
            [self.headerView setFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 160)];
            [self.headerView addGestureRecognizer:self.tableHeaderViewGesture];
            self.tableView.tableHeaderView = self.headerView;
            
            [self.tableView setAllowsSelection:YES];
            [self.tableView setScrollEnabled:YES];
            
            CGFloat newVerticalSpace = 0.0;
            self.tableViewVerticalSpace.constant = newVerticalSpace;
            [self.tableView setNeedsUpdateConstraints];
            [UIView animateWithDuration:1.0 animations:^{
                [self.tableView layoutIfNeeded];
            }];
        }
            break;
    }
    
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    static NSString *identifier;
    identifier = @"Cell";
    // Add some shadow to the first cell
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:identifier];
        
    }
    [[cell textLabel] setText:@"Hello World !"];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //first get total rows in that section by current indexPath.
    NSInteger totalRow = [tableView numberOfRowsInSection:indexPath.section];
    
    //this is the last row in section.
    if(indexPath.row == totalRow -1){
        // get total of cells's Height
        float cellsHeight = totalRow * cell.frame.size.height;
        // calculate tableView's Height with it's the header
        float tableHeight = (tableView.frame.size.height - tableView.tableHeaderView.frame.size.height);
        
        // Check if we need to create a foot to hide the backView (the map)
        if((cellsHeight - tableView.frame.origin.y)  < tableHeight){
            // Add a footer to hide the background
            int footerHeight = tableHeight - cellsHeight;
            tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, footerHeight)];
            [tableView.tableFooterView setBackgroundColor:[UIColor whiteColor]];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showHeader:(BOOL)show animated:(BOOL)animated{
    
    CGRect closedFrame = CGRectMake(0, 0, self.view.frame.size.width, 0);
    CGRect newFrame = show ? self.initialHeaderFrame : closedFrame;
    
    if(animated){
        // The UIView animation block handles the animation of our header view
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        // beginUpdates and endUpdates trigger the animation of our cells
        [self.tableView beginUpdates];
    }
    
    self.headerView.frame = newFrame;
    [self.tableView setTableHeaderView:self.headerView];
    
    if(animated){
        [self.tableView endUpdates];
        [UIView commitAnimations];
    }
    
}

#pragma mark - Getters

- (BOOL)isHeaderShown{
    return self.headerView.frame.size.height > 0;
}

#pragma mark - Properties
-(UITapGestureRecognizer *)tableHeaderViewGesture{
    if (!_tableHeaderViewGesture) {
        _tableHeaderViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapMapView:)];
        [_tableHeaderViewGesture setNumberOfTouchesRequired:1];
        [_tableHeaderViewGesture setNumberOfTapsRequired:1];
    }
    return _tableHeaderViewGesture;
}

@end
