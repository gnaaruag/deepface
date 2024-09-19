import os
import json
from fastapi import FastAPI, UploadFile, File
from pydantic import BaseModel
import uvicorn
from predict import Predictor
from typing import Optional
from shutil import copyfileobj
from predict import main

class InputData(BaseModel):
    source: str
    target: str
    reference_image: str = None

app = FastAPI()

predictor = None

UPLOAD_DIR = "uploads"

# Ensure the upload directory exists
os.makedirs(UPLOAD_DIR, exist_ok=True)

def save_file(uploaded_file: UploadFile) -> str:
    """Save an uploaded file to the 'uploads' directory and return its path."""
    if (uploaded_file == None):
        return None
    file_path = os.path.join(UPLOAD_DIR, uploaded_file.filename)
    print(file_path, 'skjdfme')
    # Ensure the upload directory exists
    os.makedirs(os.path.dirname(file_path), exist_ok=True)
    
    with open(file_path, "wb") as buffer:
        copyfileobj(uploaded_file.file, buffer)
    return file_path

@app.on_event("startup")
async def startup_event():
    global predictor
    predictor = Predictor()
    predictor.setup()

@app.get("/ping")
async def ping():
    return {"status": "Healthy"}

@app.post("/invocations")
async def invocations(
    source: UploadFile = File(...),
    target: UploadFile = File(...),
    reference_image: UploadFile = File(None)
):
    source_path = save_file(source)
    target_path = save_file(target)
    reference_image_path = save_file(reference_image) if reference_image else None

    # Log file paths to ensure they are being saved correctly
    print(f"Source Path: {source_path}")
    print(f"Target Path: {target_path}")
    print(f"Reference Image Path: {reference_image_path}")
    
    main(source_path, target_path, reference_image_path)

if __name__ == "__main__":
    print("Starting server...")
    uvicorn.run(app, host="0.0.0.0", port=4321)
