#!/bin/bash

function clean_default_plugins()
{
  # Keep plugin_list as short as possible
  echo "" > "$1/plugin_list.conf"
  disabled_plugins='plugins_ignored_by_default'
  for plugin in \
          ArticulatedSystemPlugin   \
          Geomagic                  \
          BeamAdapter               \
          CGALPlugin                \
          CImgPlugin                \
          CollisionOBBCapsule       \
          CSparseSolvers            \
          DiffusionSolver           \
          image                     \
          InvertibleFVM             \
          ManifoldTopologies        \
          ModelOrderReduction       \
          PluginExample             \
          Registration              \
          SceneCreator              \
          SensableEmulation         \
          ShapeMatchingPlugin       \
          SofaAssimp                \
          SofaCarving               \
          SofaDistanceGrid          \
          SofaDistanceGrid.CUDA     \
          SofaEulerianFluid         \
          SofaImplicitField         \
          SofaMatrix                \
          SoftRobots                \
          SofaSimpleGUI             \
          SofaSphFluid              \
          SofaValidation            \
          STLIB                     \
          VolumetricRendering       \
          CUDA                      \
      ; do
      disabled_plugins=$disabled_plugins'\|'$plugin
  done
  grep -v $disabled_plugins "$1/plugin_list.conf.default" >> "$1/plugin_list.conf"
}

function move_metis()
{
  INSTALL_DIR=$1

  cd $INSTALL_DIR
  echo "Starting metis relocation..."
  if [[ "$(uname)" != "Darwin" && "$(uname)" != "Linux" ]]; then
    echo " - moving $(find ~+ -type f -name "metis.dll" | head -n 1) into $INSTALL_DIR/bin/"
    mv $(find ~+ -type f -name "metis.dll" | head -n 1) $INSTALL_DIR/bin/ || true
    echo " - moving $(find ~+ -type f -name "metis.lib" | head -n 1) into $INSTALL_DIR/lib/"
    mv $(find ~+ -type f -name "metis.lib" | head -n 1) $INSTALL_DIR/lib/ || true
  elif [[ "$(uname)" == "Darwin" ]]; then
    echo " - moving $( find ~+ -type d -name "metis.framework" | head -n 1) into $INSTALL_DIR/lib/"
      mv $( find ~+ -type d -name "metis.framework" | head -n 1 ) $INSTALL_DIR/lib/
  else
    echo " - moving $( find ~+ -type f -name "libmetis*" | head -n 1) into $INSTALL_DIR/lib/"
    mv $( find ~+ -type f -name "libmetis*" | head -n 1) $INSTALL_DIR/lib/
  fi
  echo " - moving $(find ~+ -type d -name "metis" | grep lib/cmake/metis | head -n 1) into $INSTALL_DIR/lib/cmake/"
  mv $(find ~+ -type d -name "metis" | grep lib/cmake/metis | head -n 1) $INSTALL_DIR/lib/cmake/ || true
  echo " - moving $(find ~+ -type f -name "metis.h" | head -n 1) into $INSTALL_DIR/include/"
  mv $(find ~+ -type f -name "metis.h" | head -n 1) $INSTALL_DIR/include/ || true
}

function move_python()
{
  BUILD_DIR=$1
  INSTALL_DIR=$2

  cd $BUILD_DIR
  echo "Starting python bundled package relocation..."
  echo " - copying $(find ~+ -type d -name "python" | grep $BUILD_DIR/bin/python | head -n 1) $INSTALL_DIR/bin/"
  cp -a "$(find ~+ -type d -name "python" | grep $BUILD_DIR/bin/python | head -n 1)" "$INSTALL_DIR/bin/" || true
}

function move_python_libs()
{
  os="$(uname -s)"
  cd $INSTALL_DIR/plugins
  if [[ "$os" == "Darwin" ]]; then
    # Copy packages
    find ./ -type f |  sed -n 's|\(.*python3/site-packages\).*|\1|p' | uniq | grep -v '.*SofaPython3.*' | while IFS= read -r line; do
        cp -R ${line}/* ./SofaPython3/lib/python3/site-packages
        rm -rf ${line}
    done
  else
    # Copy packages
    find ./ -type f |  sed -n 's|\(.*python3/site-packages\).*|\1|p' | uniq | grep -v '.*SofaPython3.*' | while IFS= read -r line; do
        cp -r --preserve=links ${line}/* ./SofaPython3/lib/python3/site-packages
        rm -rf ${line}
    done
  fi
}