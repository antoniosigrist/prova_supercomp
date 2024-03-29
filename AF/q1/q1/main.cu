#include <iostream>
#include <cstring>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>


#define size 21

using namespace std;

__global__ void jogo(bool* env) {
  int x = threadIdx.x;
  int y = threadIdx.y;

  // mapeaia as bordas da posição analisada

  int wrapNorth = ((size + y - 1) % size) * size;
  int wrapSouth = ((size + y + 1) % size) * size;

  int wrapEast = (size + x + 1) % size;
  int wrapWest = (size + x - 1) % size;

  // conta quantos existem
  int count = 0;

  if (env[y * size + wrapEast]) count++;
  if (env[y * size + wrapWest]) count++;
  if (env[wrapNorth + wrapEast]) count ++;
  if (env[wrapNorth + wrapWest]) count++;
  if (env[wrapSouth + wrapEast]) count++;
  if (env[wrapSouth + wrapWest]) count++;
  if (env[wrapNorth + x]) count++;
  if (env[wrapSouth + x]) count++;


  __syncthreads(); //garante que as threads estejam sincronizadas para realizar o calculo de vizinhos vivos


  if(count < 2 || count > 3)
    env[y * size + x] = false;

  if(count == 3)
    env[y * size + x] = true;
}

void print(bool* env) {
  for(int i = 0; i < size * size; i++) {

    cout << (env[i] ? '#' : ' ');

    if (!(i % size)) cout << endl;
  }
}

int main(){

  int parada = 0;

  bool env[size * size]; //linearizei o vetor


  env[ 5*size + 7] = true;
  env[ 6*size + 8] = true;
  env[ 8*size +8] = true;
  env[ 6*size +6] = true;
  env[ 8*size +10] = true;
  env[ 9*size +10] = true;
  env[ 8*size +11] = true;
  env[10*size +11] = true;
  env[10*size +12] = true;

  bool* dEnv;

  cudaMalloc((void**) &dEnv, size * size * sizeof(bool)); //aloca vetor em cuda
  cudaMemcpy(dEnv, env, size * size * sizeof(bool), cudaMemcpyHostToDevice); //copia o vetor para cuda

  dim3 golThreads(size, size); //define tamanho das threads

  while (parada < 100) { //define o numero de parada para 100
    system("clear");
    jogo<<<1, golThreads>>>(dEnv); //chamada do kernel
    cudaMemcpy(env, dEnv, size * size * sizeof(bool), cudaMemcpyDeviceToHost); //copia valor do vetor de volta a cpu
    print(env);

    usleep(100000);

    parada++;
  }
}