#!/bin/bash
# Used by Hudson in deploy process
# Uses git-flow to create a release and commit version number changes

CheckExitCode()
{
  rc=$?
  if [ $rc != 0 ] ; then
    echo "Release Failed"
    exit $rc
  fi
}

echo '--- Releasing a new version ----------------'

echo '--- Make sure everything is up-to-date -----'
git checkout -f master
git pull origin master
git checkout -f develop
git pull origin develop

# get version number from version file
VERSION_LINE=`grep 'VERSION =' < lib/copperegg/ver.rb`
MAJOR_VERSION=`echo ${VERSION_LINE} | sed 's/\(.*VERSION = "\)\([0-9]*\).\([0-9]*\).\([0-9]*\)\(.pre[0-9]*"\)/\2/'`
MINOR_VERSION=`echo ${VERSION_LINE} | sed 's/\(.*VERSION = "\)\([0-9]*\).\([0-9]*\).\([0-9]*\)\(.pre[0-9]*"\)/\3/'`
RELEASE_VERSION=`echo ${VERSION_LINE} | sed 's/\(.*VERSION = "\)\([0-9]*\).\([0-9]*\).\([0-9]*\)\(.pre[0-9]*"\)/\4/'`
NEXT_RELEASE_VERSION=$(($RELEASE_VERSION+1))
CURRENT_VERSION="${MAJOR_VERSION}.${MINOR_VERSION}.${RELEASE_VERSION}"
NEXT_VERSION="${MAJOR_VERSION}.${MINOR_VERSION}.${NEXT_RELEASE_VERSION}"

echo VERSION_LINE=$VERSION_LINE
echo MAJOR_VERSION=$MAJOR_VERSION
echo MINOR_VERSION=$MINOR_VERSION
echo RELEASE_VERSION=$RELEASE_VERSION
echo NEXT_RELEASE_VERSION=$NEXT_RELEASE_VERSION
echo CURRENT_VERSION=$CURRENT_VERSION
echo NEXT_VERSION=$NEXT_VERSION
echo

echo '--- Start release branch -------------------'
# start release branch
git flow release start $CURRENT_VERSION
CheckExitCode

echo '--- Update version file --------------------'
# update version file and commit
sed 's/\(.*VERSION = "\)\(v[0-9][0-9.-]*\)\(.pre1\)\("\)/\1\2\4/' < lib/copperegg/ver.rb > lib/copperegg/ver.rb.new
rm lib/copperegg/ver.rb
mv lib/copperegg/ver.rb.new lib/copperegg/ver.rb
git commit -m "Deploying version ${CURRENT_VERSION}" lib/copperegg/ver.rb
CheckExitCode

echo '--- Finish release branch ------------------'
# finish release branch
git flow release finish -m "${CURRENT_VERSION}" $CURRENT_VERSION
CheckExitCode
git pull origin develop
#git push
CheckExitCode

echo '--- Bump dev version -----------------------'
# bump version on develop branch
CheckExitCode
SED_CMD='s/'"${CURRENT_VERSION}"'/'"${NEXT_VERSION}"'.pre/'
sed $SED_CMD < lib/copperegg/ver.rb > lib/copperegg/ver.rb.new
rm lib/copperegg/ver.rb
mv lib/copperegg/ver.rb.new lib/copperegg/ver.rb
git commit -m "Bumped development version to ${NEXT_VERSION}.pre" lib/copperegg/ver.rb
CheckExitCode
#git push
CheckExitCode

echo
echo
echo Remember to push to rubygems:
echo gem build copperegg.gemspec
echo gem push copperegg-$NEXT_VERSION.gem
echo
