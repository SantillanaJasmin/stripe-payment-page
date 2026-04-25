FROM ruby:4.0.3

# install dependencies
WORKDIR /home/app
RUN curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/yarn-archive-keyring.gpg && \
    curl -fsSL https://deb.nodesource.com/setup_current.x | bash - && \
    echo "deb [signed-by=/usr/share/keyrings/yarn-archive-keyring.gpg] https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update -qq && apt-get install -y postgresql-client nodejs yarn

# Create non-root user
RUN useradd app --create-home

# bundle install
WORKDIR /root
COPY Gemfile* ./

RUN bundle install --jobs 5

# copy app
WORKDIR /home/app/myapp
COPY --chown=app:app . ./

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

USER root