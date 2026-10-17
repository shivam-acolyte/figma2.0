# syntax=docker/dockerfile:1
FROM rust:1.95-bookworm AS builder

WORKDIR /app
COPY . .

# Build the collaboration server in release mode
RUN cargo build --release -p figcraft-server

FROM debian:bookworm-slim
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/target/release/figcraft-server /usr/local/bin/figcraft-server

ENV PORT=10000
ENV DATA_DIR=/tmp/figcraft-data
ENV OPEN_PUBLISH=true

EXPOSE 10000

CMD ["figcraft-server"]
