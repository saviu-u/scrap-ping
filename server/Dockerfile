FROM ruby:2.6.5

ENV LANG C.UTF-8
ENV TZ=America/Sao_Paulo

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

RUN gem install bundler

RUN mkdir /app
WORKDIR /app
COPY . /app

RUN bundle install

# COPY /app/scripts/entrypoint.sh /usr/bin/
# ENTRYPOINT ["entrypoint.sh"]
RUN chmod +x /app/scripts/entrypoint.sh