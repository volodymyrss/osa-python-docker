set -xe

ls -l  /opt/heasoft/x86_64-pc-linux-gnu-libc2.17/headas-init.sh
ls -l  /opt/heasoft/x86_64-pc-linux-gnu-libc2.17/headas-init.csh

#unlink /opt/heasoft/x86_64-pc-linux-gnu-libc2.17/headas-init.csh
#unlink /opt/heasoft/x86_64-pc-linux-gnu-libc2.17/headas-init.sh

rm -fv /opt/heasoft/x86_64-pc-linux-gnu-libc2.17/headas-init.sh
rm -fv /opt/heasoft/x86_64-pc-linux-gnu-libc2.17/headas-init.csh

cd /dist/heatools/BUILD_DIR
./configure --prefix=/opt/heasoft/
sed -i  's@HD_TOP_PFX=""@HD_TOP_PFX="/opt/heasoft"@; s@HD_TOP_EXEC_PFX=""@HD_TOP_EXEC_PFX="/opt/heasoft/"@' hmakerc
hmake
hmake install

rm -fv /opt/heasoft/x86_64-pc-linux-gnu-libc2.17/headas-init.sh
rm -fv /opt/heasoft/x86_64-pc-linux-gnu-libc2.17/headas-init.csh

cd /dist/attitude/BUILD_DIR/
./configure --prefix=/opt/heasoft/ 
sed -i  's@HD_TOP_PFX=""@HD_TOP_PFX="/opt/heasoft"@; s@HD_TOP_EXEC_PFX=""@HD_TOP_EXEC_PFX="/opt/heasoft/"@' hmakerc
hmake
hmake install

rm -fv /opt/heasoft/x86_64-pc-linux-gnu-libc2.17/headas-init.sh
rm -fv /opt/heasoft/x86_64-pc-linux-gnu-libc2.17/headas-init.csh

cd /dist/Xspec/BUILD_DIR
./configure --prefix=/opt/heasoft/ --with-heatools=/dist/heatools --with-attitude=/dist/attitude
hmake install

cd /dist/heatools/BUILD_DIR
./configure --prefix=/opt/heasoft/
sed -i  's@HD_TOP_PFX=""@HD_TOP_PFX="/opt/heasoft"@; s@HD_TOP_EXEC_PFX=""@HD_TOP_EXEC_PFX="/opt/heasoft/"@' hmakerc
hmake
hmake install

cd /opt/heasoft/x86_64-pc-linux-gnu-libc2.17/
ln -s  BUILD_DIR/headas-init.sh headas-init.sh 
ln -s   BUILD_DIR/headas-init.csh headas-init.csh

ls -l  /opt/heasoft/x86_64-pc-linux-gnu-libc2.17/headas-init.sh
ls -l  /opt/heasoft/x86_64-pc-linux-gnu-libc2.17/headas-init.csh
cat  /opt/heasoft/x86_64-pc-linux-gnu-libc2.17/headas-init.sh
cat  /opt/heasoft/x86_64-pc-linux-gnu-libc2.17/headas-init.csh
