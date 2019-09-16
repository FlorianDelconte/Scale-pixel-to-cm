#include <iostream>
#include <fstream>
#include <stdio.h>
#include <string.h>
#include "Mire.hpp"
#include "Droites.hpp"
//DGTAl
#include "DGtal/helpers/StdDefs.h"
#include "DGtal/base/Common.h"
#include "DGtal/geometry/curves/AlphaThickSegmentComputer.h"
#include "DGtal/io/boards/Board2D.h"
#include "DGtal/io/readers/PointListReader.h"
#include "DGtal/helpers/StdDefs.h"
//BOOST
#include <boost/filesystem.hpp>
#include <boost/regex.hpp>

using namespace std;
using namespace DGtal;

struct path_leaf_string
{
    std::string operator()(const boost::filesystem::directory_entry& entry) const
    {
        return entry.path().leaf().string();
    }
};

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
    cerr << "Impossible d'ouvrir le fichier pour écrire !" << endl;
  }
}
void read_directory(string& path, vector<std::string>& v)
{
    //tous les fichier du repertoire path
    boost::filesystem::path p(path);
    //on prend pas les fichier avec un _dec
    boost::regex pattern("^((?!_dec).)*$");
    //parcours pour check si la regex match
    for (boost::filesystem::directory_iterator iter(p),end; iter!=end; ++iter) {
      string name = iter->path().leaf().string();
      if(name!=".gitkeep"){
        name = name.substr(0, name.size()-4);
        if (regex_match(name, pattern)){
           //file_abs_name = dir_abs_name + name;
           v.push_back(name);
        }
      }
    }

}

int main(int argc, char** argv)
{
  string pixelLinePath="../../PIXELS/";
  string fileToWriteHorizontal="../../SCALE/echelle_computed_horizontal.txt";
  string fileToWriteVertical="../../SCALE/echelle_computed_vertical.txt";
  string fileToWriteMoyenne="../../SCALE/echelle_computed_moyenne.txt";
  if(argc==1){
    //lecture des fichier dans le repertoire (...)PIXELS/
    vector<string> list_of_file_name;
    read_directory(pixelLinePath, list_of_file_name);
    for(vector<string>::const_iterator it=list_of_file_name.begin(); it!=list_of_file_name.end(); ++it)
    {
      //nom du fichier DATA
      string name_input  = *it;
      //Board pour créer le visuel
      Board2D aBoard;
      //nom du fichier EPS + conversion string to char
      string output = "../src/visu_EPS/"+name_input+".eps";
      char name_output[output.size() + 1];
      strcpy(name_output, output.c_str());
      //nom des fichier de lecture
      string dataFileDroitesHorizontales = pixelLinePath + name_input +".dat";
      cout<<dataFileDroitesHorizontales<<"\n";
      string dataFileDroitesVerticales = pixelLinePath + name_input +"_dec.dat";
      //creation des Droites de la mire. Red=droites HORIZONTALES | Blue=droites verticales
      Droites droitesHorizontales(dataFileDroitesHorizontales,DGtal::Color::Red,aBoard);
      Droites droitesVerticales(dataFileDroitesVerticales,DGtal::Color::Blue,aBoard);
      //creéation de la mire
      Mire mire(droitesHorizontales,droitesVerticales);
      //calcul de l'échelle
      mire.computeScale(aBoard);
      //WRITE SCALE
      writeFile(name_input,mire.getScaleHorizontale(),fileToWriteHorizontal);
      //writeFile(name_input,mire.getScaleVerticale(),fileToWriteVertical);
      //writeFile(name_input,mire.getScaleMoyenne(),fileToWriteMoyenne);
      //WRITE EPS
      aBoard.saveEPS(name_output);
    }
  }else{
    //nom du fichier DATA
    string name_input  = argv[1];
    //Board pour créer le visuel
    Board2D aBoard;
    //nom du fichier EPS + conversion string to char
    string output = "visu_EPS/"+name_input+".eps";
    char name_output[output.size() + 1];
    strcpy(name_output, output.c_str());
    //nom des fichier de lecture
    string dataFileDroitesHorizontales = pixelLinePath + name_input +".dat";
    cout<<dataFileDroitesHorizontales<<"\n";
    string dataFileDroitesVerticales = pixelLinePath + name_input +"_dec.dat";
    //creation des Droites de la mire. Red=droites HORIZONTALES | Blue=droites verticales
    Droites droitesHorizontales(dataFileDroitesHorizontales,DGtal::Color::Red,aBoard);
    Droites droitesVerticales(dataFileDroitesVerticales,DGtal::Color::Blue,aBoard);
    //creéation de la mire
    Mire mire(droitesHorizontales,droitesVerticales);
    //calcul de l'échelle
    mire.computeScale(aBoard);
    //mire.toString();
    //WRITE SCALE
    writeFile(name_input,mire.getScaleHorizontale(),fileToWriteHorizontal);
    //writeFile(name_input,mire.getScaleVerticale(),fileToWriteVertical);
    //writeFile(name_input,mire.getScaleMoyenne(),fileToWriteMoyenne);
    //WRITE EPS
    aBoard.saveEPS(name_output);
  }

  return 0;
}
