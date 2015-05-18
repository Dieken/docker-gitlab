FROM debian:jessie
MAINTAINER Yubao Liu <yubao.liu@yahoo.com>

COPY assets/setup/ /app/setup/

RUN mv /etc/apt/sources.list /etc/apt/sources.list.old \
 && cp /app/setup/mirrors.aliyun.com-jessie.list /etc/apt/sources.list.d/ \
 && export APT_LISTBUGS_FRONTEND=none \
 && export APT_LISTCHANGES_FRONTEND=none \
 && export DEBIAN_FRONTEND=noninteractive \
 && export DEBCONF_DB_FALLBACK="File{filename:/app/setup/debconf-db.fallback}" \
 && apt-get update \
 && apt-get install -y apt-utils git less perl-modules pwgen vim-tiny whiptail \
 && ( cd /etc && git init && chmod 700 .git && git config user.email "root@localhost" ) \
 && apt-get dist-upgrade -y \
 && apt-get install -y etckeeper postfix sudo wget net-tools ca-certificates unzip \
 && sed -i -e "s/`hostname`/git/g" /etc/postfix/main.cf \
 && newaliases \
 && apt-get install -y supervisor logrotate locales \
      nginx openssh-server postgresql-client redis-tools \
      git ruby bundler python python-docutils nodejs \
      libkrb5-3 libpq5 zlib1g libyaml-0-2 libssl1.0.0 \
      libgdbm3 libreadline6 libncurses5 libffi6 \
      libxml2 libxslt1.1 libcurl3 libicu52 \
 && update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX \
 && locale-gen en_US.UTF-8 \
 && dpkg-reconfigure locales \
 && gem sources -c \
 && gem sources -a https://ruby.taobao.org/ \
 && gem sources -a http://mirrors.aliyun.com/rubygems/ \
 && rm -rf /var/lib/apt/lists/* # 20150504

RUN chmod 755 /app/setup/install
RUN /app/setup/install

COPY assets/config/ /app/setup/config/
COPY assets/init /app/init
RUN chmod 755 /app/init

EXPOSE 22
EXPOSE 80
EXPOSE 443

VOLUME ["/home/git/data"]
VOLUME ["/var/log/gitlab"]

WORKDIR /home/git/gitlab
ENTRYPOINT ["/app/init"]
CMD ["app:start"]
