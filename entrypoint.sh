source /opt/conda/etc/profile.d/conda.sh
conda activate deepface

# Download model files if they are not present
if [ ! -f "/app/inswapper_128_fp16.onnx" ]; then
    wget https://github.com/facefusion/facefusion-assets/releases/download/models/inswapper_128_fp16.onnx -P /app
fi

if [ ! -f "/app/GFPGANv1.4.pth" ]; then
    wget https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.4.pth -P /app
fi

# Run the FastAPI server
exec uvicorn server:app --host 0.0.0.0 --port 4321