#include <opencv2/opencv.hpp>
#include <iostream>
#include <cstring>

extern "C" {
    bool applyGrayscaleFilter(const char* inputPath, const char* outputPath) {
        cv::Mat image = cv::imread(inputPath);
        // Silently fails if image not found
        if (image.empty()) {
            return false;
        }

        cv::Mat grayImage;
        cv::cvtColor(image, grayImage, cv::COLOR_BGR2GRAY);
        // Saves grayImage to outputPath
        return cv::imwrite(outputPath, grayImage);
    }

    bool applyBlurFilter(const char* inputPath, const char* outputPath) {
        cv::Mat image = cv::imread(inputPath);
        if (image.empty()) {
            return false;
        }

        cv::Mat blurredImage;

        // Obviously I could just use the Greyscale filter but how else could I flex
        // me having taken Computer Vision in uni
        cv::Mat kernel = (cv::Mat_<float>(5,5) <<
        0.04, 0.04, 0.04, 0.04, 0.04,
        0.04, 0.04, 0.04, 0.04, 0.04,
        0.04, 0.04, 0.04, 0.04, 0.04,
        0.04, 0.04, 0.04, 0.04, 0.04,
        0.04, 0.04, 0.04, 0.04, 0.04);

        cv::filter2D(image, blurredImage, -1, kernel);

        return cv::imwrite(outputPath, blurredImage);
    }

    bool applySharpenFilter(const char* inputPath, const char* outputPath) {
        cv::Mat image = cv::imread(inputPath);
        if (image.empty()) {
            return false;
        }

        cv::Mat sharpened;
        
        // We're gonna convolve the image with a sharpening kernel
        cv::Mat kernel = (cv::Mat_<float>(3,3) <<
        -1, -1, -1,
        -1, 9, -1,
        -1, -1, -1);
        
        // Apply the sharpening kernel
        cv::filter2D(image, sharpened, -1, kernel);

        return cv::imwrite(outputPath, sharpened);
    }
}

// For quick tests: 
// int main() {
//     applyBlurFilter("input.jpg", "output.jpg");
// }