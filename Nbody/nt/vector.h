#ifndef vector_h
#define vector_h

// provide basic calculation methods for vector=====//

#include <cmath>

double dot(double x[], double y[]){
  return x[0]*y[0]+x[1]*y[1]+x[2]*y[2];
}

double module(double x[]){
  return sqrt(x[0]*x[0]+x[1]*x[1]+x[2]*x[2]);
}
  
#endif
