# Build Stage
FROM node:20.12.2-bookworm AS builder
ARG PROFILE=release
ARG GIT_REVISION
ARG EVMOS_API
ARG EVMOS_RPC
ENV GIT_REVISION=$GIT_REVISION
WORKDIR "$WORKDIR/explorer"
COPY . .
COPY .env.scalar.json ./chains/mainnet/scalar.json
RUN yarn --ignore-engines && yarn build

# Production Image
FROM nginx:1.27.0-bookworm AS runtime

# Install required packages
RUN apt-get update && apt-get install -y ca-certificates curl

# Copy build artifacts from the builder stage
COPY --from=builder /$WORKDIR/explorer/dist /usr/share/nginx/html

ARG BUILD_DATE
ARG GIT_REVISION
LABEL build-date=$BUILD_DATE
LABEL git-revision=$GIT_REVISION

# Expose the port nginx is serving on
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
