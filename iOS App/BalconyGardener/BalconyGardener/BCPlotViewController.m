//
//  BCPlotViewController.m
//  BalconyGardener
//
//  Created by Thomas Engelmeier on 19.10.14.
//  Copyright (c) 2014 Daniel Peter. All rights reserved.
//

#import "BCPlotViewController.h"
#import "BCPlotDataSource.h"

#import <CorePlot/CPTPlot.h>

@interface BCPlotViewController ()
@property (nonatomic) NSArray *sensorValues;
@property (nonatomic) BCPlotDataSource *dataSource;
@property (nonatomic, weak) IBOutlet UIView *graphHostView;
@end

@implementation BCPlotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = [[BCPlotDataSource alloc] init];
    [self internalInit];
    self.view.backgroundColor = [UIColor yellowColor];
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *sensorURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://146.0.40.96/balconygardener/service.php?action=getSensorData&sensorName=%@&count=20", self.sensorIdentifier]];
    
    [[session dataTaskWithURL:sensorURL
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                // handle response
                if( !error ) {
                    NSError *jsonError = nil;
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog( @"Setting Sensor values: %@", json );
                        [self.dataSource displaySensorTitle:self.sensorIdentifier values:json[self.sensorIdentifier]];
                    });
                }
            }] resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) internalInit {
    // Update the user interface for the detail item.
    if( self.dataSource && !self.dataSource.hostView && self.graphHostView) {
        
        CPTGraphHostingView *view = [[CPTGraphHostingView alloc] initWithFrame:CGRectZero];
        // view.backgroundColor = [UIColor greenColor];
        NSDictionary *viewsDict = @{ @"graphView": view };
        self.dataSource.hostView = view;
        self.graphHostView.translatesAutoresizingMaskIntoConstraints = NO;
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.graphHostView addSubview:view];
        
        NSMutableArray *constraints = [NSMutableArray array];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[graphView]|" options:0 metrics:nil views:viewsDict]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[graphView]|" options:0 metrics:nil views:viewsDict]];
        [self.graphHostView addConstraints:constraints];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
