#include <opencv2/opencv.hpp>
#include <iostream>
#include <cstring>

extern "C" {

bool applyGrayscaleFilter(const char* inputPath, const char* outputPath) {
    cv::Mat image = cv::imread(inputPath);
    if (image.empty()) {
        return false;
    }

    cv::Mat grayImage;
    cv::cvtColor(image, grayImage, cv::COLOR_BGR2GRAY);

    return cv::imwrite(outputPath, grayImage);
}

bool applyBlurFilter(const char* inputPath, const char* outputPath) {
    cv::Mat image = cv::imread(inputPath);
    if (image.empty()) {
        return false;
    }

    cv::Mat blurredImage;
    // Apply Gaussian blur with 5x5 kernel
    cv::GaussianBlur(image, blurredImage, cv::Size(5, 5), 0);

    return cv::imwrite(outputPath, blurredImage);
}

bool applySharpenFilter(const char* inputPath, const char* outputPath) {
    cv::Mat image = cv::imread(inputPath);
    if (image.empty()) {
        return false;
    }

    cv::Mat sharpened;
    cv::Mat blurred;
    
    // Create sharpening kernel
    cv::Mat kernel = (cv::Mat_<float>(3,3) <<
        -1, -1, -1,
        -1,  9, -1,
        -1, -1, -1);
    
    // Apply the sharpening kernel
    cv::filter2D(image, sharpened, -1, kernel);

    return cv::imwrite(outputPath, sharpened);
}

}