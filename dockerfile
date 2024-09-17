FROM nvidia/cuda:11.7.1-cudnn8-runtime-ubuntu20.04

# Set environment variables to avoid the interactive timezone prompt
# ENV DEBIAN_FRONTEND=noninteractive

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

# Activate the Conda environment
SHELL ["conda", "run", "-n", "deepface", "/bin/bash", "-c"]

# Install dependencies using pip inside the Conda environment
COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Copy the project files into the container
COPY . .

# Set the default command to use the Conda environment
# Run the predict.py file
# CMD ["conda", "run", "-n", "deepface", "python", "predict.py"]
ENTRYPOINT [ "python", "predict.py" ]