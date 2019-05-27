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
void makeAllAlphaSegment(Board2D &b,string nameFile,DGtal::Color color,vector<AlphaThickSegmentComputer2D> &allAlphaSeg){

  //Lecture du nombre de droite contenu dans le fichier
  int nbdroite=count_nb_droite(nameFile);
  //initialisation des variables utilisé dans le for
  vector<unsigned int> indiceDroite;
  vector<Z2i::Point> line;
  vector<Z2i::Point> line_cleared;
  AlphaThickSegmentComputer2D lineAlpha_Segment;
  //1 droite = deux colonne dans le fichier = parcours de deux colonne en deux colonne
  for (int i =0;i<nbdroite;i=i+2){
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
    //ajout au vecteur
    allAlphaSeg.push_back(lineAlpha_Segment);
    //cout << lineAlpha_Segment.getMu();
    //Remplissage d'un board pour le visuel
    addToBoard(b,lineAlpha_Segment,color);
  }

}
void makeVisu(Board2D &b, vector<AlphaThickSegmentComputer2D> v, vector<AlphaThickSegmentComputer2D> v_dec)
{

  //cout << v.size();
  AlphaThickSegmentComputer2D lineAlpha_Segment;
  for(std::vector<AlphaThickSegmentComputer2D>::const_iterator it=v.begin(); it!=v.end(); ++it)
  {
    lineAlpha_Segment= *it;
    addToBoard(b,lineAlpha_Segment,DGtal::Color::Red);
  }
  AlphaThickSegmentComputer2D lineAlpha_Segment_dec;
  for(std::vector<AlphaThickSegmentComputer2D>::const_iterator it_dec=v_dec.begin(); it_dec!=v_dec.end(); ++it_dec)
  {
    lineAlpha_Segment_dec= *it_dec;
    addToBoard(b,lineAlpha_Segment_dec,DGtal::Color::Blue);
  }

}
int main(int argc, char** argv)
{
  //creation du boards
  Board2D aBoard;
  //nom du fichier DATA
  string name="huawei_E004B_label";
  //chemin du fichier data
  string naiveLineFilename = pixelLinePath + name +".dat";
  string naiveLine_decFilename = pixelLinePath + name +"_dec.dat";
  //Lecture du nombre de droite contenu dans le fichier
  vector<AlphaThickSegmentComputer2D> allAlphaSegment;
  makeAllAlphaSegment(aBoard,naiveLineFilename,DGtal::Color::Red,allAlphaSegment);
  vector<AlphaThickSegmentComputer2D> allAlphaSegment_dec;
  makeAllAlphaSegment(aBoard,naiveLine_decFilename,DGtal::Color::Blue,allAlphaSegment_dec);
  //ajout des alphaSegment dans le board pour l'affichage
  makeVisu(aBoard,allAlphaSegment,allAlphaSegment_dec);
  aBoard.saveEPS("huawei_E004B_label.eps");

  return 0;
}
