FROM public.ecr.aws/amazonlinux/amazonlinux:2023.7.20250428.1
LABEL maintainer="MINETA \"m10i\' Hiroki <m10i@0nyx.net>"

RUN set -x \
    && dnf -y upgrade \
    && dnf -y install git dkms sudo python3-pip gcc gcc-c++ \
                      make cmake ninja-build perl binutils \
                      glibc-static libstdc++-static \
                      libX11-devel libxkbcommon-x11-devel \
                      libXcomposite-devel libXrandr-devel \
                      libXtst-devel mesa-libgbm-devel \
                      alsa-lib-devel cups-devel xz gperf \
    && dnf clean all \
    && mkdir -p ~/workspace \
    && cd ~/workspace \
    && git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git \
    && export PATH="$PATH:/usr/lib/dkms:/root/workspace/depot_tools" \
    && mkdir ~/workspace/chromium \
    && cd ~/workspace/chromium \
    && fetch --nohooks --no-history chromium \
    && cd src \
    && ./build/linux/sysroot_scripts/install-sysroot.py --arch=arm64 \
    && gclient runhooks \
    && gn gen out/Headless \
       --args='target_os="linux" target_cpu="arm64" is_debug=false is_component_build=false' \
    && chmod +x /root/workspace/chromium/src/third_party/node/linux/node-linux-x64/bin/node \
    && autoninja -C out/Headless headless_shell chrome_100_percent.pak chrome_200_percent.pak resources.pak \
    && mkdir -p /opt/chromium/headless_shell \
    && cp -r ./out/Headless/headless_shell /opt/chromium/headless_shell/ \
    && cp ./out/Headless/chrome_100_percent.pak /opt/chromium/headless_shell/ \
    && cp ./out/Headless/chrome_200_percent.pak /opt/chromium/headless_shell/ \
    && cp ./out/Headless/icudtl.dat /opt/chromium/headless_shell/ \
    && cp ./out/Headless/resources.pak /opt/chromium/headless_shell/ \
    && cp ./out/Headless/v8_context_snapshot.bin /opt/chromium/headless_shell/ \
    && cd /opt/ \
    && tar -czf ./chromium_headless_shell.tar.gz ./chromium \
    && dnf -y remove git dkms gcc gcc-c++ \
                      make cmake ninja-build perl binutils \
                      glibc-static libstdc++-static \
                      libX11-devel libxkbcommon-x11-devel \
                      libXcomposite-devel libXrandr-devel \
                      libXtst-devel mesa-libgbm-devel \
                      alsa-lib-devel cups-devel xz gperf \
    && dnf clean all \
    && rm -rf ~/workspace

CMD ["bash"]
