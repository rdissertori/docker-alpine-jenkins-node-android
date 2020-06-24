FROM rdissertori/alpine-jenkins-node-base

ENV KOTLIN_VERSION "build-1.4.0-rc-47"
ENV KOTLIN_DOWNLOADURL "https://github.com/JetBrains/kotlin/archive/${KOTLIN_VERSION}.zip"
ENV ANDROID_SDK_VERSION "4333796"
ENV ANDROID_SDK_DOWNLOADURL "https://dl.google.com/android/repository/commandlinetools-linux-6514223_latest.zip"

ENV KOTLIN_HOME /opt/kotlin
ENV ANDROID_HOME /opt/android-sdk
ENV ANDROID_SDK_HOME $ANDROID_HOME
ENV PATH ${PATH}:${KOTLIN_HOME}/bin:${ANDROID_HOME}/emulator:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools/bin

USER root
COPY ./install.sh /tmp/install.sh
RUN apk add --update --no-cache --virtual virtual_packages build-base \
  && apk add --update --no-cache zip expect git gradle curl \
  && cd /opt \
  && curl -Ls ${KOTLIN_DOWNLOADURL} --output kotlin.zip \
  && unzip -q kotlin.zip \
  && rm kotlin.zip \
  && mkdir -p ${ANDROID_SDK_HOME} \
  && cd ${ANDROID_SDK_HOME} \
  && curl -Ls ${ANDROID_SDK_DOWNLOADURL} --output android-sdk.zip \
  && unzip -q android-sdk.zip \
  && rm android-sdk.zip \
  && cd /home/jenkins \
  && chmod +x /tmp/install.sh && /tmp/install.sh \
  && ln -s $ANDROID_HOME/build-tools/*/zipalign /usr/bin/zipalign \
  && chmod 777 -R $ANDROID_HOME \
  && apk del virtual_packages \
  && rm -rf /tmp/* \
  && chown -R jenkins:jenkins /home/jenkins && chown -R jenkins:jenkins /opt
USER jenkins
