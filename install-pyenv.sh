yum install -y  gcc gcc-c++ make git patch openssl-devel zlib-devel readline-devel sqlite-devel bzip2-devel libffi-devel zlib

git clone git://github.com/yyuu/pyenv.git /pyenv

export PATH="/pyenv/bin:$PATH"
eval "$(pyenv init -)"

cat << HERE >> /etc/pyenvrc
export PATH="/pyenv/bin:$PATH"
eval "$(pyenv init -)"
HERE

pyenv install 2.7.15
pyenv versions

pyenv shell 2.7.15
pyenv global 2.7.15
pyenv versions
pyenv rehash
