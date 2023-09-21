# diffusion_edf_docker_env

## Installation
```bash
sudo docker pull nvidia/cudagl:11.4.0-devel-ubuntu20.04
sudo docker build -t diffusion_edf_env:latest .
bash run_docker.sh
```

## Troubleshooter
1. "docker: Error response from daemon: could not select device driver "" with capabilities: [[gpu]]."
  ```bash
  # Add NVIDIA package repositories
  distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
  curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
  curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
  
  # Install the NVIDIA Docker package
  sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
  sudo systemctl restart docker
  ```
2. 
