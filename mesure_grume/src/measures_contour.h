#ifndef DEF_CONTOUR
#define DEF_CONTOUR

#include <iostream>
#include "opencv2/imgproc.hpp"
#include "opencv2/highgui.hpp"
#include <math.h>

struct ContourMeasure
{
  std::vector<cv::Point> contour;
  //perimeter in pixel
  int perimeter;
  cv::Mat imgContour;
};


/**
*call all intern fonction to construct a ContourMeasure
**/
ContourMeasure getContourMeasure(cv::Mat img, double scale);
#endif
