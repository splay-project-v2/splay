FROM ruby:2.5.1
LABEL Description="Splay - WebApp - Web application for Splay"

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /myapp
WORKDIR /myapp
COPY Gemfile* ./
RUN bundle install
COPY . .
EXPOSE 80
CMD ["rails", "server", "-p", "80", "-b", "0.0.0.0"]