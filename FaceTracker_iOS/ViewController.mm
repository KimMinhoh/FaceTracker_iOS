//
//  ViewController.m
//  FaceTracker_iOS
//
//  Created by George Georgaklis on 9/14/14.
//  Copyright (c) 2014 George Georgaklis. All rights reserved.
//

#import "ViewController.hpp"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    NSLog(@"view did load");
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:videoView];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Protocol CvVideoCameraDelegate

#ifdef __cplusplus
- (void)processImage:(Mat&)image;
{
    //NSLog(@"process image");
    // Do some OpenCV stuff with the image
    //Mat image_copy;
    //cvtColor(image, image_copy, cv::CV_BGRA2BGR);
    
    // invert image
     //bitwise_not(image_copy, image_copy);
    //cvtColor(image_copy, image, cv::CV_BGR2BGRA);
}
#endif
#pragma mark - UI Actions

- (IBAction)trackerStart:(id)sender
{
    NSLog(@"tracker start");
    [self.videoCamera start];

}

-(IBAction)flipCam:(id)sender{
    NSLog(@"flip cam");
    [self.videoCamera switchCameras];
}


@end
