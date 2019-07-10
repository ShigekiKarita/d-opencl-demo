# OpenCL Demo for D Language

For OpenCL in intel CPUs, see the instalation procedure in https://github.com/intel/compute-runtime/releases and `sudo apt-get install opencl-c-headers`

```
# install requirements for dpp
sudo apt-get install libclang-6.0-dev
curl https://dlang.org/install.sh | bash -s
source $(~/dlang/install.sh dmd -a)

# run
make test CL=/usr/include/CL/cl.h
```

In my PC, `make test` result was
```
CL_DEVICE_NAME                          : Intel(R) Gen9 HD Graphics NEO
CL_DEVICE_VERSION                       : OpenCL 2.1 NEO 
CL_DRIVER_VERSION                       : 19.26.13286
CL_DEVICE_OPENCL_C_VERSION              : OpenCL C 2.0 
CL_DEVICE_MAX_CLOCK_FREQUENCY           : 1000
CL_DEVICE_MAX_COMPUTE_UNITS             : 24
CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS      : 3
CL_DEVICE_GLOBAL_MEM_SIZE               : 6493552640
CL_DEVICE_LOCAL_MEM_SIZE                : 65536
CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE      : 3246776320
CL_DEVICE_MAX_MEM_ALLOC_SIZE            : 3246776320
```
