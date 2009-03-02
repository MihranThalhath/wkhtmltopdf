#!/bin/bash
svn status
v="$1.$2.$3"
echo "About to release $v" 
read -p "Are you sure you are ready: " N
[ "$N" != "YES" ] && exit

sed -ri "s/SET\(CPACK_PACKAGE_VERSION_MAJOR \"[0-9]+\"\)/SET(CPACK_PACKAGE_VERSION_MAJOR \"$1\")/" CMakeLists.txt
sed -ri "s/SET\(CPACK_PACKAGE_VERSION_MINOR \"[0-9]+\"\)/SET(CPACK_PACKAGE_VERSION_MINOR \"$2\")/" CMakeLists.txt
sed -ri "s/SET\(CPACK_PACKAGE_VERSION_PATCH \"[0-9]+\"\)/SET(CPACK_PACKAGE_VERSION_PATCH \"$3\")/" CMakeLists.txt
sed -ri "s/MAJOR_VERSION=[0-9]+ MINOR_VERSION=[0-9]+ PATCH_VERSION=[0-9]+/MAJOR_VERSION=$1 MINOR_VERSION=$2 PATCH_VERSION=$3/" wkhtmltopdf.pro

if !(make clean && make -j5); then
	echo "Build failed"
	exit 1
fi
if ! ./test.sh; then
	echo "Test failed"
	exit 1
fi

svn ci -m "Making ready for vertion $v" CMakeLists.txt wkhtmltopdf.pro
svn cp https://wkhtmltopdf.googlecode.com/svn/trunk https://wkhtmltopdf.googlecode.com/svn/tags/$v -m "Tagged $v"

rm -rf release-$v
mkdir release-$v
svn export . release-$v/wkhtmltopdf-$v
tar -cjvf release-$v/wkhtmltopdf-$v.tar.bz2 -C release-$v wkhtmltopdf-$v
strip wkhtmltopdf
tar -cjvf release-$v/wkhtmltopdf-$v-static.tar.bz2 wkhtmltopdf

