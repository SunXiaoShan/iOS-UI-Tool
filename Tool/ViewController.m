//
//  ViewController.m
//  Tool
//
//  Created by Phineas_Huang on 28/03/2017.
//  Copyright © 2017 SunXiaoShan. All rights reserved.
//

#import "ViewController.h"
#import "CodeScanner.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    [CodeScanner switchToCodeScanner:self completion:^(NSArray * _Nonnull datas) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
