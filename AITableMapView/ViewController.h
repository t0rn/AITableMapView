//
//  ViewController.h
//  AITableMapView
//
//  Created by Alexey Ivanov on 30.05.15.
//  Copyright (c) 2015 Alexey Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

typedef NS_ENUM(NSInteger, MapViewControllerState) {
    MapViewControllerClearState = 0,
    MapViewControllerMinDetailState = 1,
    MapViewControllerFullDetailState = 2
};

@interface ViewController : UIViewController
@property (nonatomic,readonly) MapViewControllerState currentState;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;



@end

