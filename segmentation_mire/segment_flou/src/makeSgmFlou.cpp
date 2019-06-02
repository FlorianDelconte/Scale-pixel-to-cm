#include <iostream>
#include "ConfigExamples.h"
#include "DGtal/helpers/StdDefs.h"
#include "DGtal/base/Common.h"
#include "DGtal/geometry/curves/AlphaThickSegmentComputer.h"
#include "DGtal/io/boards/Board2D.h"
#include "DGtal/io/readers/PointListReader.h"
#include "DGtal/helpers/StdDefs.h"
#include <stdio.h>
#include <string.h>
#include <bits/stdc++.h>
using namespace DGtal;
using namespace DGtal::Z2i;
using namespace std;

typedef AlphaThickSegmentComputer< Z2i::Point > AlphaThickSegmentComputer2D;


int count_nb_droite (string filename)
{
  int cpt=0;
  ifstream fichier(filename, ios::in);  // on ouvre le fichier en lecture
  if(fichier){
    string ligne;
    getline(fichier, ligne);
    char lignec[ligne.size()+1];
    strcpy(lignec,ligne.c_str());
    //cout << ligne << endl;
    char * c=strtok(lignec," ");

    while(c != NULL){
      cpt++;
      c=strtok(NULL," ");
    }
    //cout << cpt << endl;
    //strtok
    fichier.close();  // on ferme le fichier
  }else{
    cerr << "Impossible d'ouvrir le fichier des droites !" << endl;
  }
  return cpt;
}
AlphaThickSegmentComputer2D create_sgmflou(vector<Z2i::Point> &contour)
{
  //construction of vector iterator
  std::vector<Z2i::Point>::const_iterator idebut = contour.begin();
  std::vector<Z2i::Point>::const_iterator ifin = contour.end();
  //construction of an AlphaThickSegmentComputer2D
  AlphaThickSegmentComputer2D anAlphaSegment(50);
  anAlphaSegment.init(idebut);
  while (anAlphaSegment.end() != ifin && anAlphaSegment.extendFront()) {
  }
  return anAlphaSegment;
}

vector<Z2i::Point> clearPoints(vector<Z2i::Point> line)
{
  vector<Z2i::Point> lineCleared;
  Z2i::Point temp;
  //line.erase(remove(line.begin(), line.end(),(-1,-1)), line.end());
  for(std::vector<Z2i::Point>::const_iterator it=line.begin(); it!=line.end(); ++it)
  {
      temp = *it;
      if(temp[0]!=-1)
      {
        lineCleared.push_back(Point(temp[0],-temp[1]));
      }
  }
  return lineCleared;
}
void addToBoard(Board2D &bo, AlphaThickSegmentComputer2D &alphaseg,DGtal::Color color){
  bo << CustomStyle( alphaseg.className(), new CustomColors( color, DGtal::Color::None ) );
  bo << alphaseg;

}
void makeAllAlphaSegment(Board2D &b,string nameFile,DGtal::Color color,AlphaThickSegmentComputer2D *tabAlphadroite){

  //Lecture du nombre de droite contenu dans le fichier
  int nbcolonneD=count_nb_droite(nameFile);
  //initialisation des variables utilisé dans le for
  vector<unsigned int> indiceDroite;
  vector<Z2i::Point> line;
  vector<Z2i::Point> line_cleared;
  AlphaThickSegmentComputer2D lineAlpha_Segment;
  //1 droite = deux colonne dans le fichier = parcours de deux colonne en deux colonne
  int ind=0;
  for (int i =0;i<nbcolonneD;i=i+2){
    //indice des colonne X|Y dans le fichier
    indiceDroite.clear();
    indiceDroite.push_back(i);
    indiceDroite.push_back(i+1);
    //creation du vecteur de point (X,Y) de la droite courrante
    line = PointListReader<Z2i::Point>::getPointsFromFile(nameFile,indiceDroite);
    //netoyage du vecteur (--> retrait des point(-1,-1)
    line_cleared = clearPoints(line);
    //creation du segment flou
    lineAlpha_Segment=create_sgmflou(line_cleared);
    //ajout au tableau
    tabAlphadroite[ind]=lineAlpha_Segment;
    //Remplissage d'un board pour le visuel
    addToBoard(b,lineAlpha_Segment,color);
    ind++;
  }
}
double distanceCalculate_integer(double x1, double y1, double x2, double y2)
{
	double x = x1 - x2; //calculating number to square in next step
	double y = y1 - y2;
	double dist;
//  int distance;

	dist = pow(x, 2) + pow(y, 2);       //calculating Euclidean distance
	dist = sqrt(dist);
//  distance = dist + 0.5;
	return dist;
}
void drawIntersec(Board2D &b,AlphaThickSegmentComputer2D * d,int nbdroite,AlphaThickSegmentComputer2D * n,int nbnormal, vector<double> &vec_out)
{
  double a_d,a_n;
  double b_d,b_n;
  double mu_d,mu_n;
  double nu_d,nu_n;
  double x_actu;
  double y_actu;
  double x_old;
  double y_old;
  double distance;

  for(int i=0; i< nbdroite; i++)
  {
    a_d=d[i].getNormal()[0];
    b_d=d[i].getNormal()[1];
    mu_d=d[i].getMu();
    nu_d=d[i].getNu()/2;
    x_old=-1;
    y_old=-1;
    for(int j=0; j< nbnormal; j++)
    {
      a_n=n[j].getNormal()[0];
      b_n=n[j].getNormal()[1];
      mu_n=n[j].getMu();
      nu_n=n[j].getNu()/2;
      //calcul de point d'intersection
      x_actu=(((-mu_d-nu_d)/b_d)+((mu_n+nu_n)/b_n))/((-a_d/b_d)+(a_n/b_n));
      y_actu=(mu_d+nu_d-(a_d*x_actu))/(b_d);
      //TODO : check si b=0 ou a=0;
      //on calcul la distance qu'a partir du deuxiemme point
      if(x_old!=-1 && y_old!=-1){
        distance=distanceCalculate_integer(x_actu,y_actu,x_old,y_old);
        vec_out.push_back(distance);
      }
      //maj du point précedant
      x_old=x_actu;
      y_old=y_actu;
      //print on board (facultatif)
      b.setPenColor(DGtal::Color::Black);
      b.fillCircle(x_actu,y_actu, 1.0);
    }
  }
}
double moyenne(vector<double> t)
{
  double moyenne=0.0;
  int taille=t.size();
  for(int i=0; i<taille; ++i)
  {
    //cout<<"distance : "<<t_dist[j]<<"\n";
    moyenne+=t[i];
  }
  return moyenne/taille;
}

double variance(double m,vector<double> t)
{
  double vari=0.0;
  int taille=t.size();
  for(int i=0; i<taille; ++i)
  {
    ecart=t[i]-m;
    //cout<<"distance : "<<t_dist[j]<<"\n";
    vari+=(ecart*ecart);
  }
  return vari=ecart/t
}
int main(int argc, char** argv)
{
  //longueur d'un coté de carré de la mire
  int cote=1;
  //creation du boards
  Board2D aBoard;
  //nom du fichier DATA
  string name_input  = argv[1];
  //nom du fichier output (+conversion string to char)
  string output = name_input+".eps";
  char name_output[output.size() + 1];
	strcpy(name_output, output.c_str());
  //chemin du fichier data
  string naiveLineFilename = pixelLinePath + name_input +".dat";
  string naiveLine_decFilename = pixelLinePath + name_input +"_dec.dat";
  //Lecture du nombre de droite contenu dans le fichier
  int nbDroite=count_nb_droite(naiveLineFilename)/2;
  int nbNormal=count_nb_droite(naiveLine_decFilename)/2;
  //tableau des alphasegment sur les longue droites
  AlphaThickSegmentComputer2D tabAlphaDroite[nbDroite];
  makeAllAlphaSegment(aBoard,naiveLineFilename,DGtal::Color::Red,tabAlphaDroite);
  //tableau des alphasegment sur les droite ortho
  AlphaThickSegmentComputer2D tabAlphaNormal[nbNormal];
  makeAllAlphaSegment(aBoard,naiveLine_decFilename,DGtal::Color::Blue,tabAlphaNormal);
  //vecteur qui contient les longueur des coté des carré le long des longues droites
  vector<double> vecteur_dist_long;
  drawIntersec(aBoard,tabAlphaDroite,nbDroite,tabAlphaNormal,nbNormal,vecteur_dist_long);
  //vecteur qui contient les longueur des coté des carré le long des droite orthogonal
  //double t_ortho[taille_tab];
  //drawIntersec(aBoard,tabAlphaNormal,nbNormal,tabAlphaDroite,nbDroite,t_ortho);
  //***************************STATISTIQUES*************************************//
  double moy_d=moyenne(vecteur_dist_long);
  double min_d =*min_element(vecteur_dist_long.begin(), vecteur_dist_long.end());
  double max_d =*max_element(vecteur_dist_long.begin(), vecteur_dist_long.end());
  double variance=variance(moy_d,vecteur_dist_long)
  int nb_pixel_per_cm=moy_d+0.5;
  double cm_per_pixel=cote/moy_d;
/******************************AFFICHAGE*****************************************/
  cout<<"DISTANCE MOYENNE : "<<moy_d<<"\n";
  cout<<"DISTANCE MAX : "<<max_d<<"\n";
  cout<<"DISTANCE MIN : "<<min_d<<"\n";
  cout<<"1 CM = "<<nb_pixel_per_cm<<" pixels\n";
  cout<<"1 PIXEL = "<<cm_per_pixel<<" cm\n";
  /*****************************SAVE**********************************************/
  aBoard.saveEPS(name_output);

  return 0;
}
