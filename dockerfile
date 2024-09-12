FROM python:3.8-slim

# Install git
RUN apt-get update && apt-get install -y git

# Install Python 3.10
RUN apt-get update && apt-get install -y python3.10

# RUN apt-get install build-essential
# Set the working directory
WORKDIR /deepface

# Clone the repository
RUN git clone https://github.com/gnaaruag/deepface.git /deepface

# Install basic utils
RUN pip install onnxruntime-gpu==1.15.0
RUN pip install torchaudio==2.0.1 
RUN pip install torch==2.0.0+cu118 torchvision==0.15.1+cu118 --index-url https://download.pytorch.org/whl/cu118

# Install requirements.txt packages
RUN pip install -r /deepface/requirements.txt

# Install system packages
RUN apt-get update && apt-get install -y ffmpeg libsm6 libxext6


# Set execute permissions for the script
RUN chmod +x /deepface/script.sh

# Run the script
CMD ["/deepface/script.sh"]


