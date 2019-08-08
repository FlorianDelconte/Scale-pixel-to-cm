//intern
#include "measures_region.h"
#include "measures_contour.h"
#include "orthogonalAxis.h"
//extern
#include <iostream>
#include "opencv2/imgproc.hpp"
#include "opencv2/highgui.hpp"
#include <math.h>
#include <bits/stdc++.h>

using namespace std;
using namespace cv;
//distance between geometric center and moelle in cm
double centerDistance;
//Area in cm*cm
double area;
//perimeter in cm
double perimeter;
//lenght of diameter in cm
double lenghtDiam;
//lenghtof normal of diameter in cm
double lenghtNormal;
//image for display measure
Mat image_measures;
//reel square lenght
int cote_carre;
/*******************************************INPUT***************************************/
//input scale in cm per pixel
double scale;
//input image
Mat image_souce;
//input center moelle
Point moelle;
/*******************************************COLOR***************************************/
//color for moelle center
Scalar colorMoelle= Scalar( 0, 0, 255 );
//color for moelle center
Scalar colorCenterGeometrics= Scalar( 255, 0, 0 );
//color for contour shape
Vec3b colorContour=Vec3b(0,255,0);
//color for contour shape
Scalar colorDiameter= Scalar( 150, 250, 255 );
//color for contour shape
Scalar colorNormal= Scalar( 100, 150, 155 );

/**
*Compute measure in cm thanks to the scale
**/
void computeMeasureInCm(RegionMeasure regionM,ContourMeasure contourM,Axis a){
  area=((double)regionM.areaPix)*(scale*scale);
  perimeter=((double)contourM.perimeter)*scale;
  lenghtDiam=a.diameterLenght*scale;
  lenghtNormal=a.normalLenght*scale;
  centerDistance=(sqrt(((moelle.x-regionM.center.x)*(moelle.x-regionM.center.x))+((moelle.y-regionM.center.y)*(moelle.y-regionM.center.y))))*scale;
}
/**
*add a point to image measure
**/
void addPoint(Point p,Scalar color){
  circle(image_measures, p, 20, color, 1, 4, 0);
  drawMarker(image_measures, p, color);
}
/**
*draw Point per Point the contour of grume
**/
void DrawContour(Mat imgContour,Vec3b color){
  insertChannel(imgContour,image_measures,1);
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
  /**TERMINAL**/
  cout<<"\n"<<"distance between geometric center and moelle :" <<centerDistance<<" cm";
  cout<<"\n"<<"perimeter :" <<perimeter<<" cm";
  cout<<"\n"<<"area :" <<area<<" cm²";
  cout<<"\n"<<"diameter lenght :" <<lenghtDiam<<" cm";
  cout<<"\n"<<"normal lenght :" <<lenghtNormal<<" cm\n";
  /**GRAPHICS**/
  DrawContour(contourM.imgContour,colorContour);
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

}

int main(int argc, char** argv)
{
  clock_t start, end;
  start = clock();
  /****************ARGUMENTS GESTION **********************************************************/
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
  threshold(image_souce, image_souce, 0, 255, CV_THRESH_BINARY | CV_THRESH_OTSU);
  scale=cote_carre/atof(argv[2]);
  /***************MEASURES********************************************************************/
  RegionMeasure r=getSurfaceMeasure(image_souce,scale);
  ContourMeasure c=getContourMeasure(image_souce,scale);
  Axis a = getOrthogonalAxis(c,moelle);
  
  computeMeasureInCm(r,c,a);
  display(r,c,a);
  end = clock();
  double time_taken = double(end - start)/ double(CLOCKS_PER_SEC);
  cout<< "Time taken by program is : " << fixed
      <<time_taken << setprecision(5);
  cout<< " sec " << endl;
  /**************WRITE MEASURE IN TXT FILE***************************************************/

  /**************WRITE JPG to check *********************************************************/
  imwrite( "imgSave/mesures.png", image_measures );
  imwrite( "imgSave/images.png", image_souce );
  return 0;
}
