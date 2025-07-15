# Use an official Ruby runtime as a parent image
FROM ruby:2.7.5

# Install Node.js and Yarn using the official Yarn package repository
RUN apt-get update -qq && apt-get install -y curl gnupg && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update -qq && apt-get install -y nodejs yarn

# Install the default MySQL client
RUN apt-get install -y default-mysql-client

# Set the working directory in the container
WORKDIR /app

# Copy the Gemfile and Gemfile.lock
COPY Gemfile* ./

# Ruby image comes with specific version of bundler installed - ensure version of bundler matches "BUNDLED_WITH" in Gemfile.lock
ENV BUNDLER_VERSION='2.4.22'
RUN gem install bundler --no-document -v '2.4.22'

# Install the necessary gems
RUN bundle install

# Copy the rest of the application code
COPY . .

# Precompile assets
RUN RAILS_ENV=development bundle exec rake assets:precompile

# Expose port 3001 to the outside world
EXPOSE 3001

# Start the Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]
