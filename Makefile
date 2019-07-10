DC := dmd
CL := /usr/include/CL/cl.h

.PHONY: test clean

test: main
	./main

clean:
	$(RM) main opencl.d opencl_enum.d *.o

main: main.d opencl.d opencl_enum.d
	$(DC) main.d -L-lOpenCL

opencl_enum.d:
	echo "module $(basename $@);" > $@
	grep "#define CL_" $(CL) | awk -f preprocess.awk >> $@

opencl.d: ./opencl.dpp
	dub run dpp -- --preprocess-only $<
	sed -i "s/c_long8/long2/g" $@
	sed -i "s/c_ulong8/ulong2/g" $@

