#ifndef DEF_AXIS
#define DEF_AXIS

#include <iostream>
#include "opencv2/imgproc.hpp"
#include "opencv2/highgui.hpp"
#include <math.h>

struct Axis
{
  cv::Point diameterPoint1;
  cv::Point diameterPoint2;
  cv::Point normalPoint1;
  cv::Point normalPoint2;
};
/**
*Call intern fonction to create Axis and return it
**/
Axis getOrthogonalAxis(std::vector<cv::Point> contour, cv::Point moelle,cv::Point size);

#endif
