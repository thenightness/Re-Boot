# --- Stage 1: The Builder ---
FROM ubuntu:focal AS builder

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    ca-certificates wget unzip python3 && \
    rm -rf /var/lib/apt/lists/*

# Godot Versioning
ENV GODOT_VERSION="4.6.1"
ENV RELEASE_NAME="stable"

# Download Godot and Web Templates
RUN wget https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-${RELEASE_NAME}/Godot_v${GODOT_VERSION}-${RELEASE_NAME}_linux.x86_64.zip \
    && wget https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-${RELEASE_NAME}/Godot_v${GODOT_VERSION}-${RELEASE_NAME}_export_templates.tpz

# Setup Templates (Required for the export to function)
RUN mkdir -p ~/.local/share/godot/export_templates/${GODOT_VERSION}.${RELEASE_NAME} \
    && unzip Godot_v${GODOT_VERSION}-${RELEASE_NAME}_linux.x86_64.zip -d /usr/local/bin \
    && mv /usr/local/bin/Godot_v${GODOT_VERSION}-${RELEASE_NAME}_linux.x86_64 /usr/local/bin/godot \
    && unzip Godot_v${GODOT_VERSION}-${RELEASE_NAME}_export_templates.tpz \
    && mv templates/* ~/.local/share/godot/export_templates/${GODOT_VERSION}.${RELEASE_NAME}

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