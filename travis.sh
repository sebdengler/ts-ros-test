#!/bin/bash


# Run Docker container
if ! [ "$IN_DOCKER" ]; then

  docker pull $DOCKER_IMAGE

  docker run \
    -e IN_DOCKER=true \
    -e TRAVIS_BRANCH \
    -e TRAVIS_BUILD_DIR \
    -v $(pwd):/root/$(basename $PWD) \
    -v $HOME/.ccache:/root/.ccache \
    -w /root/$(basename $PWD) \
    -t \
    $DOCKER_IMAGE /root/$(basename $PWD)/./$SCRIPT
  result=$?

  echo "r2 = $result"
  exit
fi


# Display system information
echo "##############################################"
uname -a
lsb_release -a
gcc --version
echo "CXXFLAGS = ${CXXFLAGS}"
cmake --version
echo "##############################################"


# Setup ROS
source /opt/ros/$(ls /opt/ros/)/setup.bash
export CCACHE_DIR=/root/ccache


# Prepare workspace
PROJECT_NAME="testing"
URL=${TRAVIS_BUILD_DIR/"/home/travis/build"/"https://github.com"}
cd /root
mkdir -p /catkin_ws/src
git clone $URL -b $TRAVIS_BRANCH /catkin_ws/src/$PROJECT_NAME


# Initialize git submodules
cd /catkin_ws/src/$PROJECT_NAME
git submodule update --init --recursive
cd ../..


# Lint
catkin_lint -W3 .

# Make
catkin_make_isolated || exit 1

# Test
#catkin_make run_tests
#catkin_test_results

#echo "r1 = $result"
