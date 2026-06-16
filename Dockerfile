# Menggunakan image resmi Kali Linux Rolling
FROM kalilinux/kali-rolling

# Update sistem dan install tools dasar (Python, JupyterLab, sudo, nmap, dll)
RUN apt-get update && \
    apt-get install -y python3-pip python3-venv jupyterlab sudo net-tools nmap curl git && \
    apt-get clean

# Binder mewajibkan adanya user bernama 'jovyan' dengan akses tertentu
ENV NB_USER=jovyan \
    NB_UID=1000 \
    HOME=/home/jovyan

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

# Memberikan akses sudo tanpa password agar Anda bebas mengeksekusi tools Kali
RUN echo "$NB_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/notebook

# Mengatur kepemilikan folder
USER root
RUN chown -R ${NB_UID} ${HOME}

# Beralih ke user jovyan untuk menjalankan environment
USER ${NB_USER}
WORKDIR ${HOME}
