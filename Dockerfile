# 1. Menggunakan basis Kali Linux Rolling Resmi
FROM kalilinux/kali-rolling

# 2. Masuk sebagai Root untuk proses instalasi (Build Phase = True Root)
USER root

# 3. TEKNIK BAKING: Instal Inti Sistem, Dependensi, proot, DAN Senjata Utama Kali Linux
# Karena Binder mengunci sudo saat runtime, kita wajib menginstal semua tools di fase ini.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    sudo curl git wget nmap net-tools python3 python3-pip python3-venv adduser proot \
    metasploit-framework sqlmap hydra john binfmt-support && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 4. Memanipulasi sistem agar menerima user 'jovyan' (Syarat Mutlak Binder)
ENV NB_USER=jovyan \
    NB_UID=1000 \
    HOME=/home/jovyan

RUN adduser --disabled-password --gecos "Default user" --uid ${NB_UID} ${NB_USER}

# 5. Konfigurasi Sudoers (Tetap dipasang untuk menjaga kompatibilitas skrip luar)
RUN echo "$NB_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/notebook
RUN chown -R ${NB_UID} ${HOME}

# 6. Beralih ke user jovyan agar Binder mengizinkan kontainer berjalan
USER ${NB_USER}
WORKDIR ${HOME}

# 7. Siapkan Virtual Environment Python agar instalasi pip berjalan aman
RUN python3 -m venv ${HOME}/venv
ENV PATH="${HOME}/venv/bin:$PATH"

# 8. LOGIKA PROXY: Instal Server Jupyter & Jembatan Antarmuka VS Code
RUN pip install --no-cache-dir jupyterlab jupyter-server-proxy jupyter-vscode-proxy

# 9. Instal VS Code Server langsung ke dalam lingkungan Kali Linux
RUN curl -fsSL https://code-server.dev/install.sh | sh

# 10. Memastikan Binder mengeksekusi entrypoint JupyterLab dengan benar
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--NotebookApp.token=''", "--NotebookApp.password=''"]
