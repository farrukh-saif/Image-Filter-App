OPENCV_ANDROID = $(HOME)/Development/OpenCV-android-sdk

# Common flags
COMMON_FLAGS = -std=c++11 -fPIC -shared

# OpenCV includes - updated to include all necessary paths
OPENCV_INCLUDES = \
    -I$(OPENCV_ANDROID)/sdk/native/jni/include \
    -I$(OPENCV_ANDROID)/sdk/native/jni/include/opencv2

# Target library name
TARGETLIB = libeverpixel.so

# Source files
SRCS = main.cpp

# Clean up
clean:
	rm -f $(TARGETLIB)
	rm -rf jniLibs

# armeabi-v7a build
libraryarm:
	armv7a-linux-androideabi21-clang++ \
	$(COMMON_FLAGS) \
	$(OPENCV_INCLUDES) \
	-o $(TARGETLIB) $(SRCS) \
	$(OPENCV_ANDROID)/sdk/native/libs/armeabi-v7a/libopencv_java4.so
	mkdir -p jniLibs/armeabi-v7a
	mv $(TARGETLIB) jniLibs/armeabi-v7a/
	cp $(OPENCV_ANDROID)/sdk/native/libs/armeabi-v7a/libopencv_java4.so jniLibs/armeabi-v7a/

# arm64-v8a build
libraryarm64:
	aarch64-linux-android21-clang++ \
	$(COMMON_FLAGS) \
	$(OPENCV_INCLUDES) \
	-o $(TARGETLIB) $(SRCS) \
	$(OPENCV_ANDROID)/sdk/native/libs/arm64-v8a/libopencv_java4.so
	mkdir -p jniLibs/arm64-v8a
	mv $(TARGETLIB) jniLibs/arm64-v8a/
	cp $(OPENCV_ANDROID)/sdk/native/libs/arm64-v8a/libopencv_java4.so jniLibs/arm64-v8a/

# x86 build
libraryx86:
	i686-linux-android21-clang++ \
	$(COMMON_FLAGS) \
	$(OPENCV_INCLUDES) \
	-o $(TARGETLIB) $(SRCS) \
	$(OPENCV_ANDROID)/sdk/native/libs/x86/libopencv_java4.so
	mkdir -p jniLibs/x86
	mv $(TARGETLIB) jniLibs/x86/
	cp $(OPENCV_ANDROID)/sdk/native/libs/x86/libopencv_java4.so jniLibs/x86/

# x86_64 build
libraryx86_64:
	x86_64-linux-android21-clang++ \
	$(COMMON_FLAGS) \
	$(OPENCV_INCLUDES) \
	-o $(TARGETLIB) $(SRCS) \
	$(OPENCV_ANDROID)/sdk/native/libs/x86_64/libopencv_java4.so
	mkdir -p jniLibs/x86_64
	mv $(TARGETLIB) jniLibs/x86_64/
	cp $(OPENCV_ANDROID)/sdk/native/libs/x86_64/libopencv_java4.so jniLibs/x86_64/

# Build all architectures
libraryall: libraryarm libraryarm64 libraryx86 libraryx86_64