#ifndef DEF_DROITES
#define DEF_DROITES
#include "DGtal/helpers/StdDefs.h"
#include "DGtal/base/Common.h"
#include "DGtal/geometry/curves/AlphaThickSegmentComputer.h"
#include "DGtal/io/boards/Board2D.h"
#include "DGtal/io/readers/PointListReader.h"
#include "DGtal/helpers/StdDefs.h"
#include <string>

typedef DGtal::AlphaThickSegmentComputer< DGtal::Z2i::Point > AlphaThickSegmentComputer2D;

class Droites
{
   public:
     Droites();
     Droites(std::string filenameHorizontales,DGtal::Color c,DGtal::Board2D &b);
     Droites(Droites const& d);
     ~Droites();
     int count_nb_colonne(std::string filename);
     void init_tab();
     std::vector<DGtal::Z2i::Point> clearPoints(std::vector<DGtal::Z2i::Point> line);
     AlphaThickSegmentComputer2D create_sgmflou(std::vector<DGtal::Z2i::Point> &contour);
     std::vector<AlphaThickSegmentComputer2D> makeAllAlphaSegment(DGtal::Board2D &b);
     double distanceCalculate_integer(double x1, double y1, double x2, double y2);
     std::vector<double> computeDistance(Droites d,DGtal::Board2D &b);
     void addToBoard(AlphaThickSegmentComputer2D &alphaseg,DGtal::Board2D &b);
     void toString();
     /**GETTERS**/
     std::string getNameFile();
     int getNbDroites();
     std::vector<AlphaThickSegmentComputer2D> getSegFlou();


   private:
     //couleur associé aux droites
     DGtal::Color colorSegmentFlou;
     //nom du fichier contenant les pixels des droites
     std::string fileDroites;
     ///nombre de droites
     int nbDroites;
     //segments Flou associé pixels des droites
     std::vector<AlphaThickSegmentComputer2D> tabAlphaDroite;
};


#endif
