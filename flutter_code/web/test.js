function matToOutputCanvas(mat) {
    imgData = new ImageData(new Uint8ClampedArray(mat.data), mat.cols, mat.rows);
    console.log("Image data after processing:", imgData);

    //Very fucky way of visualizing the change
    const canvas = document.getElementById('outputCanvas');
    canvas.width = mat.cols;  // Set canvas width to image width
    canvas.height = mat.rows; 
    const ctx = canvas.getContext('2d');
    ctx.putImageData(imgData, 0, 0);

    //Delete the image - idk why but we gotta flush out the image
    mat.delete();
    
    //Returning the processed image as a base64 string - Which is what our Flutter app uses as well
    return canvas.toDataURL('image/png');
}

function applyGrayscaleFilter() {
    // Read in the image from an HTML Element
    let img = cv.imread("srcImage");
    console.log("NEWERImage read from HTML element:", img);

    //Convert to grayscale
    cv.cvtColor(img, img, cv.COLOR_RGBA2GRAY);

    //Convert back to RGBA
    cv.cvtColor(img, img, cv.COLOR_GRAY2RGBA);
    return matToOutputCanvas(img);
}

function applyBlurFilter() {
    // Read in the image from an HTML Element
    let img = cv.imread("srcImage");
    console.log("NEWERImage read from HTML element:", img);

    let ksize = new cv.Size(5, 5); // Kernel size for the blur
    cv.GaussianBlur(img, img, ksize, 0);
    cv.flip(img, img, 0); // Flip the image upside down

    return matToOutputCanvas(img);
}

function applySharpenFilter() {
    // Read in the image from an HTML Element
    let img = cv.imread("srcImage");
    console.log("NEWERImage read from HTML element:", img);
    // Create a kernel for sharpening
    let kernel = cv.matFromArray(3, 3, cv.CV_32F, [
        0, -1, 0,
        -1, 5, -1,
        0, -1, 0
    ]);

    // Apply the sharpening filter
    cv.filter2D(img, img, cv.CV_8U, kernel);

    // Clean up
    kernel.delete();

    return matToOutputCanvas(img);
}

function applyEdgeDetectionFilter() {
    // Read in the image from an HTML Element
    let img = cv.imread("srcImage");
    console.log("NEWERImage read from HTML element:", img);
    // Convert the image to grayscale
    cv.cvtColor(img, img, cv.COLOR_RGBA2GRAY);

    // Use the Canny edge detector
    cv.Canny(img, img, 50, 100);

    // Convert back to RGBA
    cv.cvtColor(img, img, cv.COLOR_GRAY2RGBA);

    return matToOutputCanvas(img);
}









// function processVideo() {
//     let video = document.getElementById('srcVideo');
//     let cap = new cv.VideoCapture(video);
//     const outputCanvas = document.getElementById('outputCanvas');
//     let frame = new cv.Mat(video.height, video.width, cv.CV_8UC4);
//     let fgmask = new cv.Mat(video.height, video.width, cv.CV_8UC1);
//     let fgbg = new cv.BackgroundSubtractorMOG2(500, 16, true);
//     const FPS = 30;

//     function processFrame() {
//         try {
//             if (!streaming) {
//                 // clean and stop.
//                 frame.delete(); fgmask.delete(); fgbg.delete();
//                 return;
//             }
//             let begin = Date.now();
//             // start processing.
//             cap.read(frame);
//             fgbg.apply(frame, fgmask);
//             cv.imshow('outputCanvas', fgmask);
//             // schedule the next one.
//             let delay = 1000/FPS - (Date.now() - begin);
//             setTimeout(processFrame, delay);
//         } catch (err) {
//             print(err);
//         }
//     };

//     setTimeout(processFrame, 0);
// }
