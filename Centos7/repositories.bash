#!/bin/bash
echo "             --------------------------WELCOME TO YUM OFFLINE REPOSITORY SETUP-----------------------------"
echo "Enter location of unmounted centOS iso file(default /dev/sr0 press enter) "
read loc;
if [[ ! -z $loc  ]]
	then
	loc= `echo /dev/sr0`
fi
  	echo "Mounting files......"
	mkdir /mnt/centos
	mount $loc /mnt/centos
	sleep 5
	echo "Copying Packages....."
	mkdir /repofiles
	cp -rf /mnt/centos/Packages/a* /repofiles
	 	
echo "Building Package database....."
createrepo -d /repofiles
echo "Creating repository entry in /etc/yum.repos.d....."
cat <<exit >> /etc/yum.repos.d/Centos.repo
[centos7]
name=CentOs7
baseurl=file:///repofiles/
enabled=1
gpgcheck=0
exit
echo "Cleaning cache and refreshing yum "
yum clean all >> /dev/null
yum repolist all >> /dev/null
echo "Setup is completed successfully"


