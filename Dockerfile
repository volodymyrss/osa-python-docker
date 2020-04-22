FROM centos:7

RUN yum -y install epel-release
RUN yum -y update
RUN yum -y install gcc gcc-c++ gcc-gfortran \
                   git curl make zlib-devel bzip2 bzip2-devel \
                   readline-devel sqlite sqlite-devel openssl \
                   openssl-devel patch libjpeg libpng12 libX11 \
                   which libXpm libXext curlftpfs wget libgfortran file \
                   ruby-devel fpm rpm-build \
                   ncurses-devel \
                   libXt-devel libX11-devel libXpm-devel libXft-devel libXext-devel \
                   cmake openssl-devel pcre-devel mesa-libGL-devel mesa-libGLU-devel glew-devel ftgl-devel \
                   mysql-devel fftw-devel cfitsio-devel graphviz-devel avahi-compat-libdns_sd-devel libldap-dev python-devel libxml2-devel gsl-static \
                   compat-gcc-44 compat-gcc-44-c++ compat-gcc-44-c++.gfortran \
                   perl-ExtUtils-MakeMaker \
                   net-tools strace sshfs sudo iptables \
                   libyaml-devel  \
                   gcc gcc-c++ make git patch openssl-devel zlib-devel readline-devel sqlite-devel bzip2-devel libffi-devel zlib python36u-tkinter.x86_64 

RUN ln -s /usr/lib64/libpcre.so.1 /usr/lib64/libpcre.so.0

# OSA 

ARG OSA_VERSION=11.1-3-g87cee807-20200410-144247 
ARG OSA_PLATFORM=CentOS_7.7.1908_x86_64

RUN cd /opt/ && \
    if [ ${OSA_VERSION} == "10.2" ]; then \
        wget -q https://www.isdc.unige.ch/integral/download/osa/sw/10.2/osa10.2-bin-linux64.tar.gz && \
        tar xzf osa10.2-bin-linux64.tar.gz && \
        rm -fv osa10.2-bin-linux64.tar.gz && \
        mv osa10.2 osa; \
    else \
        wget -q https://www.isdc.unige.ch/~savchenk/gitlab-ci/integral/build/osa-build-binary-tarball/${OSA_PLATFORM}/${OSA_VERSION}/build-latest/osa-${OSA_VERSION}-${OSA_PLATFORM}.tar.gz && \
        tar xzf osa-${OSA_VERSION}-*.tar.gz && \
        rm -fv osa-${OSA_VERSION}-*.tar.gz && \
        mv osa11 osa; \
    fi 

ARG isdc_ref_cat_version=42.0

RUN wget -q https://www.isdc.unige.ch/integral/download/osa/cat/osa_cat-${isdc_ref_cat_version}.tar.gz && \
    tar xvzf osa_cat-${isdc_ref_cat_version}.tar.gz && \
    mkdir -pv /data/ && \
    mv osa_cat-${isdc_ref_cat_version}/cat /data/ && \
    rm -rf osa_cat-${isdc_ref_cat_version}

RUN wget -q http://ds9.si.edu/download/centos7/ds9.centos7.8.0.1.tar.gz && \
    tar xvfz ds9.centos7.8.0.1.tar.gz && \
    chmod a+x ds9 && \
    mv ds9 /usr/local/bin && \
    rm -f ds9.centos7.8.0.1.tar.gz

ADD init.sh /init.sh



# python

RUN git clone git://github.com/yyuu/pyenv.git /pyenv

ARG python_version=3.8.2

RUN echo 'export PYENV_ROOT=/pyenv; export PATH="/pyenv/bin:$PATH"' >> /etc/pyenvrc && \
    echo 'eval "$(pyenv init -)"' >> /etc/pyenvrc

RUN source /etc/pyenvrc && which pyenv && PYTHON_CONFIGURE_OPTS="--enable-shared"  CFLAGS="-fPIC" CXXFLAGS="-fPIC" pyenv install $python_version && pyenv versions
RUN source /etc/pyenvrc && pyenv shell $python_version && pyenv global $python_version && pyenv versions && pyenv rehash

RUN echo 'source /etc/pyenvrc' >> /init.sh

RUN yum install -y wcslib-devel swig

ARG heasoft_version=6.27.1

ADD build-heasoft.sh /build-heasoft.sh
RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
    source /init.sh && \
    rm -rf /opt/heasoft && \
    bash build-heasoft.sh download && \
    bash build-heasoft.sh build
    
RUN p=$(ls -d /opt/heasoft/x86*/); echo "found HEADAS: $p"; echo 'export HEADAS="'$p'"; source $HEADAS/headas-init.sh' >> /init.sh

RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
    source /init.sh && \
    git clone https://github.com/volodymyrss/heasoft-heasp.git /heasoft-heasp && \
    cd /heasoft-heasp/python && \
    swig -python -c++ -classic heasp.i && \
    hmake install && \
    cd /heasoft-heasp && \
    hmake install




RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
    source /init.sh && \
    python -c 'import xspec; print(xspec.__file__)' && \
    pip install numpy scipy ipython jupyter matplotlib pandas astropy==2.0.11


#RUN cat /init.sh | awk 'BEGIN {print "HOME_OVERRRIDE=/tmp/home"} 1' > /init-t.sh && mv /init-t.sh /init.sh


RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
    source /init.sh && \
    pip install -r https://raw.githubusercontent.com/volodymyrss/data-analysis/master/requirements.txt && \
    pip install git+https://github.com/volodymyrss/data-analysis@py3 && \
    pip install git+https://github.com/volodymyrss/pilton && \
    pip install git+https://github.com/volodymyrss/dda-ddosa

#RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
    source /init.sh && \
    pip install git+https://github.com/volodymyrss/dqueue.git


ADD activate.sh /activate.sh


# 3ml

RUN git clone https://github.com/threeML/astromodels.git && \
    export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
    source /init.sh && \
    ls -lotr && \
    cd /astromodels/ && python setup.py install && pip install .

RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
    source /init.sh && \
    python -c 'import astromodels; print(astromodels.__file__)' 


RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
    source /init.sh && \
    pip install jupyter

RUN export HOME_OVERRRIDE=/tmp/home && mkdir -pv /tmp/home/pfiles && \
    source /init.sh && \
    pip install pymysql peewee

ADD tests /tests
