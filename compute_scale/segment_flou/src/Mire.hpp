#ifndef DEF_MIRE
#define DEF_MIRE
//Personal project
#include "Droites.hpp"
//extern
#include "DGtal/helpers/StdDefs.h"
#include "DGtal/base/Common.h"
#include "DGtal/geometry/curves/AlphaThickSegmentComputer.h"
#include "DGtal/io/boards/Board2D.h"
#include "DGtal/io/readers/PointListReader.h"
#include "DGtal/helpers/StdDefs.h"
#include <string>

typedef DGtal::AlphaThickSegmentComputer< DGtal::Z2i::Point > AlphaThickSegmentComputer2D;

class Mire
{
  public:
    /**CONSTRUCTORS**/
    Mire();
    Mire(Droites const&droitesHorizontales, Droites const&droitesVerticales);
    /**DIVERS**/
    double moyenne(std::vector<double> t);
    double variance(std::vector<double> t);
    void filtreEcartType(std::vector<double> &vecDist);
    void filtreCarre(std::vector<double> BeliefVector,std::vector<double> &vecToWork);
    void afficheDistance(std::vector<double> horiDist,std::vector<double> vertiDist);
    double ComputeMoy(double moy_filt_n,double moy_filt_d);
    double computeScale(DGtal::Board2D &b);
    void toString();
    /**GETTERS**/
    double getScaleHorizontale();
    double getScaleVerticale();
    double getScaleMoyenne();
    /**SETTERS**/
    void setDroitesHorizontales(Droites const& h);
    void setDroitesVerticales(Droites const& v);

  private:
    Droites droitesHori;
    Droites droitesVerti;
    double echelle_horizontale,echelle_verticale,echelle_moyenne;
};
#endif
