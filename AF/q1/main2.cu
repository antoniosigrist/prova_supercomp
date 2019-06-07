#include <iostream>
#include <cstring>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define HEIGHT 32
#define WIDTH 32

using namespace std;

__global__ void gpuNext(int* env) {
  int x = threadIdx.x;
  int y = threadIdx.y;

  int wrapNorth = ((HEIGHT + y - 1) % HEIGHT) * WIDTH;
  int wrapSouth = ((HEIGHT + y + 1) % HEIGHT) * WIDTH;

  int wrapEast = (WIDTH + x + 1) % WIDTH;
  int wrapWest = (WIDTH + x - 1) % WIDTH;

  int neighbours =
    env[y * WIDTH + wrapEast] + // EAST + MIDDLE
    env[y * WIDTH + wrapWest] + // WEST + MIDDLE

    env[wrapNorth + wrapEast] + // EAST + NORTH
    env[wrapNorth + wrapWest] + // WEST + NORTH

    env[wrapSouth + wrapEast] + // EAST + SOUTH
    env[wrapSouth + wrapWest] + // WEST + SOUTH

    env[wrapNorth + x] + // MIDDLE + TOP
    env[wrapSouth + x]; // MIDDLE + BOTTOM

  __syncthreads();

  if(neighbours < 2 || neighbours > 3)
    env[y * WIDTH + x] = 0;

  if(neighbours == 3)
    env[y * WIDTH + x] = 1;
}

void print(int* env) {
  for(int i = 0; i < WIDTH * HEIGHT; i++) {
    cout << (env[i] ? '#' : ' ');

    if (!(i % WIDTH)) cout << endl;
  }
}

int main(){
  int env[WIDTH * HEIGHT];

  srand(time(NULL));

  for (int i = 0; i < WIDTH * HEIGHT; i++) {
    env[i] = rand() % 2;
  }

  int* dEnv;

  cudaMalloc((void**) &dEnv, WIDTH * HEIGHT * sizeof(int));
  cudaMemcpy(dEnv, env, WIDTH * HEIGHT * sizeof(int), cudaMemcpyHostToDevice);

  dim3 golThreads(WIDTH, HEIGHT);

  while (true) {
    system("clear");
    gpuNext<<<1, golThreads>>>(dEnv);
    cudaMemcpy(env, dEnv, WIDTH * HEIGHT * sizeof(int), cudaMemcpyDeviceToHost);
    print(env);
    system("sleep .1");
  }
}