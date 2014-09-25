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
    
    
    //=========================================================================
    //parse command line arguments
    char ftFile[256],conFile[256],triFile[256];
    bool fcheck = false; double scale = 1; int fpd = -1; bool show = true;
    //if(parse_cmd(argc,argv,ftFile,conFile,triFile,fcheck,scale,fpd)<0)return 0;
    
    //set other tracking parameters
    std::vector<int> wSize1(1); wSize1[0] = 7;
    std::vector<int> wSize2(3); wSize2[0] = 11; wSize2[1] = 9; wSize2[2] = 7;
    int nIter = 5; double clamp=3,fTol=0.01;
    FACETRACKER::Tracker model(ftFile);
    cv::Mat tri=FACETRACKER::IO::LoadTri(triFile);
    cv::Mat con=FACETRACKER::IO::LoadCon(conFile);
    
    //initialize camera and display window
    cv::Mat frame,gray,im; double fps=0; char sss[256]; std::string text;
    CvCapture* camera = cvCreateCameraCapture(CV_CAP_ANY);
    int64 t1,t0 = cvGetTickCount(); int fnum=0;
    cvNamedWindow("Face Tracker",1);


}

-(IBAction)flipCam:(id)sender{
    NSLog(@"flip cam");
    [self.videoCamera switchCameras];
}

@end
