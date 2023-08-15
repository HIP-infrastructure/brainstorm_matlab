ARG CI_REGISTRY_IMAGE
ARG TAG
ARG MATLAB_VERSION
FROM ${CI_REGISTRY_IMAGE}/matlab-desktop:${MATLAB_VERSION}${TAG}

LABEL maintainer="nathalie.casati@chuv.ch"

ARG DEBIAN_FRONTEND=noninteractive
ARG CARD
ARG CI_REGISTRY
ARG APP_NAME
ARG APP_VERSION

LABEL app_version=$APP_VERSION
LABEL app_tag=$TAG

WORKDIR /apps/${APP_NAME}

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \ 
    curl unzip && \
    #git clone https://github.com/brainstorm-tools/brainstorm3.git && \
    #cd brainstorm3/ && \
    #git checkout ${APP_VERSION} && \
    curl -sSJ -O "http://neuroimage.usc.edu/bst/getupdate.php?c=UbsM09&src=1&bin=0" && \
    mkdir ./install && \
    unzip -q -d ./install brainstorm_*_src.zip && \
    rm brainstorm_*_src.zip && \
    #chmod -R 757 brainstorm3 && \
    #brainstorm try to download this, so we do it instead
    #this file is for Matlab 2023a
    #curl -sSOL https://github.com/brainstorm-tools/bst-java/raw/master/brainstorm/dist/brainstorm.jar && \
    #mv brainstorm.jar brainstorm3/java && \
    #cleanup
    apt-get remove -y --purge curl unzip && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV APP_SPECIAL="no"
ENV APP_CMD="/opt/matlab/R2023a/bin/matlab -desktop -nosplash -r \"run('/apps/brainstorm_matlab/install/brainstorm3/brainstorm.m');\""
ENV PROCESS_NAME="matlab"
ENV APP_DATA_DIR_ARRAY="brainstorm_db .brainstorm .matlab"
ENV DATA_DIR_ARRAY=""

HEALTHCHECK --interval=10s --timeout=10s --retries=5 --start-period=30s \
  CMD sh -c "/apps/${APP_NAME}/scripts/process-healthcheck.sh \
  && /apps/${APP_NAME}/scripts/ls-healthcheck.sh /home/${HIP_USER}/nextcloud/"

COPY ./scripts/ scripts/

ENTRYPOINT ["./scripts/docker-entrypoint.sh"]
