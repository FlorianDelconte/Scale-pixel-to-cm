//interne
#include "orthogonalAxis.h"
//externe
#include <iostream>
#include "opencv2/imgproc.hpp"
#include "opencv2/highgui.hpp"
#include <math.h>

using namespace cv;
using namespace std;

Point diamPoint1;
Point diamPoint2;
Point normPoint1;
Point normPoint2;
/**
*Create a binary img of contour
**/
Mat makeContourImg(vector<Point> c, Point size){
  Mat contourImg=Mat::zeros(size, CV_8U );
  for(int i=0;i<c.size();i++)
  {
      contourImg.at<uchar>(c[i].y,c[i].x)=255;
  }
  return contourImg;
}

/**
*Check if three point are aligned
**/
bool collinear(int x1, int y1, int x2, int y2, int x3, int y3)
{
  bool b=false;
  if ((y3 - y2) * (x2 - x1) == (y2 - y1) * (x3 - x2)){
      b=true;
  }
  return b;
}
/**
*Compute the max diameter going per the moelle in a vector of point and complet an global Axis
**/
void computeMaxDiameterNorme1(vector<Point> contour,Point moelle ){
  Point currentPoint1,currentPoint2;
  Point selectedPoint1, selectedPoint2;
  int max=-1;
  int indicep1=-1;
  int indicep2=-1;
  int distance;
  for( size_t i = 0; i< contour.size(); i++ )
  {
    currentPoint1=contour[i];
    for( size_t j = 0; j< contour.size(); j++ )
    {
      currentPoint2=contour[j];
      //three point are aligned if slope of any pair of point are same as other pair
      if(collinear(currentPoint1.x,currentPoint1.y,currentPoint2.x,currentPoint2.y,moelle.x,moelle.y)){
        //distance=abs(currentPoint2.x-currentPoint1.x)+abs(currentPoint2.y-currentPoint1.y);
        distance=sqrt(((currentPoint2.x-currentPoint1.x)*(currentPoint2.x-currentPoint1.x))+((currentPoint2.y-currentPoint1.y)*(currentPoint2.y-currentPoint1.y)));
        if(distance>max){
          selectedPoint1=contour[i];
          selectedPoint2=contour[j];
          max=distance;
        }
      }
    }
  }
  diamPoint1=selectedPoint1;
  diamPoint2=selectedPoint2;

}
void computeNormal(vector<Point> contour,Point moelle,Point size){
  Mat contourImg=makeContourImg(contour,size);
  //les coeficients a et b de la droite passant par les deux points du diametre
  double a = diamPoint2.y - diamPoint1.y;
  double b = diamPoint2.x - diamPoint1.x;
  double c = -(b*moelle.x)-(a*moelle.y);
  //la pente de la droite
  double slope =a/b;
  //la pente de la droite perpendiculaire
  double perpendicular_slope=-1/slope;
  double b_n = moelle.y-(perpendicular_slope*moelle.x);
  int rows = contourImg.rows;
  int cols = contourImg.cols;

  int x1=0;
  int x2=max(rows,cols);
  int y1;
  int y2;
  y1=(perpendicular_slope*x1)+b_n;
  y2=(perpendicular_slope*x2)+b_n;
  cout<<perpendicular_slope;
  LineIterator it(contourImg, Point(x1,y1), Point(x2,y2), 8);
  vector<Point> normal;
  int indiceAddVecteur=0;
  Point pt;
  for(int i = 0; i < it.count; i++, ++it)
  {
      pt= it.pos();
      uchar intensity = contourImg.at<uchar>(pt);
      if(intensity!=0 ){
        normal.push_back(pt);
      }
  }
  normPoint1=normal.front();
  normPoint2=normal.back();
}


Axis getOrthogonalAxis(vector<Point> contour, Point moelle,Point size){
  Axis a;
  //construit une image binaire du contour
  computeMaxDiameterNorme1(contour,moelle);
  computeNormal(contour,moelle,size);
  a.diameterPoint1=diamPoint1;
  a.diameterPoint2=diamPoint2;
  a.normalPoint1=normPoint1;
  a.normalPoint2=normPoint2;
  //cout<<normPoint1<<"\n"<<normPoint2;
  return a;
}
