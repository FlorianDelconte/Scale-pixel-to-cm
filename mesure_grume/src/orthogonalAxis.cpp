//interne
#include "orthogonalAxis.h"
#include "measures_contour.h"
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
double normLenght;
double diamLenght;
/**
*compute euclidian distance
**/
double euclideanDistance(double x1,double y1,double x2,double y2){
  return sqrt(((x2-x1)*(x2-x1))+((y2-y1)*(y2-y1)));
}
/**
*compute euclidian distance
**/
double Norme1Distance(double x1,double y1,double x2,double y2){
  return abs(x2-x1)+abs(y2-y1);
}
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

  if ((y1 - y2) * (x1 - x3) == (y1 - y3) * (x1 - x2)){

      b=true;
  }
  return b;
}

/**
*Check if the are formed by A,B,C is null
**/
bool areaTriangleNull(int x1, int y1, int x2, int y2, int x3, int y3)
{
  bool b=false;
  int area=((x1*(y2-y3))+(x2*(y3-y1))+(x3*(y1-y2)));
  if (area==0){
      b=true;
  }
  return b;
}
/*int searchIndColinear(vector<Point> contour, Point moelle){
  double max=-1;
  double distance;
  Point currentPoint1,currentPoint2;
  int ind=-1;
  for( int i = 0; i< contour.size(); i++ )
  {
  currentPoint1=contour[0];
  for( int j = 1; j< contour.size(); j++ )
  {
    currentPoint2=contour[j];
    distance=euclideanDistance(currentPoint1.x,currentPoint1.y,currentPoint2.x,currentPoint2.y);
    if(areaTriangleNull(currentPoint1.x,currentPoint1.y,currentPoint2.x,currentPoint2.y,moelle.x,moelle.y) ){
        if(distance>max){
          cout<<"oui le triangle est null"<<j;
          ind=j;
          max=distance;
        }
    }
  }
  return ind;


}*/
/**
*Compute the max diameter going per the moelle in a vector of point and stock corresponding two point distance: Euclidian
**/
void computeEucliDiameter(vector<Point> contour,Point moelle){
  Point currentPoint1,currentPoint2;
  Point selectedPoint1, selectedPoint2;
  bool firstCollinearFind=false;
  double max=-1;
  int indicep1=-1;
  int indicep2=-1;
  double distance;
  int i2 =0;
  //FIND first three point collinear and remember the point indice
  for( size_t i = 0; i< contour.size(); i++ )
  {
    //cout<<"--------------------"<<i<<"\n";
    currentPoint1=contour[i];
    for( size_t j = i2; j< contour.size(); j++ )
    {
      currentPoint2=contour[j];
      //three point are aligned if slope of any pair of point are same as other pair
      if(areaTriangleNull(currentPoint1.x,currentPoint1.y,currentPoint2.x,currentPoint2.y,moelle.x,moelle.y)){
        distance=euclideanDistance(currentPoint1.x,currentPoint1.y,currentPoint2.x,currentPoint2.y);
        if(distance>max){
          selectedPoint1=currentPoint1;
          selectedPoint2=currentPoint2;
          max=distance;
          i2=j;
        }
      }
    }
  }
  diamLenght=max;
  diamPoint1=selectedPoint1;
  diamPoint2=selectedPoint2;
    /*i2=searchIndColinear(contour,moelle);
    currentPoint1=contour[0];
    currentPoint2=contour[i2];
    if(collinear(currentPoint1.x,currentPoint1.y,currentPoint2.x,currentPoint2.y,moelle.x,moelle.y)){
        cout<<"colli";
    }

    for( int i = 0; i< contour.size(); i++ )
    {
      currentPoint1=contour[i];
      currentPoint2=contour[i2];

      distance=euclideanDistance(currentPoint1.x,currentPoint1.y,currentPoint2.x,currentPoint2.y);

      if(collinear(currentPoint1.x,currentPoint1.y,currentPoint2.x,currentPoint2.y,moelle.x,moelle.y)){
        if(distance>max){

          selectedPoint1=currentPoint1;
          selectedPoint2=currentPoint2;
          max=distance;
        }
      }
      i2++;
      if(i2>=contour.size()){
        i2=0;
      }
    }*/
}
/**
*Compute the max diameter going per the moelle in a vector of point and stock corresponding two point distance: Norme1
**/
/*void computeNorme1Diameter(vector<Point> contour,Point moelle){
  Point currentPoint1,currentPoint2;
  Point selectedPoint1, selectedPoint2;
  double max=-1;
  int indicep1=-1;
  int indicep2=-1;
  double distance;
  for( size_t i = 0; i< contour.size(); i++ )
  {
    currentPoint1=contour[i];
    for( size_t j = 0; j< contour.size(); j++ )
    {
      currentPoint2=contour[j];
      //three point are aligned if slope of any pair of point are same as other pair
      if(collinear(currentPoint1.x,currentPoint1.y,currentPoint2.x,currentPoint2.y,moelle.x,moelle.y)){
        distance=Norme1Distance(currentPoint1.x,currentPoint1.y,currentPoint2.x,currentPoint2.y);
        if(distance>max){
          selectedPoint1=contour[i];
          selectedPoint2=contour[j];
          max=distance;
        }
      }
    }
  }
  diamLenght=max;
  diamPoint1=selectedPoint1;
  diamPoint2=selectedPoint2;
}*/
void computeNormal(vector<Point> contour,Mat contourImg,Point moelle){
  //Mat contourImg=makeContourImg(contour,size);
  //les coeficients a et b de la droite passant par les deux points du diametre
  double a = diamPoint2.y - diamPoint1.y;
  double b = diamPoint2.x - diamPoint1.x;
  double c = -(b*moelle.x)-(a*moelle.y);
  //la pente de la droite
  double slope;
  double perpendicular_slope;
  double b_n;
  int rows = contourImg.rows;
  int cols = contourImg.cols;
  int x1;
  int x2;
  int y1;
  int y2;
  if(b!=0 && a!=0){

    slope=a/b;
    perpendicular_slope=-1/slope;
    b_n = moelle.y-(perpendicular_slope*moelle.x);
    x1=0;
    x2=max(rows,cols);
    y1=(perpendicular_slope*x1)+b_n;
    y2=(perpendicular_slope*x2)+b_n;
  }else{
    if(a==0){
      x1=moelle.x;
      x2=moelle.x;
      y1=0;
      y2=rows;
    }
    if(b==0){
      y1=moelle.y;
      y2=moelle.y;
      x1=0;
      x2=cols;
    }
  }
  //la pente de la droite perpendiculaire
  //cout<<"a : "<<a<<"\n";
  //cout<<"b : "<<b<<"\n";
  //cout<<"slope : "<<perpendicular_slope<<"\n";
  //cout<<"biais : "<<b_n;
  //cout<<"p1 : ["<<x1<<";"<<y1<<"]\n";
  //cout<<"p2 : ["<<x2<<";"<<y2<<"]\n";
  LineIterator it(contourImg, Point(x1,y1), Point(x2,y2), 8);
  vector<Point> normal;
  int indiceAddVecteur=0;
  Point pt;
  for(int i = 0; i < it.count; i++, ++it)
  {
      pt= it.pos();
      uchar intensity = contourImg.at<uchar>(pt);
      if(intensity!=0 ){
        //cout<<"coucou";
        normal.push_back(pt);
      }
  }
  normPoint1=normal.front();
  normPoint2=normal.back();
  normLenght=euclideanDistance(normPoint1.x,normPoint1.y,normPoint2.x,normPoint2.y);
}

Axis getOrthogonalAxis(ContourMeasure c, Point moelle){
  Axis a;
  computeEucliDiameter(c.contour,moelle);
  computeNormal(c.contour,c.imgContour,moelle);

  a.diameterPoint1=diamPoint1;
  a.diameterPoint2=diamPoint2;
  a.normalPoint1=normPoint1;
  a.normalPoint2=normPoint2;
  a.diameterLenght=diamLenght;
  a.normalLenght=normLenght;
  return a;
}
