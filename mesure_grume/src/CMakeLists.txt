PROJECT(mesure_grume)
CMAKE_MINIMUM_REQUIRED(VERSION 2.8)

#required in openCv
FIND_PACKAGE( OpenCV REQUIRED )
INCLUDE_DIRECTORIES( ${OpenCV_INCLUDE_DIRS} )


ADD_EXECUTABLE(mesures main.cpp measures_contour.h measures_contour.cpp  measures_region.cpp measures_region.h orthogonalAxis.h orthogonalAxis.cpp)#

TARGET_LINK_LIBRARIES(mesures ${OpenCV_LIBS})
