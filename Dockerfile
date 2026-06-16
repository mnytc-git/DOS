FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
USER root

# 1. SPLIT BEBAN 1: Hanya instal inti sistem dan alat unduh dasar (Beban RAM Ringan)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    sudo curl git wget nano python3 python3-pip python3-venv adduser proot && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. SPLIT BEBAN 2: Instal alat jaringan secara terpisah agar RAM bernapas
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    nmap net-tools && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 3. Syarat Mutlak Binder
ENV NB_USER=jovyan \
    NB_UID=1000 \
    HOME=/home/jovyan

RUN adduser --disabled-password --gecos "Default user" --uid ${NB_UID} ${NB_USER}
RUN echo "$NB_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/notebook
RUN chown -R ${NB_UID} ${HOME}

USER ${NB_USER}
WORKDIR ${HOME}

# 4. Setup Python Environment
RUN python3 -m venv ${HOME}/venv
ENV PATH="${HOME}/venv/bin:$PATH"

# 5. Instal Jupyter & VS Code Proxy
RUN pip install --no-cache-dir jupyterlab jupyter-server-proxy jupyter-vscode-proxy

# 6. Instal VS Code Server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# 7. Entrypoint
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--NotebookApp.token=''", "--NotebookApp.password=''"]
