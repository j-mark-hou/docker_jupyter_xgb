FROM jupyter/scipy-notebook

# set workdir to / and user to root so we can install some stuff
WORKDIR /
USER root

# install xgboost: http://xgboost.readthedocs.io/en/latest/build.html
RUN git clone --recursive https://github.com/dmlc/xgboost && \
    cd xgboost; make -j4
RUN cd xgboost/python-package && python setup.py install

#install cmake, which we need for lgb
RUN apt-get update  && \
	apt-get install -y cmake

# install lightgbm now
RUN git clone --recursive https://github.com/Microsoft/LightGBM &&\
	cd LightGBM && \
	mkdir build && \
	cd build && \
	cmake .. && \
	make -j4
RUN cd LightGBM/python-package && \
	python setup.py install

# re-set workdir to the previous place and user to the notebook user
# these env variables are defined in in https://github.com/jupyter/docker-stacks/blob/master/base-notebook/Dockerfile
USER $NB_UID 
WORKDIR $HOME

# run jupyter lab. see https://github.com/jupyter/docker-stacks/tree/master/base-notebook
#  basically, start.sh is a shell script for launching stuff, so we'll launch jupyter
CMD ["start.sh", "jupyter lab"]