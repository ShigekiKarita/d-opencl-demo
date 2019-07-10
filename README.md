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
