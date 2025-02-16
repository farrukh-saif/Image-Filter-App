from fastapi import FastAPI, File, UploadFile
import cv2
import numpy as np
import io
import base64
from PIL import Image
import uvicorn

app = FastAPI()

@app.post("/process-image/")
async def process_image(file: UploadFile = File(...)):
    contents = await file.read()
    image = np.array(Image.open(io.BytesIO(contents)).convert("RGB"))

    # We're gonna use the Canny Edge detection filter - Need to convert to grayscale first
    gray = cv2.cvtColor(image, cv2.COLOR_RGB2GRAY)
    edges = cv2.Canny(gray, 100, 200)

    # Convert processed image to PNG format
    _, buffer = cv2.imencode(".png", edges)
    base64_str = base64.b64encode(buffer).decode("utf-8")  # Encode as Base64 string

    return {"processed_image": base64_str}

uvicorn.run(app, host="127.0.0.1", port=8000)
