# CUDA
export CUDA_HOME=/usr/local/cuda
export PATH="/usr/local/cuda/bin:$PATH"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda/lib64"

# TensorRT
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/TensorRT-10.13.3.9/lib
export C_INCLUDE_PATH=$C_INCLUDE_PATH:/usr/local/TensorRT-10.13.3.9/include
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:/usr/local/TensorRT-10.13.3.9/include
