#include <iostream>
#include <fstream>
#include <math.h>
#include "ConfigExamples.h"
#include "DGtal/helpers/StdDefs.h"
#include "DGtal/base/Common.h"
#include "DGtal/geometry/curves/AlphaThickSegmentComputer.h"
#include "DGtal/io/boards/Board2D.h"
#include "DGtal/io/readers/PointListReader.h"
#include "DGtal/helpers/StdDefs.h"
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <bits/stdc++.h>
using namespace DGtal;
using namespace DGtal::Z2i;
using namespace std;

typedef AlphaThickSegmentComputer< Z2i::Point > AlphaThickSegmentComputer2D;
//const string fileToWriteHorizontal="../build/echelle_computed_horizontal.txt";
//const string fileToWriteVertical="../build/echelle_computed_vertical.txt";

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
      //calcul de point d'intersection : 4 cas possible
      //CAS 1
      if(b_d!=0 && b_n!=0){
        //cout<<"cas1";
        x_actu=(((-mu_d-nu_d)/b_d)+((mu_n+nu_n)/b_n))/((-a_d/b_d)+(a_n/b_n));
        y_actu=(mu_d+nu_d-(a_d*x_actu))/(b_d);
      }else{
        //CAS 2
        if(b_d==0 && b_n==0){
          //cout<<"cas2";
          x_actu=(mu_d-mu_n+nu_d-nu_n)/(a_d-a_n);
          y_actu=(mu_d+nu_d-(a_d*x_actu))/(b_d);
        }else{
          //CAS 3
          if(b_d==0 && b_n!=0){
            x_actu=(mu_d+nu_d)/a_d;
            y_actu=(mu_n+nu_n-(a_n*x_actu))/(b_n);
            //cout<<"cas3 "<<x_actu<<"  "<< a_d*x_actu<<"\n";
          }else{
            //CAS 4
            if(b_d!=0 && b_n==0){
              //cout<<"cas4";
              x_actu=(mu_n+nu_n)/a_n;
              y_actu=(mu_d+nu_d-(a_d*x_actu))/(b_d);
            }
          }
        }
      }
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
/**
*Cette fonction retourne la moyenne d'un vecteur.
*retourne -1 si le vecteur est vide
**/
double moyenne(vector<double> t)
{
  //valeur par défaut
  double moyenne=-1;
  int taille=t.size();
  //on vérifie que le vecteur n'a pas une taille à 0
  if(taille!=0)
  {
    for(int i=0; i<taille; ++i)
    {
      //cout<<"distance : "<<t[i]<<"\n";
      moyenne+=t[i];
    }
    moyenne=moyenne/taille;
  }
  return moyenne;
}
/**
*Calcul la variance d'un vecteur. si la moyenne de se vecteur est nulle, retourne -1
**/
double variance(double m,vector<double> t)
{
  double vari=-1;
  if(m!=-1){
    vari=0;
    int taille=t.size();
    double currentEcart;
    for(int i=0; i<taille; ++i)
    {
      currentEcart=t[i]-m;
      vari+=(currentEcart*currentEcart);
    }
    vari=vari/taille;
  }
  return vari;
}
void writeFile(string imgFile,double distance1cm,string fileToWrite)
{
  ofstream fichier(fileToWrite, ios::out | ios::app);
  if(fichier)
  {
    fichier<<imgFile<<" "<<distance1cm<<endl;
    fichier.close();
  }
  else
  {
    cerr << "Impossible d'ouvrir le fichier !" << endl;
  }
}

void filtreEcartType(double ecartType,double moyenne, vector<double> &vecDist)
{
  /*
  *Les carré des la mire sur lesquelles nous mesurons les distances disposé toujours à la mlêm distance.
  *On peux donc filtrer les distance dont lécart à la moyenne  est supérieur à l'écart type.
  */
  vector<double> vecDist_filtered;
  int taille=vecDist.size();
  double vari;
  //parcours des disctance pour remplie une liste d'indice à supprimer
  //un distance est à supprimer si son écart à la moyenne est supérieur à l'écart type
  for(int i=0; i<taille; ++i)
  {
    vari=vecDist[i]-moyenne;
    vari=(vari*vari);
    vari=sqrt(vari);
    //si l'écart à la moyenne courrant est inférieur à l'écart type
    if(vari<ecartType)
    {
      //on garde la distance : on l'ajoute au vecteur de distance quon retourne
      vecDist_filtered.push_back(vecDist[i]);
    }
  }
  //cout<<"----------"<<"\n";
  vecDist=vecDist_filtered;
}
void filtreCarre(double moyenne,vector<double> &vecDist)
{
  /*
  *Comme la mire est constitué de carré, on sait qu'en moyenne, les distance horizontales et vverticales seront proches
  *On peux donc filté les distance verticales par la moyenne des distance horizontales. Car les distance horizontales sont plus sûr.
  */
  //le vecteur des distance filtree
  vector<double> vecDist_filtered;
  //taille du vecteur des distances
  int taille=vecDist.size();
  //seuil écart à la moyenne
  double seuil=(moyenne/100)*15;
  //initialisation de la variable de distance courrante
  double currentDist;
  //parcours des distances
  //cout<<taille;
  for(int i=0; i<taille; ++i)
  {
    //distance courante
    currentDist=vecDist[i];
    //cout<<currentDist<<"\n";
    //si la distance est comprise entre la moyenne et son seuil, on accepte
    if(currentDist>=moyenne-seuil && currentDist<=moyenne+seuil)
    {
      vecDist_filtered.push_back(currentDist);
    }

  }
  vecDist=vecDist_filtered;
}
/**
*Calcul la moyenne entre deux distance, si une des deux distance est nulle retourne l'autre
**/
double ComputeMoy(double moy_filt_n,double moy_filt_d){
  double moy_filtered_m;
  if(moy_filt_n==-1 && moy_filt_d==-1){
    moy_filtered_m=-1;
  }else{
    if(moy_filt_d==-1){
      moy_filtered_m=moy_filt_n;
    }else{
      if(moy_filt_n==-1){
        moy_filtered_m=moy_filt_d;
      }else{
        moy_filtered_m=(moy_filt_d+moy_filt_n)/2;
      }
    }
  }
  return moy_filtered_m;
}

int main(int argc, char** argv)
{
  string fileToWriteHorizontal="../build/echelle_computed_horizontal.txt";
  string fileToWriteVertical="../build/echelle_computed_vertical.txt";
  string fileToWriteMoyenne="../build/echelle_computed_moyenne.txt";
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
  //vecteur qui contient les longueur des coté des carré horizontal
  vector<double> vecteur_dist_horizontal;
  drawIntersec(aBoard,tabAlphaDroite,nbDroite,tabAlphaNormal,nbNormal,vecteur_dist_horizontal);
  //vecteur qui contient les longueur des coté des carré vertical
  vector<double> vecteur_dist_vertical;
  drawIntersec(aBoard,tabAlphaNormal,nbNormal,tabAlphaDroite,nbDroite,vecteur_dist_vertical);


  //***************************STATISTIQUES*************************************//
  /***********droite HORIZONTALES*/
  int taille=vecteur_dist_horizontal.size();
  double moy_d=moyenne(vecteur_dist_horizontal);//droite horizontal
  double min_d =*min_element(vecteur_dist_horizontal.begin(), vecteur_dist_horizontal.end());
  double max_d =*max_element(vecteur_dist_horizontal.begin(), vecteur_dist_horizontal.end());
  double var_d=variance(moy_d,vecteur_dist_horizontal);
  double ecartType_d=sqrt(var_d);
  /*filtrage par ecart type*/
  filtreEcartType(ecartType_d,moy_d,vecteur_dist_horizontal);//filtre des distance par rapport à l'écart type
  double moy_filtered_d=moyenne(vecteur_dist_horizontal);
  double ecarType_filtered_d;
  if(variance(moy_filtered_d,vecteur_dist_horizontal)!=-1){
    ecarType_filtered_d=sqrt(variance(moy_filtered_d,vecteur_dist_horizontal));
  }else{
    ecarType_filtered_d=-1;
  }
  /************droite VERTICAL*/
  double moy_n=moyenne(vecteur_dist_vertical);//droite vertical
  double min_n =*min_element(vecteur_dist_vertical.begin(), vecteur_dist_vertical.end());
  double max_n =*max_element(vecteur_dist_vertical.begin(), vecteur_dist_vertical.end());
  double var_n=variance(moy_n,vecteur_dist_vertical);
  double ecartType_n=sqrt(var_n);
  /*filtrage carré*/
  //filtreEcartType(ecartType_n,moy_n,vecteur_dist_vertical);//filtre des distance par rapport à l'écart type
  filtreCarre(moy_filtered_d,vecteur_dist_vertical);//filtre des distance par la moyenne des distance horizontales
  double moy_filtered_n=moyenne(vecteur_dist_vertical);
  double ecarType_filtered_n;
  if(variance(moy_filtered_n,vecteur_dist_vertical)!=-1){
    ecarType_filtered_n=sqrt(variance(moy_filtered_n,vecteur_dist_vertical));
  }else{
    ecarType_filtered_n=-1;
  }
  /**************MOYENNE*/
  double moy_filtered_m=ComputeMoy(moy_filtered_n,moy_filtered_d);//moyenne des distance moyennes filtrées des deux type de droites
  double moy_m=ComputeMoy(moy_d,moy_n);//moyenne des distance moyennes des deux droites
  /*echelle*/
  int nb_pixel_per_cm_d=moy_filtered_d+0.5;//distance horizontal
  double cm_per_pixel_d=cote/moy_filtered_d;
  int nb_pixel_per_cm_n=moy_filtered_n+0.5;//distance vertical
  double cm_per_pixel_n=cote/moy_filtered_n;
  int nb_pixel_per_cm_m=moy_filtered_m+0.5;//moyenne des deux
  double cm_per_pixel_m=cote/moy_filtered_m;
  //écriture dans le fichier
  writeFile(name_input,moy_filtered_d,fileToWriteHorizontal);
  writeFile(name_input,moy_filtered_n,fileToWriteVertical);
  writeFile(name_input,moy_filtered_m,fileToWriteMoyenne);

/******************************AFFICHAGE*****************************************/
  cout<<"DROITE HORIZONTALE-------------------\n";
  cout<<"DISTANCE MOYENNE : "<<moy_d<<" FILTREE : "<<moy_filtered_d<<"\n";
  cout<<"ECART TYPE : "<<ecartType_d<<" FILTREE : "<<ecarType_filtered_d<<"\n";
  cout<<"1 CM = "<<nb_pixel_per_cm_d<<" pixels\n";
  cout<<"1 PIXEL = "<<cm_per_pixel_d<<" cm\n";

  cout<<"DROITE VERTICALE-------------------\n";
  cout<<"DISTANCE MOYENNE : "<<moy_n<<" FILTREE: "<<moy_filtered_n<<"\n";
  cout<<"ECART TYPE : "<<ecartType_n <<" FILTREE : "<<ecarType_filtered_n<<"\n";
  cout<<"1 CM = "<<nb_pixel_per_cm_n<<" pixels\n";
  cout<<"1 PIXEL = "<<cm_per_pixel_n<<" cm\n";

  cout<<"DROITE MOYENNE-------------------\n";
  cout<<"DISTANCE MOYENNE : "<<moy_m <<" FILTREE: "<<moy_filtered_m<<"\n";;
  cout<<"1 CM = "<<nb_pixel_per_cm_m<<" pixels\n";
  cout<<"1 PIXEL = "<<cm_per_pixel_m<<" cm\n";
  /*****************************SAVE**********************************************/
  aBoard.saveEPS(name_output);
  return 0;
}
