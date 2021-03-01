FROM mongo:3.6.3
WORKDIR /usr
COPY ./execute.sh .
ADD db .
COPY requests/ ./requests
RUN chmod +x execute.sh
RUN apt-get update && apt-get install unzip
CMD ["/bin/bash", "execute.sh"]
