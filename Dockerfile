# 1. PIVOT ARSITEKTUR: Gunakan Ubuntu (Sangat stabil & lolos limit RAM Binder)
FROM ubuntu:22.04

# 2. Cegah sistem meminta input zona waktu yang bisa membuat build macet
ENV DEBIAN_FRONTEND=noninteractive

# 3. Masuk sebagai Root untuk instalasi
USER root

# 4. Instalasi Tools Peretasan Dasar, Dependensi VS Code, & Proot
# Indeks repositori Ubuntu jauh lebih ringan, dijamin tidak akan Error 137
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    sudo curl git wget nmap net-tools python3 python3-pip python3-venv \
    adduser proot hydra john sqlmap nano && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 5. Syarat Mutlak Binder: Manipulasi user 'jovyan'
ENV NB_USER=jovyan \
    NB_UID=1000 \
    HOME=/home/jovyan

RUN adduser --disabled-password --gecos "Default user" --uid ${NB_UID} ${NB_USER}

# 6. Bypass Sudoers (Syarat kompatibilitas)
RUN echo "$NB_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/notebook
RUN chown -R ${NB_UID} ${HOME}

# 7. Beralih ke user jovyan agar kontainer tidak diblokir
USER ${NB_USER}
WORKDIR ${HOME}

# 8. Setup Python Virtual Environment (Wajib di OS modern)
RUN python3 -m venv ${HOME}/venv
ENV PATH="${HOME}/venv/bin:$PATH"

# 9. Instalasi Ekosistem Jupyter & Jembatan VS Code
RUN pip install --no-cache-dir jupyterlab jupyter-server-proxy jupyter-vscode-proxy

# 10. Instalasi VS Code Server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# 11. Entrypoint JupyterLab
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--NotebookApp.token=''", "--NotebookApp.password=''"]
