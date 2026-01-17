#!/bin/bash
export RBENV_VERSION=3.3.7

export PATH="$(brew --prefix bison)/bin:$PATH"
export BOOST_ROOT="$(brew --prefix boost@1.85)"

# Check the CPU architecture
ARCH=$(uname -m)

# Check if running under Rosetta 2 emulation
if [[ "$ARCH" == "x86_64" && $(sysctl -n sysctl.proc_translated) == "1" ]]; then
  echo "Running on Apple Silicon under Rosetta 2 emulation"
  export LG_VADDR=39
elif [[ "$ARCH" == "arm64" ]]; then
  echo "Running on Apple Silicon"
  export LG_VADDR=39
else
  echo "Running on Intel Silicon"
  export LG_VADDR=48
fi

export CMAKE_ARGS="-DBoost_NO_BOOST_CMAKE=ON -DCMAKE_PREFIX_PATH=$BOOST_ROOT"

tebako press --root=./ --entry-point=trmnl-liquid-cli.rb --output trmnl-liquid-cli