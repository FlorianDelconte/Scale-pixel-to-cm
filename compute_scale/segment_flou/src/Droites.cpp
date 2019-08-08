//Personal project
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
Droites::Droites()
{ }
/**
*Constructeur de droites. prend un nom de fichier .dat et une couleur en entrée
**/
Droites::Droites(string filenameHorizontales,DGtal::Color c,Board2D &b){
  fileDroites=filenameHorizontales;
  nbDroites=count_nb_colonne(filenameHorizontales)/2;
  colorSegmentFlou=c;
  tabAlphaDroite=makeAllAlphaSegment(b);

}
/**
*Constructeur copy
**/
Droites::Droites(const Droites &d) :fileDroites(d.fileDroites), nbDroites(d.nbDroites), tabAlphaDroite(d.tabAlphaDroite),colorSegmentFlou(d.colorSegmentFlou)
{ }

/**
*Destructeur des tableau de segmentFlou
**/
Droites::~Droites()
{ }
/**
*Compte le nombre de colonne dans un fichier.dat
*retourn le nombre de colonne du fichier
**/
int Droites::count_nb_colonne(string filename){
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
    fichier.close();  // on ferme le fichier
  }else{
    cerr << "Impossible d'ouvrir le fichier des droites !" << endl;
  }
  return cpt;
}

/**
*Fonction qui permet de retirer les couples (-1,-1) dans un vecteur de point
*Retourne le vecteur de point sans les (-1,-1)
**/
vector<Z2i::Point> Droites::clearPoints(vector<Z2i::Point> line)
{
  vector<Z2i::Point> lineCleared;
  Z2i::Point temp;
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
/**
*creation d'un alphasegment a partir d'un vecteur de point
retourne segment flou
**/
AlphaThickSegmentComputer2D Droites::create_sgmflou(vector<Z2i::Point> &contour)
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
/*
*fonction interne permettant d'ajouter un segment flou à un board pour le visualiser
*/
void Droites::addToBoard(AlphaThickSegmentComputer2D &alphaseg,Board2D &aBoard){
  //cout<<colorSegmentFlou<<"\n";
  aBoard << CustomStyle( alphaseg.className(), new CustomColors( colorSegmentFlou, DGtal::Color::None ) );
  aBoard << alphaseg;
}
/**
*Fonction qui permet de lire un fichier .dat 2 colonne par 2 colonne.
*Créer un segment flou pour chaque paire de colonne.
*Retourne un tableau contenant les segment flou.
**/
vector<AlphaThickSegmentComputer2D> Droites::makeAllAlphaSegment(Board2D & aBoard){
  //Lecture du nombre de colonne contenu dans le fichier
  int nbcolonneD=count_nb_colonne(fileDroites);
  //initialisation du segmentFlou
  std::vector<AlphaThickSegmentComputer2D> tabAlphaSegment;
  //initialisation des variables utilisé dans le for
  vector<unsigned int> indiceDroite;
  //le vecteur des points de la droites passé en paramètre
  vector<Z2i::Point> line;
  //le vecteur des points nettoyé des valeurs (-1,-1)
  vector<Z2i::Point> line_cleared;
  //segmentFlou courrant
  AlphaThickSegmentComputer2D lineAlpha_Segment;
  //indice de la droite
  int ind=0;
  //parcours du fichier 2en 2
  for (int i =0;i<nbcolonneD;i=i+2){
    indiceDroite.clear();
    //les indices des colonne courante du fichier
    indiceDroite.push_back(i);//correspond à X
    indiceDroite.push_back(i+1);//correspond à Y
    //creation du vecteur de point (X,Y) de la droite courrante
    line = PointListReader<Z2i::Point>::getPointsFromFile(fileDroites,indiceDroite);
    //netoyage du vecteur (--> retrait des point(-1,-1))
    line_cleared = clearPoints(line);
    if(line_cleared.size()>2){
      //creation du segment flou
      lineAlpha_Segment=create_sgmflou(line_cleared);
      //ajout au vecteur
      tabAlphaSegment.push_back(lineAlpha_Segment);
      //ajout au board pour créer un visuel
      addToBoard(lineAlpha_Segment,aBoard);
      ind++;
    }
  }

  return tabAlphaSegment;
}
/**
*fonction qui calcul la distance eucliedienne entre deux points
**/
double Droites::distanceCalculate_integer(double x1, double y1, double x2, double y2)
{
  double x = x1 - x2; //calculating number to square in next step
  double y = y1 - y2;
  double dist;
  dist = pow(x, 2) + pow(y, 2);       //calculating Euclidean distance
  dist = sqrt(dist);
  return dist;
}
/**
*
**/
vector<double> Droites::computeDistance(Droites otherDroites,Board2D &b){
  vector<double> vecteur_out;
  std::vector<AlphaThickSegmentComputer2D> othersegFlou=otherDroites.getSegFlou();
  //cout<<othersegFlou[0];
  double a_d,a_n;
  double b_d,b_n;
  double mu_d,mu_n;
  double nu_d,nu_n;
  double x_actu;
  double y_actu;
  double x_old;
  double y_old;
  double distance;

  for(int i=0; i< tabAlphaDroite.size(); i++)
  {

    a_d=tabAlphaDroite[i].getNormal()[0];
    b_d=tabAlphaDroite[i].getNormal()[1];
    mu_d=tabAlphaDroite[i].getMu();
    nu_d=tabAlphaDroite[i].getNu()/2;
    x_old=-1;
    y_old=-1;
    for(int j=0; j< othersegFlou.size(); j++)
    {
      a_n=othersegFlou[j].getNormal()[0];
      b_n=othersegFlou[j].getNormal()[1];
      mu_n=othersegFlou[j].getMu();
      nu_n=othersegFlou[j].getNu()/2;
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
            //cout<<"cas3 ";
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
        /*cout<<"DROITES"<<"\n";
        cout<<"a : "<<a_d<<"\n";
        cout<<"b : "<<b_d<<"\n";
        cout<<"mu : "<<mu_d<<"\n";
        cout<<"nu : "<<nu_d<<"\n";
        cout<<"NORMALES"<<"\n";
        cout<<"a : "<<a_n<<"\n";
        cout<<"b : "<<b_n<<"\n";
        cout<<"mu : "<<mu_n<<"\n";
        cout<<"nu : "<<nu_n<<"\n";
        cout<<"X : "<<x_actu<<"\n";
        cout<<"Y : "<<y_actu<<"\n";
        cout<<"distance : "<<distanceCalculate_integer(x_actu,y_actu,x_old,y_old)<<"\n";*/
        distance=distanceCalculate_integer(x_actu,y_actu,x_old,y_old);
        vecteur_out.push_back(distance);
      }
      //maj du point précedant
      x_old=x_actu;
      y_old=y_actu;
      //ajout sur le board
      b.setPenColor(DGtal::Color::Black);
      b.fillCircle(x_actu,y_actu, 1.0);
    }
  }
  return vecteur_out;
}
/*****************************************************************GETTER********************************************************************/
/**
*retourne le nom du fichier
**/
string Droites::getNameFile(){
  return fileDroites;
}
/**
*retoune le nombre de droites dans le fichier
**/
int Droites::getNbDroites(){
  return nbDroites;
}
/**
*retourne un tableau de segment flou
**/
vector<AlphaThickSegmentComputer2D> Droites::getSegFlou(){
  return tabAlphaDroite;
}
/*************************************************************************************************************************************/
//fonction d'affichage des attributs
void Droites::toString(){
  cout<<"--------------------"<<"\n";
  cout<<"nom du fichier traitée : "<<fileDroites<<"\n";
  cout<<"nombre de droites dans le fichier :"<<nbDroites<<"\n";
  cout<<"--------\n";
  /*for(unsigned i=0; i< tabAlphaDroite.size(); i++)
  {
    cout<<"droite : "<<i<<"\n"<<tabAlphaDroite.at(i)<<"\n";
  }*/
}
/**************************************************************************************************************************************/
