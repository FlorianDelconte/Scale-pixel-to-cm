//intern
#include "measures_region.h"
//extern
#include <iostream>
#include "opencv2/imgproc.hpp"
#include "opencv2/highgui.hpp"
#include <math.h>

using namespace std;
using namespace cv;

//label of components in image
Mat labels;
//some stats on components
Mat stats;
//center of components
Mat centroids;
//index of grume
int index_grume;
/**
*computer area of the biggest component
**/
int getArea(){
  int max=-1;
  int area;
  //Need to start at 1 because 0 is the background
  for(int lab=1; lab<stats.rows; lab++)
  {
    area=stats.at<int>(Point(4,lab));

    if(area>max){
      max=area;
      index_grume=lab;//the biggest (area) connected component is Grume
    }
  }
  return max;
}
/**
*compute center of the biggest component
**/
Point getCenter(){
  int x = centroids.at<double>(index_grume, 0);//X
  int y = centroids.at<double>(index_grume, 1);//Y
  return Point(x,y);
}

RegionMeasure getSurfaceMeasure(Mat img, double scale){
  //init three matrice -> lables,stats,centroids
  connectedComponentsWithStats(img,labels,stats,centroids);
  RegionMeasure s;
  s.areaPix=getArea();//area in pixel
  //cout<<double(s.areaPix)*(scale*scale)<<"\n";
  s.areaCm=double(s.areaPix)*(scale*scale);//area in cm
  s.center=getCenter();//center of grume
  return s;
}
