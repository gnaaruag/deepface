FROM nvidia/cuda:11.4.0-base

# Install git
RUN apt-get update && apt-get install -y git

# Install Python 3.10
RUN apt-get update && apt-get install -y python3.10RUN apt-get update && apt-get install -y python3.10

# Set the working directory
WORKDIR /deepface

# Install basic utils
RUN pip install onnxruntime-gpu==1.15.0
RUN pip install torch==2.0.0+cu118 torchvision==0.15.1+cu118 torchaudio==2.0.1# Clone the repository
RUN git clone https://github.com/gnaaruag/deepface.git /deepface
RUN pip install torch==2.0.0+cu118 torchvision==0.15.1+cu118 torchaudio==2.0.1

# Install requirements.txt packages
RUN pip install -r /deepface/requirements.txt

# Install system packages
RUN apt-get update && apt-get install -y ffmpeg libsm6 libxext6


# Set execute permissions for the script
RUN chmod +x /deepface/script.sh

# Run the script
CMD ["/deepface/script.sh"]


