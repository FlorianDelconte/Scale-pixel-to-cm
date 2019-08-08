//Personal project
#include "Mire.hpp"
#include "Droites.hpp"
//extern
#include "DGtal/helpers/StdDefs.h"
#include "DGtal/base/Common.h"
#include "DGtal/geometry/curves/AlphaThickSegmentComputer.h"
#include "DGtal/io/boards/Board2D.h"
#include "DGtal/io/readers/PointListReader.h"
#include "DGtal/helpers/StdDefs.h"


using namespace std;
using namespace DGtal;
using namespace DGtal::Z2i;

typedef AlphaThickSegmentComputer< Z2i::Point > AlphaThickSegmentComputer2D;
/**
*Constructeur vide
**/
Mire::Mire(){}
/**
*Constructeur de mire, prend en paramètre deux Droites.
**/
Mire::Mire(Droites const& droitesHorizontales, Droites const& droitesVerticales): droitesHori(droitesHorizontales), droitesVerti(droitesVerticales)
{}
//fonction d'affichage des attributs
void Mire::toString(){
  droitesHori.toString();
  droitesVerti.toString();
  cout<<"echelle horizontales"<<echelle_horizontale<<"\n";
  cout<<"echelle verticales"<<echelle_verticale<<"\n";
  cout<<"echelle moyenne"<<echelle_moyenne<<"\n";
}
void Mire::afficheDistance(vector<double> horiDist,vector<double> vertiDist){
  cout<<"----AFFICHAGE DES DISTANCES----\n";
  cout<<"HORIZONTALES"<<"\n";
  int taille=horiDist.size();
  for(int i=0; i<taille; ++i)
  {
    cout<<"distance : "<<horiDist[i]<<"\n";
  }
  cout<<"VERTICALES"<<"\n";
  taille=vertiDist.size();
  for(int i=0; i<taille; ++i)
  {
    cout<<"distance : "<<vertiDist[i]<<"\n";
  }
}


/**
*Cette fonction retourne la moyenne d'un vecteur.
*retourne -1 si le vecteur est vide
**/
double Mire::moyenne(vector<double> t)
{
  //valeur par défaut
  double moyenne=0;
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
  }else{
    moyenne=-1;
  }
  return moyenne;
}
/**
*Calcul la variance d'un vecteur. si la moyenne de se vecteur est nulle, retourne -1
**/
double Mire::variance(vector<double> t)
{
  double m=moyenne(t);
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
/**
*Permet de filtrer les outsider (utilisé sur les droite horisontales)
**/
void Mire::filtreEcartType(vector<double> &vecDist)
{
  double moy=moyenne(vecDist);
  double vari=variance(vecDist);
  double ecartType=sqrt(vari);

  vector<double> vecDist_filtered;
  int taille=vecDist.size();
  //parcours des disctance pour remplie une liste d'indice à supprimer
  //un distance est à supprimer si son écart à la moyenne est supérieur à l'écart type
  for(int i=0; i<taille; ++i)
  {
    vari=vecDist[i]-moy;
    vari=(vari*vari);
    vari=sqrt(vari);
    //si l'écart à la moyenne courrant est inférieur à l'écart type
    if(vari<ecartType)
    {
      //on garde la distance : on l'ajoute au vecteur de distance quon retourne
      vecDist_filtered.push_back(vecDist[i]);
    }
  }
  vecDist=vecDist_filtered;
}

/**
*filtre les distance verticales selon la moyenne des distance horizontales
**/
void Mire::filtreCarre(vector<double> BeliefVector,vector<double> &vecDist)
{
  //moyenne du vecteur de distance cru
  double moyenne_d=moyenne(BeliefVector);
  //le vecteur des distance filtree
  vector<double> vecDist_filtered;
  //taille du vecteur des distances
  int taille=vecDist.size();
  //seuil écart à la moyenne
  double seuil=(moyenne_d/100)*15;
  //initialisation de la variable de distance courrante
  double currentDist;
  //parcours des distances
  for(int i=0; i<taille; ++i)
  {
    //distance courante
    currentDist=vecDist[i];
    //si la distance est comprise entre la moyenne et son seuil, on accepte
    if(currentDist>=moyenne_d-seuil && currentDist<=moyenne_d+seuil)
    {
      vecDist_filtered.push_back(currentDist);
    }

  }
  vecDist=vecDist_filtered;
}
/**
*Calcul la moyenne entre deux distance, si une des deux distance est nulle retourne l'autre
**/
double Mire::ComputeMoy(double moy_filt_n,double moy_filt_d){
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
double Mire::getScaleHorizontale(){
  return echelle_horizontale;
}
double Mire::getScaleVerticale(){
  return echelle_verticale;
}
double Mire::getScaleMoyenne(){
  return echelle_moyenne;
}
/*
*Fonction qui calcul l'echelle à partir de deux attribut droites
*/
double Mire::computeScale(Board2D &b){
  //Calcul les distances entre Droite Horizontales/droites Verticales
  vector<double> distanceHori=droitesHori.computeDistance(droitesVerti, b);
  //Calcul les distances entre droite verticales/droites horizontales
  vector<double> distanceVerti=droitesVerti.computeDistance(droitesHori, b);
  //filtre des distances horizontales par écart type
  filtreEcartType(distanceHori);
  //filtre des distance verticales en prenant en compte que la mire est constitué de carré
  filtreCarre(distanceHori,distanceVerti);
  echelle_horizontale=moyenne(distanceHori);
  echelle_verticale=moyenne(distanceVerti);
  echelle_moyenne=ComputeMoy(echelle_verticale,echelle_horizontale);
}
/**
*Setter droitesHori
**/
void Mire::setDroitesHorizontales(Droites const& h){
  droitesHori=h;
}
/**
*Setter droitesVerti
**/
void Mire::setDroitesVerticales(Droites const& v){
  droitesVerti=v;
}
