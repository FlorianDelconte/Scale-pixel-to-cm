#include <iostream>
#include "ConfigExamples.h"
#include "DGtal/helpers/StdDefs.h"
#include "DGtal/base/Common.h"
#include "DGtal/geometry/curves/AlphaThickSegmentComputer.h"
#include "DGtal/io/boards/Board2D.h"
#include "DGtal/io/readers/PointListReader.h"
using namespace std;
using namespace DGtal;
int main(  )
{
  trace.beginBlock ( "Example exampleAlphaThickSegment" );
  typedef FreemanChain<Z2i::Space::Integer>::ConstIterator FCConstIterator;
  typedef  AlphaThickSegmentComputer< Z2i::Point, FCConstIterator > AlphaThickSegmentComputer2D;
  Board2D aBoard;
  // Reading input contour
  std::string freemanChainFilename = examplesPath + "samples/contourS.fc";
  fstream fst;
  fst.open (freemanChainFilename.c_str(), ios::in);
  FreemanChain<Z2i::Space::Integer> fc(fst);
  fst.close();
  aBoard << fc;
  //construction of an AlphaThickSegmentComputer2D from the freemanchain iterator
  AlphaThickSegmentComputer2D anAlphaSegment(15), anAlphaSegment2(5), anAlphaSegment3(2);
  anAlphaSegment.init(fc.begin());
  while (anAlphaSegment.end() != fc.end() &&
         anAlphaSegment.extendFront()) {
  }
  aBoard << anAlphaSegment;
  // Example of thickness definition change: usin the euclidean thickness definition.
  AlphaThickSegmentComputer2D anAlphaSegment2Eucl(5, functions::Hull2D::EuclideanThickness);
  anAlphaSegment2Eucl.init(fc.begin());
  while (anAlphaSegment2Eucl.end() != fc.end() &&
         anAlphaSegment2Eucl.extendFront()) {
  }
  aBoard << CustomStyle( anAlphaSegment2Eucl.className(),
                         new CustomColors( DGtal::Color(20, 250, 255), DGtal::Color::None ) );
  aBoard << anAlphaSegment2Eucl;
  anAlphaSegment2.init(fc.begin());
  while (anAlphaSegment2.end() != fc.end() && anAlphaSegment2.extendFront()) {
  }
  aBoard  << CustomStyle( anAlphaSegment2.className(), new CustomColors( DGtal::Color::Blue, DGtal::Color::None ) );
  aBoard << anAlphaSegment2;
  FCConstIterator fcIt = fc.begin();
  while (anAlphaSegment3.extendFront(*fcIt)) {
    fcIt++;
  }
  aBoard  << CustomStyle( anAlphaSegment3.className(), new CustomColors( DGtal::Color::Green, DGtal::Color::None ) );
  aBoard << anAlphaSegment3;
  aBoard.saveEPS("exampleAlphaThickSegment.eps");
  trace.endBlock();
  return 0;
}
