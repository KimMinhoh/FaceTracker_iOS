//
//  ViewController.h
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
using namespace cv;

@interface ViewController : UIViewController<CvVideoCameraDelegate>
{
    IBOutlet UIImageView* videoView;
    IBOutlet UIButton* start;
    IBOutlet UIButton* flip;
}

@property (nonatomic, strong) CvVideoCamera* videoCamera;

- (IBAction)trackerStart:(id)sender;

- (IBAction)flipCam:(id)sender;


@end
