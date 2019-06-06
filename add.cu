// Exemplo para o curso de Super Computacao
// Criado por: Luciano P. Soares
// atualizado em: 15/04/2019

#include <iostream>

/* Rotina para somar dois vetores na GPU */ 
__global__ void add(double *a, double *b, double *c, int N) {
   int i=blockIdx.x*blockDim.x+threadIdx.x;
   if(i<N) {   // Importante checar valor do i pois pode acessar fora do tamanho do vetor
      c[i] = a[i] + b[i];
   }
}

/* Programa cria dois vetores e soma eles em GPU */
int main() {

   double *h_a, *h_b, *h_c;
   double *d_a, *d_b, *d_c;
   int    blocksize, i, n;

   cudaError_t error;

   n=1<<23;

   // Aloca vetores na memoria da CPU
   h_a = (double *)malloc(n*sizeof(double));
   h_b = (double *)malloc(n*sizeof(double));
   h_c = (double *)malloc(n*sizeof(double));

   // Preenche os vetores
   for (i = 0; i < n; i++) {
    h_a[i] = (double)i;
    h_b[i] = (double)n-i;
   }

   // Aloca vetores na memoria da GPU
   error = cudaMalloc((void **)&d_a,n*sizeof(double));
   if(error!=cudaSuccess) {
      std::cout << "Memory Allocation CUDA failure " << __FILE__ << ":" << __LINE__ << ": '" << cudaGetErrorString(error) << "'\n";
      exit(EXIT_FAILURE);
   }

   error = cudaMalloc((void **)&d_b,n*sizeof(double));
   if(error!=cudaSuccess) {
      std::cout << "Memory Allocation CUDA failure " << __FILE__ << ":" << __LINE__ << ": '" << cudaGetErrorString(error) << "'\n";
      exit(EXIT_FAILURE);
   }

   error = cudaMalloc((void **)&d_c,n*sizeof(double));
   if(error!=cudaSuccess) {
      std::cout << "Memory Allocation CUDA failure " << __FILE__ << ":" << __LINE__ << ": '" << cudaGetErrorString(error) << "'\n";
      exit(EXIT_FAILURE);
   }


   // Copia valores da CPU para a GPU
   error = cudaMemcpy(d_a, h_a, n*sizeof(double), cudaMemcpyHostToDevice);
   if(error!=cudaSuccess) {
      std::cout << "Memory Copy CUDA failure " << __FILE__ << ":" << __LINE__ << ": '" << cudaGetErrorString(error) << "'\n";
      exit(EXIT_FAILURE);
   }

   error = cudaMemcpy(d_b, h_b, n*sizeof(double), cudaMemcpyHostToDevice);
   if(error!=cudaSuccess) {
      std::cout << "Memory Copy CUDA failure " << __FILE__ << ":" << __LINE__ << ": '" << cudaGetErrorString(error) << "'\n";
      exit(EXIT_FAILURE);
   }

   // Realiza calculo na GPU
   blocksize = 256;
   add<<<((n-1)/256 + 1),blocksize>>>(d_a,d_b,d_c,n);

   // Retorna valores da memoria da GPU para a CPU
   error = cudaMemcpy(h_c, d_c, n*sizeof(double), cudaMemcpyDeviceToHost);
   if(error!=cudaSuccess) {
      std::cout << "Memory Copy CUDA failure " << __FILE__ << ":" << __LINE__ << ": '" << cudaGetErrorString(error) << "'\n";
      exit(EXIT_FAILURE);
   }

   // Libera memoria da GPU
   cudaFree(d_a);
   cudaFree(d_b);
   cudaFree(d_c);

   // Exibe um resultado para checar se valores conferem
   std::cout.precision(7);
   for(i=0;i<n;i++) {
      if(!(i%(n/8))) {
         std::cout << "a[" << i << "] + b[" << i << "] = c[" << i << "]  =>  ";
         std::cout << h_a[i] << " + " << h_b[i] << " = " << h_c[i] << std::endl;
      }
   }
   
   // Libera memoria da CPU
   free(h_a);
   free(h_b);
   free(h_c);

   return 0;
}
