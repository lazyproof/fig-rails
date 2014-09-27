FROM phusion/baseimage:0.9.13

ENV HOME /root

CMD ["/sbin/my_init"]

# Install Java and node
RUN sudo add-apt-repository ppa:webupd8team/java
RUN sudo add-apt-repository ppa:chris-lea/node.js && sudo apt-get update
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
RUN sudo apt-get install -y --no-install-recommends oracle-java8-installer
RUN sudo apt-get install oracle-java8-set-default
RUN sudo apt-get install -y nodejs
RUN sudo apt-get autoremove -y && apt-get clean
ENV JRUBY_VERSION 1.7.15
RUN curl http://jruby.org.s3.amazonaws.com/downloads/$JRUBY_VERSION/jruby-bin-$JRUBY_VERSION.tar.gz | tar xz -C /opt
ENV PATH /opt/jruby-$JRUBY_VERSION/bin:$PATH

# set gem, update, bundle
RUN echo gem: --no-document >> /etc/gemrc
RUN gem update --system
RUN gem install bundler

# Add group
RUN addgroup --gid 9999 app
# Add User
RUN adduser --uid 9999 --gid 9999 --disabled-password --gecos "Application" app
RUN usermod -L app
# Make homedir for app user
RUN mkdir -p /home/app/my_app
# Share this folder with app folder
ADD . /home/app/my_app
RUN chown -R app:app /home/app/

USER app

ENV PATH /opt/jruby-$JRUBY_VERSION/bin:$PATH
RUN echo compat.version=2.0 > /home/app/.jrubyrc
RUN echo invokedynamic.all=true >> /home/app/.jrubyrc

WORKDIR /home/app/my_app
# RUN bundle install
# ADD Gemfile /myapp/Gemfile
# ENV RAILS_ENV staging
# RUN bundle exec rake db:reset
# RUN bundle install --deployment --without test development
# RUN bundle exec rake db:reset
# EXPOSE 3000
# ENTRYPOINT bundle exec rails server
ADD . /home/app/my_app

