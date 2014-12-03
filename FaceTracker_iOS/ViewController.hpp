//
//  ViewController.hpp
//  FaceTracker_iOS
//
//  Created by George Georgaklis on 9/14/14.
//  Copyright (c) 2014 George Georgaklis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/highgui/cap_ios.h>
#import <opencv2/imgproc.hpp>
#import <opencv2/objdetect.hpp>
#include <opencv/highgui.h>
#include <iostream>
#include <FaceTracker/Tracker.h>
#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>
using namespace cv;

@interface ViewController : UIViewController<CvVideoCameraDelegate, AVCaptureVideoDataOutputSampleBufferDelegate> {
    IBOutlet UIImageView* videoView;
    IBOutlet UIButton* start;
    IBOutlet UIButton* flip;
    UIView *faceView;
    UIView *leftEyeView;
    UIView *rightEye;
    UIView *mouth;
}

@property (nonatomic, strong) CvVideoCamera* videoCamera;

- (IBAction)trackerStart:(id)sender;

- (IBAction)flipCam:(id)sender;

- (IBAction)capture:(id)sender;

- (cv::Mat)cvMatFromUIImage:(UIImage *)image;

- (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;

- (void)captureOutput:(AVCaptureOutput *)captureOutput idOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;

- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;




@end
