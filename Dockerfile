# Build Stage
FROM ubuntu:20.04 AS builder

ARG PROFILE=release
ARG GIT_REVISION
ENV GIT_REVISION=$GIT_REVISION

# Install required packages
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    libssl-dev

# Install nvm
ENV NVM_DIR /root/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

# Install Node.js via nvm
RUN bash -c "source $NVM_DIR/nvm.sh && nvm install node && nvm use node && nvm alias default node"

# Install latest npm
RUN bash -c "source $NVM_DIR/nvm.sh && nvm use node && npm install -g npm"

# Install yarn globally
RUN bash -c "source $NVM_DIR/nvm.sh && nvm use node && npm install --global yarn"

# Set PATH
ENV PATH $NVM_DIR/versions/node/$(nvm version)/bin:$PATH

# Set workdir and copy application files
WORKDIR /app/ping-pub-explorer
COPY . .

# Install application dependencies and build the application
RUN bash -c "source $NVM_DIR/nvm.sh && nvm use node && yarn install && yarn --ignore-engines && yarn build"

# Production Image
FROM nginx:1.27.0-bookworm AS runtime

# Install required packages
RUN apt-get update && apt-get install -y ca-certificates curl

# Copy build artifacts from the builder stage
COPY --from=builder /app/ping-pub-explorer/dist /usr/share/nginx/html

ARG BUILD_DATE
ARG GIT_REVISION
LABEL build-date=$BUILD_DATE
LABEL git-revision=$GIT_REVISION

# Expose the port nginx is serving on
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
