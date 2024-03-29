#include <iostream>
#include <unistd.h>
#include <mpi.h>
#define size 30

int main(int argc, char ** argv){

  int rank;
  double sum,sum1,sum2,sum3;
  double serie[size],a[size/2+2],b[size/2+2];
  MPI_Init(&argc, &argv);
  double start = MPI_Wtime();
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Request request;
  MPI_Status status;

  if (rank == 0) {


        serie[0] = 1.0;

        int j = 1;

        for (int i=2;j<size;i*=2){

          serie[j] = (double) 1/(i);

          j++;

        }


        for(int i= 0; i<size/2;i++)
          MPI_Send(&serie[i], 1, MPI_DOUBLE, 1, 0, MPI_COMM_WORLD);

        // comentar for abaixo caso nao tenha 3 processos
        for(int i= size/2; i<size-1;i++){
        
          MPI_Send(&serie[i], 1, MPI_DOUBLE, 2, 5, MPI_COMM_WORLD);
        }


        MPI_Recv(&sum, 1, MPI_DOUBLE, 1, 2, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        MPI_Recv(&sum2, 1, MPI_DOUBLE, 2, 3, MPI_COMM_WORLD, MPI_STATUS_IGNORE);

   

        if (sum2 >0.05){
          std::cout  << "Provavelmente é divergente. Caso não seja, ela converge para um valor maior de: "<< sum + sum2 << "\n";
        }else{
          std::cout  << "A serie converge para "<< sum + sum2 << "\n";
        }
       
        
  }

  else if (rank == 1){

        for(int i= 0; i<size/2;i++)
          MPI_Recv(&a[i], 1, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);

         sum1 = 0.0;

         for (int i=0;i< size/2;i++){

            sum1 += a[i];

         }

         MPI_Send(&sum1, 1, MPI_DOUBLE, 0, 2, MPI_COMM_WORLD);
  }

  else if (rank == 2){

        for(int i= 0; i<size/2-1;i++)
          MPI_Recv(&b[i], 1, MPI_DOUBLE, 0, 5, MPI_COMM_WORLD, MPI_STATUS_IGNORE);

          sum3 = 0.0;
         
         for (int i=0;i< size/2;i++){

          sum3 += b[i];

         }


         MPI_Send(&sum3, 1, MPI_DOUBLE, 0, 3, MPI_COMM_WORLD);


  }


  MPI_Finalize();

  return 0;


}
