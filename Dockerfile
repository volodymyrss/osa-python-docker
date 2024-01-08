FROM centos:7

RUN yum -y install epel-release
RUN yum -y update
RUN yum -y install gcc gcc-c++ gcc-gfortran \
		git curl make zlib-devel bzip2 bzip2-devel \
		readline-devel sqlite sqlite-devel \
		patch libjpeg libpng12 libX11 \
		which libXpm libXext curlftpfs wget libgfortran file \
		ruby-devel fpm rpm-build \
		openssl-devel openssl11-devel openssl11-lib \
		ncurses-devel \
		libXt-devel libX11-devel libXpm-devel libXft-devel libXext-devel \
		cmake pcre-devel mesa-libGL-devel mesa-libGLU-devel glew-devel ftgl-devel \
		mysql-devel fftw-devel cfitsio-devel graphviz-devel avahi-compat-libdns_sd-devel libldap-dev python-devel libxml2-devel gsl-static gsl-devel\
		compat-gcc-44 compat-gcc-44-c++ compat-gcc-44-c++.gfortran \
		perl-ExtUtils-MakeMaker \
		net-tools strace sshfs sudo iptables \
		libyaml-devel  \
		git patch zlib-devel readline-devel sqlite-devel bzip2-devel libffi-devel zlib python36u-tkinter.x86_64 \
		wcslib-devel swig \
		libcurl4 \
		libcurl4-gnutls-dev \
		libncurses5-dev \
		libreadline6-dev \
		make \
		ncurses-dev \
		perl-modules \
		python3-dev \
		python3-pip \
		python3-setuptools \
		python-is-python3 \
		wget \
		xorg-dev 

        
RUN yum install -y centos-release-scl
RUN yum install -y devtoolset-7*

RUN ln -s /usr/lib64/libpcre.so.1 /usr/lib64/libpcre.so.0

# OSA 

ARG OSA_VERSION=11.2-20220322-170352
ARG OSA_PLATFORM=CentOS_7.8.2003_x86_64

RUN cd /opt/ && \
    if [ ${OSA_VERSION} == "10.2" ]; then \
        echo "with OSA11, we will always install OSA10.2 for compatibility"; \
    else \
        wget -q https://www.isdc.unige.ch/~savchenk/gitlab-ci/integral/build/osa-build-binary-tarball/${OSA_PLATFORM}/${OSA_VERSION}/build-latest/osa-${OSA_VERSION}-${OSA_PLATFORM}.tar.gz && \
        tar xzf osa-${OSA_VERSION}-*.tar.gz && \
        rm -fv osa-${OSA_VERSION}-*.tar.gz && \
        mv osa11 osa; \
    fi && \
    wget -q https://www.isdc.unige.ch/integral/download/osa/sw/10.2/osa10.2-bin-linux64.tar.gz && \
    tar xzf osa10.2-bin-linux64.tar.gz && \
    rm -fv osa10.2-bin-linux64.tar.gz

ARG isdc_ref_cat_version=43.0

RUN wget -q https://www.isdc.unige.ch/integral/download/osa/cat/osa_cat-${isdc_ref_cat_version}.tar.gz && \
    tar xvzf osa_cat-${isdc_ref_cat_version}.tar.gz && \
    mkdir -pv /data/ && \
    mv osa_cat-${isdc_ref_cat_version}/cat /data/ && \
    rm -rf osa_cat-${isdc_ref_cat_version}

RUN wget -q https://ds9.si.edu/download/centos7/ds9.centos7.8.5.tar.gz && \
    tar xvfz ds9.centos*.tar.gz && \
    chmod a+x ds9 && \
    mv ds9 /usr/local/bin && \
    rm -f ds9.centos*.tar.gz

ADD init.sh /init.sh

# python

RUN git clone https://github.com/yyuu/pyenv.git /pyenv

ARG python_version=3.10.11

RUN echo 'export PYENV_ROOT="/pyenv"' >> /etc/pyenvrc && \
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> /etc/pyenvrc && \
    echo 'eval "$(pyenv init --path)"' >> /etc/pyenvrc && \
    echo 'eval "$(pyenv init -)"' >> /etc/pyenvrc


RUN source /etc/pyenvrc && which pyenv && PYTHON_CONFIGURE_OPTS="--enable-shared"  CFLAGS="-fPIC -I/usr/include/openssl11" CXXFLAGS="-fPIC -I/usr/include/openssl11" LDFLAGS="-L/usr/lib64/openssl11 -lssl -lcrypto" pyenv install $python_version && pyenv versions
RUN source /etc/pyenvrc && pyenv shell $python_version && pyenv global $python_version && pyenv versions && pyenv rehash

RUN echo 'source /etc/pyenvrc' >> /init.sh

RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
    source /init.sh && pip install pip --upgrade

# Needed for pyxspec
RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
    source /init.sh && \
    pip install numpy scipy ipython jupyter matplotlib pandas astropy 

ARG heasoft_version=6.28

ADD build-heasoft.sh /build-heasoft.sh

RUN echo '. /opt/rh/devtoolset-7/enable' >> /init.sh
    
RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
    source /init.sh && \
    rm -rf /opt/heasoft && \
    bash build-heasoft.sh download

RUN p=$(ls -d /opt/heasoft/x86*/); echo "found HEADAS: $p"; echo 'export HEADAS="'$p'"; source $HEADAS/headas-init.sh' >> /init.sh

RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
    source /init.sh && \
    python -c 'import xspec; print(xspec.__file__)' 

RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
    source /init.sh && \
    git clone https://github.com/volodymyrss/heasoft-heasp.git /heasoft-heasp && \
    cd /heasoft-heasp/python && \
    swig -python -c++ -classic heasp.i && \
    hmake install && \
    cd /heasoft-heasp && \
    hmake install

#pip install -r https://raw.githubusercontent.com/volodymyrss/data-analysis/master/requirements.txt && \
#Removed healpy version from requirements
#ADD data-analysis-requirements.txt /tmp/data-analysis-requirements.txt
#    pip install -r /tmp/data-analysis-requirements.txt && \

RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
    source /init.sh && \
    pip install git+https://github.com/volodymyrss/data-analysis && \
    pip install git+https://github.com/volodymyrss/pilton && \
    pip install git+https://github.com/volodymyrss/dda-ddosa \
    pip install git+https://github.com/volodymyrss/dqueue.git


ADD activate.sh /activate.sh

RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
    source /init.sh && \
    pip install pip --ignore-installed --upgrade 

RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
    source /init.sh && \
    pip install pygsl --ignore-installed --upgrade
# 3ml

RUN git clone https://github.com/ferrigno/astromodels.git && \
    export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
    source /init.sh && \
    ls -lotr && \
    pip install "packaging<22.0,>=21.3" tempita && \
    cd /astromodels/ && python setup.py install && pip install .

RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
    source /init.sh && \
    pip install llvmlite --ignore-installed --upgrade

RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
    source /init.sh && \
    pip freeze | grep numba && \
    pip uninstall -y numba && \
    pip install numba --ignore-installed --upgrade && \
    python -c 'import astromodels; print(astromodels.__file__)' 

RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
    source /init.sh && \
    pip install jupyter

RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
    source /init.sh && \
    pip install pymysql peewee

ADD tests /tests

RUN source /init.sh; pip install jupyterlab

ENTRYPOINT bash -c 'export HOME_OVERRRIDE=/home/jovyan; cd /home/jovyan; source /init.sh; jupyter lab --ip 0.0.0.0 --no-browser'
