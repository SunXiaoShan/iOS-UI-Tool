//
//  CodeScanner.m
//  Tool
//
//  Created by Phineas_Huang on 28/03/2017.
//  Copyright © 2017 SunXiaoShan. All rights reserved.
//

#import "CodeScanner.h"
#import <AVFoundation/AVFoundation.h>

typedef void (^Completion) (NSArray *datas);

@interface CodeScanner () <AVCaptureMetadataOutputObjectsDelegate> {
    AVCaptureSession *captureSession;
    AVCaptureVideoPreviewLayer *videoPreviewLayer;
    
    Completion blockCompletion;
}

@property (weak, nonatomic) IBOutlet UIImageView *preview;
@property (weak, nonatomic) IBOutlet UILabel *labelHint;

@property (nonatomic, copy) Completion blockCompletion;

@end

@implementation CodeScanner

@synthesize blockCompletion;

+ (void) switchToCodeScanner:( UIViewController * __nonnull)viewcontroller
                  completion:(Completion __nonnull)completion {
    
   dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CodeScanner" bundle:nil];
        CodeScanner *vc = [storyboard instantiateViewControllerWithIdentifier:@"CodeScannerViewController"];
        vc.blockCompletion = [completion copy];
        [viewcontroller presentViewController:vc animated:YES completion:nil];
   });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self startCamera];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self runCamera];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopCamera];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) startCamera {
    captureSession = [[AVCaptureSession alloc] init];
    
    NSError *error;
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if ([captureSession canAddInput:input]) {
        [captureSession addInput:input];
    } else {
        NSLog(@"captureSession canAddInput : fail");
        return;
    }
    
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [captureSession addOutput:output];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [output setMetadataObjectsDelegate:self queue:dispatchQueue];
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode,
                                      AVMetadataObjectTypeUPCECode,
                                      AVMetadataObjectTypeCode39Code,
                                      AVMetadataObjectTypeCode39Mod43Code,
                                      AVMetadataObjectTypeEAN13Code,
                                      AVMetadataObjectTypeEAN8Code,
                                      AVMetadataObjectTypeCode93Code,
                                      AVMetadataObjectTypeCode128Code,
                                      AVMetadataObjectTypePDF417Code,
                                      AVMetadataObjectTypeAztecCode]];
    
    videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
    [videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [videoPreviewLayer setFrame:self.view.layer.bounds];
    [self.view.layer addSublayer:videoPreviewLayer];
    
    [self.view insertSubview:self.preview aboveSubview:self.view];
    [self.view insertSubview:self.labelHint aboveSubview:self.view];
}

- (void) runCamera {
    if (![captureSession isRunning]) {
        [captureSession startRunning];
    }
}

- (void) stopCamera {
    if ([captureSession isRunning]) {
        [captureSession stopRunning];
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection {
    
    if (metadataObjects == nil || [metadataObjects count] ==0) {
        return;
    }
    
    NSMutableArray *buff = [[NSMutableArray alloc] init];
    for (id metadata in metadataObjects) {
        if (![metadata isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            continue;
        }
        AVMetadataMachineReadableCodeObject *readableObject = metadata;
        NSString *code = [readableObject stringValue];
        if (code != nil) {
            [buff addObject:code];
        }
    }
    
    if (blockCompletion == nil) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        blockCompletion([buff copy]);
        blockCompletion = nil;
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

@end


















