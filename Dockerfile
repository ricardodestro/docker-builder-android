FROM openjdk:8-jdk

LABEL maintainer "maciel.bombonato@gmail.com"

ENV ANDROID_HOME /opt/android-sdk
ENV GOPATH /opt/go

# ------------------------------------------------------
# --- Base pre-installation

# --- Remove another maven installations and prepare to 
# install required packages

# Generate proper EN US UTF-8 locale
# Install the "locales" package - required for locale-gen
RUN apt-get update --yes
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get install -y locales \
# Do Locale gen
    && locale-gen en_US.UTF-8

RUN dpkg --add-architecture i386 \
 && apt-get update --yes \
 && DEBIAN_FRONTEND=noninteractive \
 && apt-get -y install \
# Requiered
    apt-utils \
    git \
    mercurial \
    curl \
    wget \
    rsync \
    sudo \
    expect \
# Python
    python \
    python-dev \
    python-pip \
# Common, useful
    build-essential \
    zip \
    unzip \
    tree \
    clang \
    imagemagick \
    awscli \
# For PPAs
    software-properties-common \
# Build tools
    maven \
# Dependencies to execute Android builds
    openjdk-8-jdk \
    libc6:i386 \
    libstdc++6:i386 \
    libgcc1:i386 \
    libncurses5:i386 \
    libz1:i386

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get install -y \
    nodejs

# Install gradle
RUN git config --global http.sslverify "false" \
 && wget --no-check-certificate https://services.gradle.org/distributions/gradle-4.7-bin.zip?_ga=2.231650783.1772064128.1527540661-637361431.1521740106 -O gradle-4.7-bin.zip \
 && unzip -d /opt gradle-4.7-bin.zip

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
    && wget -q --no-check-certificate \
        https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip \
        -O android-sdk-tools.zip \
    && unzip android-sdk-tools.zip -d ${ANDROID_HOME} \
    && rm android-sdk-tools.zip

ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools

# ------------------------------------------------------
# --- Pre-install Ionic and Cordova CLIs
#RUN apt install --yes npm 
#RUN npm config set registry http://registry.npmjs.org/
#RUN npm install -g ionic cordova

# ------------------------------------------------------
# --- Install Android SDKs and other build packages

# Other tools and resources of Android SDK
#  you should only install the packages you need!
# To get a full list of available options you can use:
RUN sdkmanager --list

# To prevent error in component installations is needed to create an empty file
# for repositories configuration
RUN touch /root/.android/repositories.cfg

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
RUN yes | sdkmanager \
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
    "system-images;android-26;google_apis;x86" \
#    "system-images;android-25;google_apis;armeabi-v7a" \
#    "system-images;android-24;default;armeabi-v7a" \
#    "system-images;android-22;default;armeabi-v7a" \
#    "system-images;android-19;default;armeabi-v7a" \
    "extras;android;m2repository" \
    "extras;google;m2repository" \
    "extras;google;google_play_services" \
    "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" \
    "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.1" \
    "add-ons;addon-google_apis-google-23" 
#    "add-ons;addon-google_apis-google-22" \
#    "add-ons;addon-google_apis-google-21"

# deleting sdk images 
RUN rm -rf /opt/android-sdk/system-images \
 && mkdir /opt/android-sdk/system-images

# Cleaning
RUN apt-get clean --yes

# ---------------------------------------------------------------
# Install buck

RUN wget --no-check-certificate https://github.com/facebook/buck/releases/download/v2018.03.26.01/buck_2018.03.26_all.deb -O buck_2018.03.26_all.deb \
 && dpkg -i buck_2018.03.26_all.deb \
 && buck --version


# Create directory to host the application
RUN mkdir /opt/app
WORKDIR /opt/app