#include <iostream>
#include <cstring>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define size 21

using namespace std;

__global__ void gpuNext(int* env) {
  int x = threadIdx.x;
  int y = threadIdx.y;

  int wrapNorth = ((size + y - 1) % size) * size;
  int wrapSouth = ((size + y + 1) % size) * size;

  int wrapEast = (size + x + 1) % size;
  int wrapWest = (size + x - 1) % size;

  int neighbours =
    env[y * size + wrapEast] + // EAST + MIDDLE
    env[y * size + wrapWest] + // WEST + MIDDLE

    env[wrapNorth + wrapEast] + // EAST + NORTH
    env[wrapNorth + wrapWest] + // WEST + NORTH

    env[wrapSouth + wrapEast] + // EAST + SOUTH
    env[wrapSouth + wrapWest] + // WEST + SOUTH

    env[wrapNorth + x] + // MIDDLE + TOP
    env[wrapSouth + x]; // MIDDLE + BOTTOM

  __syncthreads();

  if(neighbours < 2 || neighbours > 3)
    env[y * size + x] = 0;

  if(neighbours == 3)
    env[y * size + x] = 1;
}

void print(int* env) {
  for(int i = 0; i < size * size; i++) {
    cout << (env[i] ? '#' : ' ');

    if (!(i % size)) cout << endl;
  }
}

int main(){
  bool env[size * size];

  // srand(time(NULL));

  // for (int i = 0; i < size * size; i++) {
  //   env[i] = rand() % 2 == 0;
  // }

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

  cudaMalloc((void**) &dEnv, size * size * sizeof(bool));
  cudaMemcpy(dEnv, env, size * size * sizeof(bool), cudaMemcpyHostToDevice);

  dim3 golThreads(size, size);

  while (true) {
    system("clear");
    gpuNext<<<1, golThreads>>>(dEnv);
    cudaMemcpy(env, dEnv, size * size * sizeof(bool), cudaMemcpyDeviceToHost);
    print(env);
    system("sleep .1");
  }
}