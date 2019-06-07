#include <iostream>
#include <unistd.h>
#define size 25

int main(int argc, char ** argv){

  int rank, a[100], b[50];
  MPI_Init(&argc, &argv);
  double start = MPI_Wtime();
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);



  double serie[size];

  serie[0] = 1.0;

  int j = 1;

  for (int i=2;j<size;i*=2){

    std::cout << i << " " << i << "\n" ;
    serie[j] = (double) 1/(i);
    j++;

  }

  double sum = 0;

  for(int i =0; i<size;i++){
    std::cout << serie[i] << "\n" ;
    sum += serie[i];

  }

  

  std::cout << "Converge para: "<< sum << "\n" ;


}
