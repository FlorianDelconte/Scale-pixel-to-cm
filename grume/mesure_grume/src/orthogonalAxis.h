#ifndef DEF_AXIS
#define DEF_AXIS
//intern
#include "measures_contour.h"
//extern
#include <iostream>
#include "opencv2/imgproc.hpp"
#include "opencv2/highgui.hpp"
#include <math.h>

struct Axis
{
  cv::Point diameterPoint1;
  cv::Point diameterPoint2;
  //lenght of diameter in pixel --> use Norme2
  double diameterLenght;
  cv::Point normalPoint1;
  cv::Point normalPoint2;
  //lenght of normal in pixel --> use Norme2
  double normalLenght;
};
/**
*Call intern fonction to create Axis and return it
*s=1 : Distance norme1 used
*s=2 : Distance norme2 used
**/
Axis getOrthogonalAxis(ContourMeasure c, cv::Point moelle,int s);


#endif
