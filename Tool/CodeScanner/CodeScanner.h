//
//  CodeScanner.h
//  Tool
//
//  Created by Phineas_Huang on 28/03/2017.
//  Copyright © 2017 SunXiaoShan. All rights reserved.
//

// import AVFoundation framework

#import <UIKit/UIKit.h>

typedef void (^Completion) (NSArray * __nonnull datas);

@interface CodeScanner : UIViewController

+ (void) switchToCodeScanner:(UIViewController * __nonnull)viewcontroller
                  completion:(Completion __nonnull)completion;

@end
