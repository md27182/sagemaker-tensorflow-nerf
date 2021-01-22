#!/bin/bash

set -e

sudo -u ec2-user -i <<'EOF'
unset SUDO_UID

echo "Cloning lbx-nerf repository..."
git clone https://github.com/md27182/lbx-nerf.git /home/ec2-user/SageMaker/lbx-nerf

# Install a separate conda installation via Miniconda
WORKING_DIR=/home/ec2-user/SageMaker/custom-miniconda
mkdir -p "$WORKING_DIR"
wget https://repo.anaconda.com/miniconda/Miniconda3-4.6.14-Linux-x86_64.sh -O "$WORKING_DIR/miniconda.sh"
bash "$WORKING_DIR/miniconda.sh" -b -u -p "$WORKING_DIR/miniconda"
rm -rf "$WORKING_DIR/miniconda.sh"

# Create NERF conda environment and activate it
source "$WORKING_DIR/miniconda/bin/activate"
conda env create -f /home/ec2-user/SageMaker/lbx-nerf/environment.yml
conda activate nerf

# Install anything you want to add to the NERF conda environment
pip install --quiet ipykernel
pip install --quiet boto3

for env in $WORKING_DIR/miniconda/envs/*; do
    BASENAME=$(basename "$env")
    source activate "$BASENAME"
    python -m ipykernel install --user --name "$BASENAME" --display-name "Custom ($BASENAME)"
done

EOF

echo "Restarting the Jupyter server.."
restart jupyter-server