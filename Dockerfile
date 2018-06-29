# Copyright (C) 2015-2016 Intel Corporation
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

#FROM crops/yocto:debian-9-base
FROM crops/yocto:ubuntu-16.04-base

USER root

ADD https://raw.githubusercontent.com/crops/extsdk-container/master/restrict_useradd.sh  \
        https://raw.githubusercontent.com/crops/extsdk-container/master/restrict_groupadd.sh \
        https://raw.githubusercontent.com/crops/extsdk-container/master/usersetup.py \
        /usr/bin/
COPY poky-entry.py poky-launch.sh /usr/bin/
COPY sudoers.usersetup /etc/

# We remove the user because we add a new one of our own.
# The usersetup user is solely for adding a new user that has the same uid,
# as the workspace. 70 is an arbitrary *low* unused uid on debian.
RUN userdel -r yoctouser && \
    groupadd -g 70 usersetup && \
    useradd -N -m -u 70 -g 70 usersetup && \
    chmod 755 /usr/bin/usersetup.py \
        /usr/bin/poky-entry.py \
        /usr/bin/poky-launch.sh \
        /usr/lib/sudo/sudoers.so \
        /etc/sudoers \
        /etc/sudoers.d \
        /etc/sudoers.d/README \
        /usr/bin/restrict_groupadd.sh \
        /usr/bin/restrict_useradd.sh && \
    echo "#include /etc/sudoers.usersetup" >> /etc/sudoers

ADD http://storage.googleapis.com/git-repo-downloads/repo /usr/local/bin
RUN chmod a+rwx /usr/local/bin/repo && \
        rm /bin/sh && \
        ln -s bash /bin/sh

ENV http_proxy dockerhost:3128
ENV https_proxy dockerhost:3128
ENV ftp_proxy dockerhost:3128
RUN echo 'Acquire::http::proxy "http://dockerhost:3128/";' > /etc/apt/apt.conf && \
    echo 'exec socat STDIO PROXY:dockerhost:$1:$2,proxyport=3128' > /usr/local/bin/gitproxy && \
    chmod a+rwx /usr/local/bin/gitproxy && \
    git config --system core.gitproxy /usr/local/bin/gitproxy 

RUN apt-get update && \
    apt-get install -y \
        socat \
        libsdl1.2-dev \
        libx11-dev

USER usersetup
ENV LANG=en_US.UTF-8

ENTRYPOINT ["/usr/bin/dumb-init", "--", "/usr/bin/poky-entry.py"]
