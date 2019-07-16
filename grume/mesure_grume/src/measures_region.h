#ifndef DEF_REGION
#define DEF_REGION

#include <iostream>
#include "opencv2/imgproc.hpp"
#include "opencv2/highgui.hpp"
#include <math.h>

struct RegionMeasure
{
  int areaPix;
  cv::Point center;
};
/**
*call all intern function to construct a RegionMeasure
**/
RegionMeasure getSurfaceMeasure(cv::Mat img,double scale);
#endif
