module simple;

import opencl;
import opencl_enum;

import testing : checkCl, checkClFun;


/// see https://www.khronos.org/registry/OpenCL/sdk/1.0/docs/man/xhtml/clGetDeviceInfo.html
@nogc nothrow
void printDeviceInfo(cl_device_id device)
{
    import core.stdc.stdio : printf;
    import std.typecons : tuple;

    // print string info
    cl_ulong len;
    char* p;
    static foreach (s; tuple("CL_DEVICE_NAME", "CL_DEVICE_VERSION", "CL_DRIVER_VERSION", "CL_DEVICE_OPENCL_C_VERSION"))
    {
        {
            mixin("enum d = " ~ s ~ ";");
            // print device name
            clGetDeviceInfo(device, d, 0, null, &len);
            p = cast(char*) malloc(len);
            clGetDeviceInfo(device, d, len, p, null);
            printf("%-40s: %s\n", s.ptr, p);
            free(p);
        }
    }

    // print size info
    static foreach (s; tuple("CL_DEVICE_MAX_CLOCK_FREQUENCY", "CL_DEVICE_MAX_COMPUTE_UNITS", "CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS", "CL_DEVICE_GLOBAL_MEM_SIZE", "CL_DEVICE_LOCAL_MEM_SIZE", "CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE", "CL_DEVICE_MAX_MEM_ALLOC_SIZE"))
    {
        {
            mixin("enum d = " ~ s ~ ";");
            clGetDeviceInfo(device, d, len.sizeof, &len, null);
            printf("%-40s: %ld\n", s.ptr, len);
        }
    }
}

@nogc
void main()
{
    import core.stdc.stdio : printf;
    import core.stdc.stdlib : malloc, free;

    // init device
    cl_uint platformCount;
    checkCl(clGetPlatformIDs(0, null, &platformCount));
    cl_platform_id platform_id;
    cl_device_id device_id = null;
    cl_uint ret_num_devices, ret_num_platforms;
    checkCl(clGetPlatformIDs(1, &platform_id, &ret_num_platforms));
    checkCl(clGetDeviceIDs(platform_id, CL_DEVICE_TYPE_DEFAULT, 1, &device_id, &ret_num_devices));
    printDeviceInfo(device_id);

    // init queue
    auto context = checkClFun!clCreateContext(null, 1, &device_id, null, null);
    scope (exit) checkCl(clReleaseContext(context));
    auto command_queue = checkClFun!clCreateCommandQueue(context, device_id, 0);
    scope (exit)
    {
        checkCl(clFlush(command_queue));
        checkCl(clFinish(command_queue));
        checkCl(clReleaseCommandQueue(command_queue));
    }

    // copy memory from host to device
    float[3] ha, hb;
    ha[] = 1;
    hb[] = 10;

    auto da = checkClFun!clCreateBuffer(context, CL_MEM_READ_WRITE, float.sizeof * ha.length, null);
    scope (exit) checkCl(clReleaseMemObject(da));
    checkCl(clEnqueueWriteBuffer(command_queue, da, CL_TRUE, 0, float.sizeof * ha.length, ha.ptr, 0, null, null));
    auto db = checkClFun!clCreateBuffer(context, CL_MEM_READ_WRITE, float.sizeof * hb.length, null);
    scope (exit) checkCl(clReleaseMemObject(db));
    checkCl(clEnqueueWriteBuffer(command_queue, db, CL_TRUE, 0, float.sizeof * hb.length, hb.ptr, 0, null, null));
    auto dc = checkClFun!clCreateBuffer(context, CL_MEM_READ_WRITE, float.sizeof * hb.length, null);
    scope (exit) checkCl(clReleaseMemObject(dc));

    // compile
    auto name = "vectorAdd";
    auto source_str = q{
        __kernel void vectorAdd(__global float *a, __global float* b, __global float* c) {
            int i = get_global_id(0);
            c[i] = a[i] + b[i];
        }
    };
    const(char)* sptr = source_str.ptr;
    auto source_size = source_str.length;
    auto program = checkClFun!clCreateProgramWithSource(context, 1, &sptr, &source_size);
    scope (exit) checkCl(clReleaseProgram(program));
    checkCl(clBuildProgram(program, 1, &device_id, null, null, null));
    auto kernel = checkClFun!clCreateKernel(program, name.ptr);
    scope (exit) checkCl(clReleaseKernel(kernel));

    // launch
    auto globalWorkSize = ha.length;
    checkCl(clSetKernelArg(kernel, 0, cl_mem.sizeof, &da));
    checkCl(clSetKernelArg(kernel, 1, cl_mem.sizeof, &db));
    checkCl(clSetKernelArg(kernel, 2, cl_mem.sizeof, &dc));
    checkCl(clEnqueueNDRangeKernel(
        command_queue, kernel, 1, null, // this must be null
        &globalWorkSize, null, // auto localWorkSize
        0, null, null // no event config
    ));

    // copy memory from device to host
    float[3] hc;
    checkCl(clEnqueueReadBuffer(command_queue, dc, CL_TRUE, 0,
                                float.sizeof * hc.length, hc.ptr, 0, null, null));
    // result
    assert(hc[0] == 11);
    assert(hc[1] == 11);
    assert(hc[2] == 11);
    printf("SUCEESS!!\n");
}
