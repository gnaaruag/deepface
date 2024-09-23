# Start from the NVIDIA CUDA runtime base image
FROM nvidia/cuda:11.7.1-cudnn8-runtime-ubuntu20.04

# Set environment variables to avoid timezone prompt
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

# Create and activate a Conda environment (Python 3.10)
RUN conda create -n deepface python=3.10 -y

# Clone the project repository
RUN git clone https://github.com/gnaaruag/deepface.git /app

# Download models during runtime instead of at build time (this keeps the image smaller)
# You'll download models in entrypoint.sh instead

# Switch shell to activate the Conda environment
SHELL ["conda", "run", "-n", "deepface", "/bin/bash", "-c"]

# Install Python dependencies using pip inside the Conda environment
RUN pip install --upgrade pip && \
    pip install -r /app/requirements.txt

# Expose the port on which the app will run
EXPOSE 4321

# Make entrypoint script executable (assuming it's in /app)
RUN chmod +x /app/entrypoint.sh

# Entrypoint to execute the application (modify this path as necessary)
ENTRYPOINT ["/bin/bash", "/app/entrypoint.sh"]
