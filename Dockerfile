FROM ruby:2.5.5

# throw errors if Gemfile has been modified since Gemfile.lock
#RUN bundle config --global frozen 1

WORKDIR /app

COPY Gemfile ./
RUN bundle install

COPY . .

EXPOSE 3000:3000

CMD ["bundle", "exec", "ruby", "bot.rb", "-p", "3000", "-e", "production"]  