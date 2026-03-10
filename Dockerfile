# --- Stage 1: The Builder ---
FROM ubuntu:focal AS builder

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    ca-certificates wget unzip python3 && \
    rm -rf /var/lib/apt/lists/*

# Godot Versioning
ENV GODOT_VERSION="4.6.1"
ENV RELEASE_NAME="stable"
ARG TARGETARCH

# Download Godot and Web Templates
RUN if [ "$TARGETARCH" = "amd64" ]; then \
        export GODOT_ARCH="linux.x86_64"; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        export GODOT_ARCH="linux.arm64"; \
    fi && \
    wget https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-${RELEASE_NAME}/Godot_v${GODOT_VERSION}-${RELEASE_NAME}_${GODOT_ARCH}.zip -O godot.zip && \
    unzip godot.zip -d /usr/local/bin && \
    mv /usr/local/bin/Godot_v${GODOT_VERSION}-${RELEASE_NAME}_${GODOT_ARCH} /usr/local/bin/godot && \
    rm godot.zip
    

# Setup Templates (Required for the export to function)
RUN wget https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-${RELEASE_NAME}/Godot_v${GODOT_VERSION}-${RELEASE_NAME}_export_templates.tpz && \
    mkdir -p ~/.local/share/godot/export_templates/${GODOT_VERSION}.${RELEASE_NAME} && \
    unzip Godot_v${GODOT_VERSION}-${RELEASE_NAME}_export_templates.tpz && \
    mv templates/* ~/.local/share/godot/export_templates/${GODOT_VERSION}.${RELEASE_NAME} && \
    rm Godot_v${GODOT_VERSION}-${RELEASE_NAME}_export_templates.tpz

WORKDIR /src
COPY . .

# Create export directory and build
RUN mkdir -p build/web
# "Web" must match the name of your preset in export_presets.cfg
RUN godot --headless --export-release "Web" build/web/index.html

# --- Stage 2: The Tiny Server ---
FROM nginx:alpine

# 1. Create a mini config file for Nginx to inject your headers
RUN echo 'server { \
    listen 8080; \
    server_name localhost; \
    root /usr/share/nginx/html; \
    index index.html; \
    location / { \
        add_header "Cross-Origin-Opener-Policy" "same-origin"; \
        add_header "Cross-Origin-Embedder-Policy" "require-corp"; \
        add_header "Access-Control-Allow-Origin" "*"; \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

# 2. Copy the web artifacts from the builder
COPY --from=builder /src/build/web /usr/share/nginx/html

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]