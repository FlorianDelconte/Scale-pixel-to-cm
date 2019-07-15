//intern
#include "measures_contour.h"
//extern
#include <iostream>
#include <math.h>
#include "opencv2/imgproc.hpp"
#include "opencv2/highgui.hpp"


using namespace cv;
using namespace std;

//the contour of grume
vector<Point> contour;
//list of all contour of connected component
vector<vector<Point>> liste_contour;
//useless
vector<Vec4i> hierarchy;

/**
*Extract contour from shape
**/
void extractContour(Mat img){
  //extract in liste_contour all the contour of connected component --> check findcontour from openCV
  findContours(img, liste_contour, hierarchy, RETR_CCOMP, CHAIN_APPROX_NONE);

  //search the biggest contour
  int currentContourSize;
  int maxSize=-1;
  int max_index=-1;
  for( size_t i = 0; i< liste_contour.size(); i++ )
  {
    currentContourSize=liste_contour.at(i).size();
    if(currentContourSize>maxSize)
    {
      maxSize=currentContourSize;
      max_index=i;
    }
  }
  contour=liste_contour.at(max_index);
}
/**
*Perimeter of a shape is the number of picel in the contour
**/
int computePerimeter(){
  return contour.size();
}

ContourMeasure getContourMeasure(Mat img, double scale){
  ContourMeasure c;
  extractContour(img);
  c.contour=contour;
  c.perimeter=computePerimeter();
  return c;
}
