# Copyright 2017-2018 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You
# may not use this file except in compliance with the License. A copy of
# the License is located at
#
#     http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
# ANY KIND, either express or implied. See the License for the specific
# language governing permissions and limitations under the License.

# For more information on creating a Dockerfile
# https://docs.docker.com/compose/gettingstarted/#step-2-create-a-dockerfile
# https://github.com/awslabs/amazon-sagemaker-examples/master/advanced_functionality/pytorch_extending_our_containers/pytorch_extending_our_containers.ipynb
# ARG REGION=us-east-1
ARG REGION=cn-northwest-1

# SageMaker PyTorch image
#FROM 520713654638.dkr.ecr.$REGION.amazonaws.com/sagemaker-pytorch:1.4.0-gpu-py3
#FROM 763104351884.dkr.ecr.$REGION.amazonaws.com/pytorch-training:1.4.0-gpu-py3
FROM pytorch/pytorch:1.6.0-cuda10.1-cudnn7-devel

ENV PATH="/opt/ml/code:${PATH}"

### Install nginx notebook
RUN apt-get -y update && apt-get install -y --no-install-recommends \
         wget \
         nginx \
         ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

# /opt/ml and all subdirectories are utilized by SageMaker, we use the /code subdirectory to store our user code.
#RUN git clone https://github.com/whn09/OpenNRE.git /opt/ml/code
COPY ./ /opt/ml/code

# this environment variable is used by the SageMaker PyTorch container to determine our user code directory.
ENV SAGEMAKER_SUBMIT_DIRECTORY /opt/ml/code

# RUN pip config set global.index-url https://opentuna.cn/pypi/web/simple/
RUN pip install -r /opt/ml/code/requirements.txt

# RUN cd /opt/ml/code && python setup.py install

# this environment variable is used by the SageMaker PyTorch container to determine our program entry point
# for training and serving.
# For more information: https://github.com/aws/sagemaker-pytorch-container
# ENV SAGEMAKER_PROGRAM /opt/ml/code/example/train_finre_bertentity_softmax.py

WORKDIR /opt/ml/code