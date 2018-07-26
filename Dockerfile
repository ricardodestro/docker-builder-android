FROM macielbombonato/docker-builder:latest

LABEL maintainer "Maciel Escudero Bombonato <maciel.bombonato@gmail.com>"

WORKDIR /

USER root

# Update certificates
RUN update-ca-certificates

ENV ANDROID_HOME /opt/android-sdk
ENV GOPATH /opt/go

# Install gradle
RUN git config --global http.sslverify "false" \
 && wget --no-check-certificate https://services.gradle.org/distributions/gradle-4.7-bin.zip?_ga=2.231650783.1772064128.1527540661-637361431.1521740106 -O gradle-4.7-bin.zip \
 && unzip -d /opt gradle-4.7-bin.zip \
 && rm /gradle-4.7-bin.zip

ENV PATH $PATH:/opt/gradle-4.7/bin

# ------------------------------------------------------
# --- Pre-installed but not through apt-get

# install Go
#  from official binary package
RUN wget -q --no-check-certificate https://storage.googleapis.com/golang/go1.10.2.linux-amd64.tar.gz -O go-bins.tar.gz \
 && tar -C /usr/local -xvzf go-bins.tar.gz \
 && rm go-bins.tar.gz
# ENV setup
ENV PATH $PATH:/usr/local/go/bin
# Go Workspace dirs & envs
# From the official Golang Dockerfile
#  https://github.com/docker-library/golang
ENV PATH $GOPATH/bin:$PATH
# 755 because Ruby complains if 777 (warning: Insecure world writable dir ... in PATH)
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 755 "$GOPATH"

# ------------------------------------------------------
# --- Download Android SDK tools into $ANDROID_HOME
RUN cd /opt \
 && wget --no-check-certificate \
        https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip \
        -O /android-sdk-tools.zip \
 && unzip /android-sdk-tools.zip -d ${ANDROID_HOME} \
 && rm /android-sdk-tools.zip

ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools

# ------------------------------------------------------
# nvm environment variables
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 4.4.7

# install nvm
RUN groupadd --gid 1000 node \
  && useradd --uid 1000 --gid node --shell /bin/bash --create-home node

# gpg keys listed at https://github.com/nodejs/node#release-team
RUN set -ex \
  && for key in \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    56730D5401028683275BD23C23EFEFE93C4CFFFE \
    77984A986EBC2AA786BC0F66B01FBB92821C587A \
  ; do \
    gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
    gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
  done

ENV NODE_VERSION 9.11.1

RUN buildDeps='xz-utils' \
    && ARCH= && dpkgArch="$(dpkg --print-architecture)" \
    && case "${dpkgArch##*-}" in \
      amd64) ARCH='x64';; \
      ppc64el) ARCH='ppc64le';; \
      s390x) ARCH='s390x';; \
      arm64) ARCH='arm64';; \
      armhf) ARCH='armv7l';; \
      i386) ARCH='x86';; \
      *) echo "unsupported architecture"; exit 1 ;; \
    esac \
    && set -x \
    && apt-get update && apt-get install -y ca-certificates curl wget $buildDeps --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && wget --no-check-certificate "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.xz" \
    && wget --no-check-certificate "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
    && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
    && grep " node-v$NODE_VERSION-linux-$ARCH.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
    && tar -xJf "node-v$NODE_VERSION-linux-$ARCH.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
    && rm "node-v$NODE_VERSION-linux-$ARCH.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
    && apt-get purge -y --auto-remove $buildDeps \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs

ENV YARN_VERSION 1.5.1

RUN set -ex \
  && for key in \
    6A010C5166006599AA17F08146C2130DFD2497F5 \
  ; do \
    gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
    gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
  done \
  && wget --no-check-certificate "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
  && wget --no-check-certificate "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz.asc" \
  && gpg --batch --verify yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
  && mkdir -p /opt \
  && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/ \
  && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
  && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg \
  && rm yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz

# -----------------------------------------------------
# --- Install ionic and cordova
RUN npm config set registry http://registry.npmjs.org/ \
 && npm install -g ionic cordova

# ------------------------------------------------------
# --- Install Android SDKs and other build packages

USER root

# Other tools and resources of Android SDK
#  you should only install the packages you need!

# To prevent error in component installations is needed to create an empty file
# for repositories configuration
RUN touch touch /usr/local/share/android-sdk \
 && mkdir /root/.android \
 && touch /root/.android/repositories.cfg

# Accept licenses before installing components, no need to echo y for each component
# License is valid for all the standard components in versions installed from this file
# Non-standard components: MIPS system images, preview versions, GDK (Google Glass) and
# Android Google TV require separate licenses, not accepted there
RUN yes | sdkmanager --licenses

# Platform tools
RUN sdkmanager "emulator" "tools" "platform-tools"

# SDKs
# Please keep these in descending order!
# The `yes` is for accepting all non-standard tool licenses.

# Please keep all sections in descending order!
# If necessary, activate the components bellow
RUN sdkmanager --list \
 && yes | sdkmanager \
    "platforms;android-27" \
#    "platforms;android-26" \
#    "platforms;android-25" \
#    "platforms;android-24" \
#    "platforms;android-23" \
#    "platforms;android-22" \
#    "platforms;android-21" \
#    "platforms;android-19" \
#    "platforms;android-17" \
#    "platforms;android-15" \
    "build-tools;27.0.3" \
#    "build-tools;27.0.2" \
#    "build-tools;27.0.1" \
#    "build-tools;27.0.0" \
#    "build-tools;26.0.2" \
#    "build-tools;26.0.1" \
#    "build-tools;26.0.0" \
#    "build-tools;25.0.3" \
#    "build-tools;24.0.3" \
#    "build-tools;23.0.3" \
#    "build-tools;22.0.1" \
#    "build-tools;21.1.2" \
#    "build-tools;19.1.0" \
#    "build-tools;17.0.0" \
    "system-images;android-27;google_apis;x86" \
#    "system-images;android-26;google_apis;x86" \
#    "system-images;android-25;google_apis;armeabi-v7a" \
#    "system-images;android-24;default;armeabi-v7a" \
#    "system-images;android-22;default;armeabi-v7a" \
#    "system-images;android-19;default;armeabi-v7a" \
    "extras;android;m2repository" \
    "extras;google;m2repository" \
    "extras;google;google_play_services" \
    "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" \
    "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.1" \
#    "add-ons;addon-google_apis-google-24"
    "add-ons;addon-google_apis-google-23"
#    "add-ons;addon-google_apis-google-22" \
#    "add-ons;addon-google_apis-google-21"

# deleting sdk images
RUN rm -rf /opt/android-sdk/system-images \
 && mkdir /opt/android-sdk/system-images

################################################################################################
#Ruby
ENV RUBY_MAJOR 2.3
ENV RUBY_VERSION 2.3.3
ENV RUBY_DOWNLOAD_SHA256 1a4fa8c2885734ba37b97ffdb4a19b8fba0e8982606db02d936e65bac07419dc
ENV RUBYGEMS_VERSION 2.6.10
ENV BUNDLER_VERSION 1.14.3

###
### Install Ruby & bundler
###

RUN apt update \
 && apt install ruby`ruby -e 'puts RUBY_VERSION[/\d+\.\d+/]'`-dev --yes

RUN gem update \
 && gem install bundle \
 && gem install bundler --version "$BUNDLER_VERSION"

# install things globally, for great justice
# and don't create ".bundle" in all our apps
ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_PATH="$GEM_HOME" \
  BUNDLE_BIN="$GEM_HOME/bin" \
  BUNDLE_SILENCE_ROOT_WARNING=1 \
  BUNDLE_APP_CONFIG="$GEM_HOME"
RUN mkdir -p "$GEM_HOME" "$BUNDLE_BIN" \
  && chmod 777 "$GEM_HOME" "$BUNDLE_BIN"

# Cleaning
RUN apt-get clean --yes

# Create directory to host the application
WORKDIR /opt/app

CMD ["sdkmanager --version", "sdkmanager --list"]
