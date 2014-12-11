//
//  ViewController.m
//  FaceTracker_iOS
//
//  Created by George Georgaklis on 9/14/14.
//  Copyright (c) 2014 George Georgaklis. All rights reserved.
//

#import "ViewController.hpp"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *trackFaceView;

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
    
    faceView = nil;
    rightEye = nil;
    leftEyeView = nil;
    mouth = nil;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

void getGray(const cv::Mat& input, cv::Mat& gray) {
    cv::cvtColor(input, gray, cv::COLOR_BGR2GRAY);
}

#pragma mark - Protocol CvVideoCameraDelegate

#ifdef __cplusplus
- (void)processImage:(Mat&)image {
    //NSLog(@"process image");
    // Do some OpenCV stuff with the image
    Mat image_copy;
    cvtColor(image, image_copy, CV_BGRA2BGR);
    
    //invert image
    bitwise_not(image_copy, image_copy);
    cvtColor(image_copy, image, CV_BGR2BGRA);
    
    //    UIImage *img = [self UIImageFromCVMat:image];
    //    [self markFaces:img];
}
#endif
#pragma mark - UI Actions

- (IBAction)trackerStart:(id)sender {
    
    NSLog(@"tracker start");
    [self.videoCamera start];
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

-(void)processOneImage:(cv::Mat)img {
    //parse command line arguments
    //char ftFile[256],conFile[256],triFile[256];
    bool fcheck = false; int fpd = -1; bool show = true;
    
    //set other tracking parameters
    std::vector<int> wSize1(1); wSize1[0] = 7;
    std::vector<int> wSize2(3); wSize2[0] = 11; wSize2[1] = 9; wSize2[2] = 7;
    int nIter = 5; double clamp=3,fTol=0.01;
    
    cv::Mat gray;
    
    //load files into strings
    std::istringstream ftFile(face_tracker);
    std::istringstream triFile(face_tri);
    std::istringstream conFile(face_con);
    
    //18 linker errors here
    FACETRACKER::Tracker model("FaceTracker"); //what does this do?
    cv::Mat tri = FACETRACKER::IO::LoadTriString(triFile);
    cv::Mat con = FACETRACKER::IO::LoadConString(conFile);
    
    //track this image
    //convert input image to gray scale
    cv::cvtColor(img,gray,CV_BGR2GRAY);
    
    if(model.Track(gray,wSize1,fpd,nIter,clamp,fTol,fcheck) == 0){
        int idx = model._clm.GetViewIdx();
        //walk the data structure filled in by the track model
        Draw(img,model._shape,con,tri,model._clm._visi[idx]);
    }else{
        if(show){
            cv::Mat R(img,cvRect(0,0,150,50)); R = cv::Scalar(0,0,255);
        }
    }
}

- (cv::Mat)cvMatFromUIImage:(UIImage *)image {
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat {
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

//iOS face marker
-(void)markFaces:(UIImage *)uiimage {
    // draw a CI image with the previously loaded face detection picture
    CIImage* image = [CIImage imageWithCGImage:uiimage.CGImage];
    // create a face detector - since speed is not an issue we'll use a high accuracy
    // detector
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy]];
    // create an array containing all the detected faces from the detector
    NSArray* features = [detector featuresInImage:image];
    
    // we'll iterate through every detected face. CIFaceFeature provides us
    // with the width for the entire face, and the coordinates of each eye
    // and the mouth if detected. Also provided are BOOL's for the eye's and
    // mouth so we can check if they already exist.
    for(CIFaceFeature* faceFeature in features) {
        NSLog(@"for faceFeature in features");
        // get the width of the face
        CGFloat faceWidth = faceFeature.bounds.size.width;
        
        // create a UIView using the bounds of the face
        if(!faceView) {
            faceView = [[UIView alloc] initWithFrame:faceFeature.bounds];
        }
        else {
            faceView.bounds = faceFeature.bounds;
        }
        
        // add a border around the newly created UIView
        faceView.layer.borderWidth = 1;
        faceView.layer.borderColor = [[UIColor redColor] CGColor];
        
        // add the new view to create a box around the face
        [videoView addSubview:faceView];
        if(faceFeature.hasLeftEyePosition) {
            NSLog(@"has left eye position");
            // create a UIView with a size based on the width of the face
            if(!leftEyeView) {
                leftEyeView = [[UIView alloc] initWithFrame:CGRectMake(faceFeature.leftEyePosition.x-faceWidth*0.15, faceFeature.leftEyePosition.y-faceWidth*0.15, faceWidth*0.3, faceWidth*0.3)];
            }
            else {
                leftEyeView.bounds = CGRectMake(faceFeature.leftEyePosition.x-faceWidth*0.15, faceFeature.leftEyePosition.y-faceWidth*0.15, faceWidth*0.3, faceWidth*0.3);
            }
            // change the background color of the eye view
            [leftEyeView setBackgroundColor:[[UIColor blueColor] colorWithAlphaComponent:0.3]];
            // set the position of the leftEyeView based on the face
            [leftEyeView setCenter:faceFeature.leftEyePosition];
            // round the corners
            leftEyeView.layer.cornerRadius = faceWidth*0.15;
            // add the view to the window
            [videoView addSubview:leftEyeView];
        }
        
        if(faceFeature.hasRightEyePosition) {
            NSLog(@"has right eye position");
            // create a UIView with a size based on the width of the face
            if(!rightEye) {
                rightEye = [[UIView alloc] initWithFrame:CGRectMake(faceFeature.rightEyePosition.x-faceWidth*0.15, faceFeature.rightEyePosition.y-faceWidth*0.15, faceWidth*0.3, faceWidth*0.3)];
            }
            else {
                rightEye.bounds = CGRectMake(faceFeature.rightEyePosition.x-faceWidth*0.15, faceFeature.rightEyePosition.y-faceWidth*0.15, faceWidth*0.3, faceWidth*0.3);
            }
            // change the background color of the eye view
            [rightEye setBackgroundColor:[[UIColor blueColor] colorWithAlphaComponent:0.3]];
            // set the position of the rightEyeView based on the face
            [rightEye setCenter:faceFeature.rightEyePosition];
            // round the corners
            rightEye.layer.cornerRadius = faceWidth*0.15;
            // add the new view to the window
            [videoView addSubview:rightEye];
        }
        if(faceFeature.hasMouthPosition) {
            NSLog(@"has mouth position");
            // create a UIView with a size based on the width of the face
            if(!mouth) {
                mouth = [[UIView alloc] initWithFrame:CGRectMake(faceFeature.mouthPosition.x-faceWidth*0.2, faceFeature.mouthPosition.y-faceWidth*0.2, faceWidth*0.4, faceWidth*0.4)];
            }
            else {
                mouth.bounds = CGRectMake(faceFeature.mouthPosition.x-faceWidth*0.2, faceFeature.mouthPosition.y-faceWidth*0.2, faceWidth*0.4, faceWidth*0.4);
            }
            // change the background color for the mouth to green
            [mouth setBackgroundColor:[[UIColor greenColor] colorWithAlphaComponent:0.3]];
            // set the position of the mouthView based on the face
            [mouth setCenter:faceFeature.mouthPosition];
            // round the corners
            mouth.layer.cornerRadius = faceWidth*0.2;
            // add the new view to the window
            [videoView addSubview:mouth];
        }
    }
}

@end
