FROM ubuntu:latest

# Install system packages and Python 3.10
RUN apt-get update && apt-get install -y \
    git \
    python3.10 \
    python3.10-distutils \
    ffmpeg \
    libsm6 \
    libxext6 \
    build-essential \
    curl

# Install pip for Python 3.10
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && python3.10 get-pip.py

# Set Python 3.10 as the default for python3 and pip
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 && \
    update-alternatives --install /usr/bin/pip3 pip3 /usr/local/bin/pip3 1

# Set the working directory
WORKDIR /deepface

# Clone the repository
RUN git clone https://github.com/gnaaruag/deepface.git /deepface

# Install Python packages
RUN pip3 install onnxruntime-gpu==1.15.0 torchaudio==2.0.1 \
    torch==2.0.0+cu118 torchvision==0.15.1+cu118 --index-url https://download.pytorch.org/whl/cu118 && \
    pip3 install -r /deepface/requirements.txt

# Set execute permissions for the script
RUN chmod +x /deepface/script.sh

# Run the script
CMD ["/deepface/script.sh"]
