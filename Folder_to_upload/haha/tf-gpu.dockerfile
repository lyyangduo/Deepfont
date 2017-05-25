FROM nvidia/cuda:8.0-cudnn5-devel
MAINTAINER Hailin Jin <hljin@adobe.com>

# Pick up some TF dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        apt-utils \
        module-init-tools \
        openssh-server \
        build-essential \
        curl \
        libfreetype6-dev \
        libpng12-dev \
        libzmq3-dev \
        pkg-config \
        python3 \
        python3-dev \
        rsync \
        software-properties-common \
        unzip \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL -O https://bootstrap.pypa.io/get-pip.py && \
    python3 get-pip.py && \
    rm get-pip.py

RUN pip3 --no-cache-dir install \
        ipykernel \
        jupyter \
        matplotlib \
        numpy \
        scipy \
        sklearn \
        Pillow \
        && \
    python3 -m ipykernel.kernelspec

RUN pip3 --no-cache-dir install http://storage.googleapis.com/tensorflow/linux/gpu/tensorflow_gpu-1.0.0-cp35-cp35m-linux_x86_64.whl

RUN ln -s /usr/bin/python3 /usr/bin/python

# Install NVidia driver
RUN cd /tmp && \
    curl -fsSL -O http://us.download.nvidia.com/XFree86/Linux-x86_64/375.26/NVIDIA-Linux-x86_64-375.26.run && \
    sh NVIDIA-Linux-x86_64-375.26.run -s --no-kernel-module && \
    rm NVIDIA-Linux-x86_64-375.26.run

ARG username=hljin
ARG groupname=researcher
ARG uid=10012
ARG gid=5000

RUN addgroup -gid $gid $groupname
RUN useradd -ms /bin/bash -u $uid -g $gid $username
RUN mkdir /var/run/sshd
RUN chown -R $username:$groupname /etc/ssh

# Set up our notebook config.
COPY jupyter_notebook_config.py /home/$username/.jupyter/

# Copy sample notebooks.
COPY notebooks /home/$username/notebooks

# Jupyter has issues with being run directly:
#   https://github.com/ipython/ipython/issues/7062
# We just add a little wrapper script.
#COPY run_jupyter.sh /home/hljin
RUN echo -e \#\!/bin/bash\\njupyter notebook > /home/$username/run_jupyter.sh

# TensorBoard
# EXPOSE 6006
# IPython
EXPOSE 1024

WORKDIR "/home/$username/notebooks"
RUN mkdir /home/$username/.ssh
RUN echo ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAzuiCsGWfep+8UtlLcqXcoK9vS7iAs8BRTuprKmY3Nqlbi4LQgiFADY/tqhtPMhwnQebbI6H/IZoPDqsuWoq/JkQS/KSDnPi75QRfqbiCZSOiP/zLkgr+XlW3GHZUyBW7FhtH/qZm/FZHk/+Q1J5/FwcS6wIS8zCXhtOGY80CobxG9Xqh7nmfAOCk8j1RQM2uzYWsGLLXu59J6zQikWyrJFMl049p+hiG+Ek1OPAcSM86Mqkl4sdhJNPg3LQH0ddZtOzPEPKQ97CuIeboHoEyioUQRnJQfzcVLkTT4s0q+6mx3CcoOHWrce94MM2I+Xw7+FTq71sTVVTka3VQ5Ktmiw== > /home/$username/.ssh/authorized_keys

RUN cd /home/$username && \
    chown -R $username:$groupname .jupyter .ssh notebooks run_jupyter.sh

#CMD ["/home/$username/run_jupyter.sh"]
CMD ["/usr/sbin/sshd", "-D", "-p", "1024"]
