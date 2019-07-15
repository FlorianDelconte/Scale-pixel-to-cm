//intern
#include "measures_region.h"
#include "measures_contour.h"
#include "orthogonalAxis.h"
//extern
#include <iostream>
#include "opencv2/imgproc.hpp"
#include "opencv2/highgui.hpp"
#include <math.h>

using namespace std;
using namespace cv;

//scale in cm per pixel
double scale;
//image source
Mat image_souce;
//image for measure
Mat image_measures;
//reel square lenght
int cote_carre;
//center of moelle grume
Point moelle;
//color for moelle center
Scalar colorMoelle= Scalar( 0, 0, 255 );
//color for moelle center
Scalar colorCenterGeometrics= Scalar( 255, 0, 0 );
//color for contour shape
Vec3b colorContour=Vec3b(0,255,0);
//color for contour shape
Scalar colorDiameter= Scalar( 255, 255, 255 );
//color for contour shape
Scalar colorNormal= Scalar( 0, 200, 200 );
/**
*add a point to image measure
**/
void addPoint(Point p,Scalar color){
  circle(image_measures, p, 20, color, 1, 8, 0);
  drawMarker(image_measures, p, color);
}
/**
*draw Point per Point the contour of grume
**/
void DrawContour(vector<Point> c,Vec3b color){
  for(int i=0;i<c.size();i++)
  {
      image_measures.at<Vec3b>(c[i].y,c[i].x)=color;
  }
}
/**
*add a line to image measure
**/
void DrawLine(Point p1,Point p2,Scalar color){
  line(image_measures, p1,p2, color, 1, 8, 0);
}
/**
*Display two windows : One for images source, One for image measure
**/
void display(RegionMeasure regionM,ContourMeasure contourM,Axis a){
  DrawContour(contourM.contour,colorContour);
  DrawLine(a.diameterPoint1,a.diameterPoint2,colorDiameter);
  DrawLine(a.normalPoint1,a.normalPoint2,colorNormal);
  addPoint(moelle,colorMoelle);
  addPoint(regionM.center,colorCenterGeometrics);
  namedWindow( "image treshold", WINDOW_NORMAL );
  resizeWindow("image treshold", 800,800);
  imshow( "image treshold", image_souce );
  namedWindow( "image measures", WINDOW_NORMAL );
  resizeWindow("image measures", 800,800);
  imshow( "image measures", image_measures );
  waitKey(0);
  imwrite( "imgSave/mesures.jpg", image_measures );
  imwrite( "imgSave/images.jpg", image_souce );
}

int main(int argc, char** argv)
{
  /****************GESTION ARGUMENTS**********************************************************/
  cote_carre=1;
  moelle=Point(atoi(argv[3]),atoi(argv[4]));
  if( argc != 5)
  {
    cout <<"arg1: Path img  arg2: scale arg3: X moelle arg4: Y moelle" << endl;
    return -1;
  }
  image_souce = imread(argv[1],0);
  if(!image_souce.data )
  {
      cout <<  "Could not open or find the image" << endl ;
      return -1;
  }

  image_measures = Mat::zeros(image_souce.size(), CV_8UC3 );
  scale=cote_carre/atof(argv[2]);

  /***************MEASURES********************************************************************/
  RegionMeasure r=getSurfaceMeasure(image_souce,scale);
  ContourMeasure c=getContourMeasure(image_souce,scale);//1 normae1

  Axis a = getOrthogonalAxis(c.contour, moelle,image_souce.size());

  display(r,c,a);
}
