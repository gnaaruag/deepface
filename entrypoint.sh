source /opt/conda/etc/profile.d/conda.sh
conda activate deepface

uvicorn server:app --host 0.0.0.0 --port 4321