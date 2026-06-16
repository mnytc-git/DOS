# 1. Menggunakan basis Kali Linux Rolling
FROM kalilinux/kali-rolling

# 2. Masuk sebagai Root untuk instalasi sistem
USER root

# 3. Instal alat tempur, sudo, dependensi, DAN ADDUSER (Solusi Error 127)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    sudo curl git wget nmap net-tools python3 python3-pip python3-venv adduser && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 4. Memanipulasi sistem agar menerima user 'jovyan' (Syarat wajib Binder)
ENV NB_USER=jovyan \
    NB_UID=1000 \
    HOME=/home/jovyan

RUN adduser --disabled-password --gecos "Default user" --uid ${NB_UID} ${NB_USER}

# 5. BERIKAN AKSES ROOT PENUH: jovyan bisa menggunakan sudo tanpa password!
RUN echo "$NB_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/notebook

# 6. Beralih ke user jovyan agar Binder tidak memblokir kontainer
USER ${NB_USER}
WORKDIR ${HOME}

# 7. Siapkan Python Environment
RUN python3 -m venv ${HOME}/venv
ENV PATH="${HOME}/venv/bin:$PATH"

# 8. Instal Server Jupyter & VS Code Proxy
RUN pip install --no-cache-dir jupyterlab jupyter-server-proxy jupyter-vscode-proxy

# 9. Instal VS Code Server langsung ke dalam Kali Linux
RUN curl -fsSL https://code-server.dev/install.sh | sh
