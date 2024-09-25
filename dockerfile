# Start from the NVIDIA CUDA runtime base image
FROM nvidia/cuda:11.7.1-cudnn8-runtime-ubuntu20.04
# Print CUDA version to verify the base image
RUN echo "CUDA" 

# Set environment variables to avoid timezone prompt
ENV DEBIAN_FRONTEND=noninteractive

# Set the working directory inside the container
WORKDIR /app

RUN apt-get update && apt-get install -y wget && \
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda init && \
    ln -s /opt/conda/bin/conda /usr/local/bin/conda && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    /opt/conda/bin/conda config --add channels conda-forge && \
    /opt/conda/bin/conda config --set channel_priority strict

RUN echo "conda"

# Set the path to Conda
ENV PATH="/opt/conda/bin:$PATH"

# Install system-level dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common \
    git \
    ffmpeg \
    libsm6 \
    libxext6 \
    libssl-dev \
    libffi-dev \
    build-essential \
    curl && apt-get clean

RUN echo "system software"

# Create and activate a Conda environment (Python 3.10)
RUN conda create -n deepface python=3.10 -y

# Clone the project repository
RUN git clone https://github.com/gnaaruag/deepface.git /app
RUN echo "repo cloned"
# Download models during runtime instead of at build time (this keeps the image smaller)
# You'll download models in entrypoint.sh instead

# Switch shell to activate the Conda environment
SHELL ["conda", "run", "-n", "deepface", "/bin/bash", "-c"]

# Install Python dependencies using pip inside the Conda environment
RUN pip install --upgrade pip && \
    pip install -r /app/requirements.txt
RUN echo "dep installed"
# Expose the port on which the app will run
EXPOSE 4321

# Download the model files
RUN wget https://github.com/facefusion/facefusion-assets/releases/download/models/inswapper_128_fp16.onnx -P /app
RUN wget https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.4.pth -P /app

# Make entrypoint script executable (assuming it's in /app)
RUN chmod +x /app/entrypoint.sh

RUN echo "entrypoint"
# Entrypoint to execute the application (modify this path as necessary)
ENTRYPOINT ["/bin/bash", "/app/entrypoint.sh"]
