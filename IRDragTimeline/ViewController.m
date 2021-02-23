//
//  ViewController.m
//  IRDragTimeline
//
//  Created by Phil on 2020/9/8.
//  Copyright © 2020 Phil. All rights reserved.
//

#import "ViewController.h"
#import "IRDragTableViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController pushViewController:[[IRDragTableViewController alloc] init] animated:YES];
}


@end
