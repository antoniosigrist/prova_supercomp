#include <iostream>
#include <unistd.h>
#include <mpi.h>
#define size 100000

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

        for (int i=2;j<size;i++){

          serie[j] = (double) 1/(i);
          j++;

        }

        //envia para 1
        for(int i= 0; i<size/2;i++)
          MPI_Send(&serie[i], 1, MPI_DOUBLE, 1, 0, MPI_COMM_WORLD);

        // envia para 2
        for(int i= size/2; i<size-2;i++){
           std::cout  << "Dado processo 2 "<< serie[i] << "\n";
          MPI_Send(&serie[i], 1, MPI_DOUBLE, 2, 5, MPI_COMM_WORLD);
        }


        MPI_Recv(&sum, 1, MPI_DOUBLE, 1, 2, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        MPI_Recv(&sum2, 1, MPI_DOUBLE, 2, 3, MPI_COMM_WORLD, MPI_STATUS_IGNORE);

        //MPI_Wait(&request, &status);

        if (sum2 >0.5){
          std::cout  << "Provavelmente a serie é divergente. Caso não seja, ela converge para um valor maior que: "<< sum + sum2 << "\n";
          std::cout  << "Foram somados "<< size<< "elementos até aqui";
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

          std::cout  << "Sum processo 1 "<< sum1 << "\n";
         MPI_Send(&sum1, 1, MPI_DOUBLE, 0, 2, MPI_COMM_WORLD);
  }

  else if (rank == 2){

        for(int i= 0; i<size/2-2;i++)
          MPI_Recv(&b[i], 1, MPI_DOUBLE, 0, 5, MPI_COMM_WORLD, MPI_STATUS_IGNORE);

          sum3 = 0.0;
         
         for (int i=0;i< size/2;i++){

          sum3 += b[i];

         }

         std::cout  << "Sum processo 2 "<< sum3 << "\n";

         MPI_Send(&sum3, 1, MPI_DOUBLE, 0, 3, MPI_COMM_WORLD);


  }


  MPI_Finalize();

  return 0;


}
