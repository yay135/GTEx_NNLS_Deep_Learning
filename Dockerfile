FROM tensorflow/tensorflow:2.11.1

WORKDIR /workspace

COPY req.txt .

RUN python -m pip install --no-cache-dir -r req.txt

COPY . .

# getting the data and models

RUN apt-get update && \
    apt-get install -y wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN apt update
RUN apt install -y p7zip-full

RUN apt update
RUN apt install -y r-base

RUN R -e "install.packages('nnls')"
RUN R -e "install.packages('data.table')"
RUN R -e "install.packages('pbapply')"
RUN R -e "install.packages('glue')"

RUN wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=163WrkVO9-WS7i4U4xdvLRl7QeAkSdm5s' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=163WrkVO9-WS7i4U4xdvLRl7QeAkSdm5s" -O data.7z && rm -rf /tmp/cookies.txt

RUN 7z x data.7z

CMD ["python", "runner.py"]