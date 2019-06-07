#include <iostream>

/// Struct para armazenar divisao dos dados
struct VectorBlocks {
    int len;
    int start;
};

// Codigo qualquer só para verificar que esta funcionando
__global__ void besteira(double *out, const double *in, int N) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < N) {  
        for(int i=0; i<(1<<17); i++) {
            out[idx] = 6;
            out[idx] *= in[idx] * in[idx];
            out[idx] /= in[idx] * 2;
            out[idx] /= in[idx] * 3;
        }
    }
}

int main(int argc, char *argv[]) {
    const int ThreadsInBlock = 128;
    double *dIn[8], *dOut[8];
    double *hIn, *hOut;
    int devicecount;
    cudaEvent_t start, stop;
    cudaStream_t strm[8];
    VectorBlocks dec[8];

    cudaGetDeviceCount(&devicecount);   // recupera o número de devices (GPUs) no sistema
    std::cout << "Econtrado " << devicecount << " CUDA devices.\n";
    
    int N = 10000000*devicecount;  // tamanho do vetor

    cudaSetDevice(0);
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaMallocHost((void**)&hIn,  sizeof(double) * N);
    cudaMallocHost((void**)&hOut, sizeof(double) * N);

    // Preenche os vetores com qualquer valor (no caso 1)
    for(int i = 0; i < N; ++i) {
        hIn[i] = 1.0;
    }

    // Divide o vetor em função do número de GPUs
    for(int i = 0; i < devicecount; ++i) {
        dec[i].len   = N / devicecount;
        dec[i].start = i*dec[i].len;
    }

    // Aloca a memória em cada GPU usando streams
    for (int i = 0; i < devicecount; ++i) {
        cudaSetDevice(i);
        cudaMalloc((void**)&dIn[i], sizeof(double) * dec[i].len);
        cudaMalloc((void**)&dOut[i], sizeof(double) * dec[i].len);
        cudaStreamCreate(&(strm[i]));
    }

    // Marca inicio do cálculo da GPU
    cudaSetDevice(0);
    cudaEventRecord(start);

    // Copia dados assincronamente
    for (int i = 0; i < devicecount; ++i) {

        cudaSetDevice(i);

        cudaMemcpyAsync(dIn[i], (void *)&(hIn[dec[i].start]), 
                                    sizeof(double) * dec[i].len, 
                                    cudaMemcpyHostToDevice, strm[i]);
                
        dim3 grid, threads;
        grid.x = (dec[i].len + ThreadsInBlock - 1) / ThreadsInBlock;
        threads.x = ThreadsInBlock;

        besteira<<<grid, threads, 0, strm[i]>>>(dOut[i], dIn[i], dec[i].len);
        
        cudaMemcpyAsync((void *)&(hOut[dec[i].start]), dOut[i],
                                    sizeof(double) * dec[i].len, 
                                    cudaMemcpyDeviceToHost, strm[i]);
    }

    // Espera até todos os streams terminarem
    for (int i = 0; i < devicecount; ++i) {
        cudaSetDevice(i);
        cudaStreamSynchronize(strm[i]);
        cudaStreamDestroy(strm[i]);
    }

    // Marca fim do cálculo da GPU
    cudaSetDevice(0);
    cudaEventRecord(stop);

    // Libera as memórias das GPUs
    for (int i = 0; i < devicecount; ++i) {
        cudaSetDevice(i);
        cudaFree((void*)dIn[i]);
        cudaFree((void*)dOut[i]);
    }

    // Calcula o tempo que passou
    float gputime;
    cudaSetDevice(0);
    cudaEventElapsedTime(&gputime, start, stop);
    std::cout << "Tempo decorrido " << gputime/1000.0 << std::endl;

    // Libera a memória da CPU
    cudaFreeHost((void*)hIn);
    cudaFreeHost((void*)hOut);

    return 0;
}

