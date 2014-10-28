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

- (IBAction)trackerStart:(id)sender {
    NSLog(@"tracker start");
    [self.videoCamera start];
    
   // [self processOneImage];
}

-(IBAction)flipCam:(id)sender {
    NSLog(@"flip cam");
    [self.videoCamera switchCameras];
}

void Draw(cv::Mat &image,cv::Mat &shape,cv::Mat &con,cv::Mat &tri,cv::Mat &visi) {
    int i,n = shape.rows/2; cv::Point p1,p2; cv::Scalar c;
    
    //draw triangulation
    c = CV_RGB(0,0,0);
    for(i = 0; i < tri.rows; i++){
        if(visi.at<int>(tri.at<int>(i,0),0) == 0 ||
           visi.at<int>(tri.at<int>(i,1),0) == 0 ||
           visi.at<int>(tri.at<int>(i,2),0) == 0)continue;
        p1 = cv::Point(shape.at<double>(tri.at<int>(i,0),0),
                       shape.at<double>(tri.at<int>(i,0)+n,0));
        p2 = cv::Point(shape.at<double>(tri.at<int>(i,1),0),
                       shape.at<double>(tri.at<int>(i,1)+n,0));
        cv::line(image,p1,p2,c);
        p1 = cv::Point(shape.at<double>(tri.at<int>(i,0),0),
                       shape.at<double>(tri.at<int>(i,0)+n,0));
        p2 = cv::Point(shape.at<double>(tri.at<int>(i,2),0),
                       shape.at<double>(tri.at<int>(i,2)+n,0));
        cv::line(image,p1,p2,c);
        p1 = cv::Point(shape.at<double>(tri.at<int>(i,2),0),
                       shape.at<double>(tri.at<int>(i,2)+n,0));
        p2 = cv::Point(shape.at<double>(tri.at<int>(i,1),0),
                       shape.at<double>(tri.at<int>(i,1)+n,0));
        cv::line(image,p1,p2,c);
    }
    //draw connections
    c = CV_RGB(0,0,255);
    for(i = 0; i < con.cols; i++){
        if(visi.at<int>(con.at<int>(0,i),0) == 0 ||
           visi.at<int>(con.at<int>(1,i),0) == 0)continue;
        p1 = cv::Point(shape.at<double>(con.at<int>(0,i),0),
                       shape.at<double>(con.at<int>(0,i)+n,0));
        p2 = cv::Point(shape.at<double>(con.at<int>(1,i),0),
                       shape.at<double>(con.at<int>(1,i)+n,0));
        cv::line(image,p1,p2,c,1);
    }
    //draw points
    for(i = 0; i < n; i++){
        if(visi.at<int>(i,0) == 0)continue;
        p1 = cv::Point(shape.at<double>(i,0),shape.at<double>(i+n,0));
        c = CV_RGB(255,0,0); cv::circle(image,p1,2,c);
    }return;
}

-(void)processOneImage{
    //doesn't compile with this uncommented
    /*
    UIImage *image;
    
    //parse command line arguments
    char ftFile[256],conFile[256],triFile[256];
    bool fcheck = false; double scale = 1; int fpd = -1; bool show = true;
    
    //set other tracking parameters
    std::vector<int> wSize1(1); wSize1[0] = 7;
    std::vector<int> wSize2(3); wSize2[0] = 11; wSize2[1] = 9; wSize2[2] = 7;
    int nIter = 5; double clamp=3,fTol=0.01;
    
    //initialize camera and display window
    cv::Mat frame,gray,im; double fps=0; char sss[256]; std::string text;
    CvCapture* camera = cvCreateCameraCapture(CV_CAP_ANY); //how do I capture from my video camera?
    int64 t1,t0 = cvGetTickCount(); int fnum=0;
    //cvNamedWindow("Face Tracker",1); //dont need a window name
    
    FACETRACKER::Tracker model(ftFile);
    cv::Mat tri=FACETRACKER::IO::LoadTri(triFile);
    cv::Mat con=FACETRACKER::IO::LoadCon(conFile);
    
    bool failed = true;
    //grab image, resize and flip
    IplImage* I = cvQueryFrame(camera); //do I need to pass in a CvCapture camera or can I use a CvVideoCamera?
    //frame = I; //why can't frame = I?
    
    if(scale == 1){
        im = frame;
    }
    else {
        cv::resize(frame,im,cv::Size(scale*frame.cols,scale*frame.rows));
    }
    cv::flip(im,im,1); cv::cvtColor(im,gray,CV_BGR2GRAY);
    
    //track this image
    std::vector<int> wSize; if(failed)wSize = wSize2; else wSize = wSize1;
    if(model.Track(gray,wSize,fpd,nIter,clamp,fTol,fcheck) == 0){
        int idx = model._clm.GetViewIdx(); failed = false;
        Draw(im,model._shape,con,tri,model._clm._visi[idx]);
    }else{
        if(show){
            cv::Mat R(im,cvRect(0,0,150,50)); R = cv::Scalar(0,0,255);
        }
        model.FrameReset(); failed = true;
    }
    //draw framerate on display image
    if(fnum >= 9){
        t1 = cvGetTickCount();
        fps = 10.0/((double(t1-t0)/cvGetTickFrequency())/1e+6);
        t0 = t1; fnum = 0;
    }
    else{
        fnum += 1;
    }
    if(show){
        sprintf(sss,"%d frames/sec",(int)round(fps)); text = sss;
        cv::putText(im,text,cv::Point(10,20), CV_FONT_HERSHEY_SIMPLEX,0.5,CV_RGB(255,255,255));
    }
*/
}

@end
