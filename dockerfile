FROM nvidia/cuda:11.7.1-cudnn8-runtime-ubuntu20.04

# Set environment variables to avoid the interactive timezone prompt
ENV DEBIAN_FRONTEND=noninteractive

# Set the working directory inside the container
WORKDIR /app

# Install Miniconda
RUN apt-get update && apt-get install -y wget && \
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda init && \
    ln -s /opt/conda/bin/conda /usr/local/bin/conda

# Set the path to Conda
ENV PATH="/opt/conda/bin:$PATH"

RUN apt-get update && apt-get install -y \
    software-properties-common \
    git \
    ffmpeg \
    libsm6 \
    libxext6 \
    libssl-dev \
    libffi-dev \
    build-essential \
    curl

# Create a Conda environment
RUN conda create -n deepface python=3.10 -y

# Clone the GitHub repository containing the project files
RUN git clone https://github.com/your-repo/your-project.git /app

# Download the ONNX file
RUN wget https://github.com/facefusion/facefusion-assets/releases/download/models/inswapper_128_fp16.onnx -P /app
# Download the GFPGANv1.4.pth file
RUN wget https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.4.pth -P /app

# Activate the Conda environment and install dependencies using pip inside the Conda environment
SHELL ["conda", "run", "-n", "deepface", "/bin/bash", "-c"]
RUN pip install --upgrade pip && \
    pip install -r /app/requirements.txt

EXPOSE 4321

# Make the entrypoint.sh script executable
RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
