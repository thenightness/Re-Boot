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
FROM busybox:latest

# Create a non-root user for security
RUN adduser -D static
USER static
WORKDIR /home/static

# Copy only the web artifacts from the builder
COPY --from=builder /src/build/web .

# Serve the files on port 8080
# -p: port, -h: home directory, -f: run in foreground
CMD ["httpd", "-f", "-p", "8080", "-h", "/home/static"]