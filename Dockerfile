FROM continuumio/miniconda3

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    postgresql-client \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Handle Zscaler certificate if provided
ARG ZSCALER_CERT=""
RUN if [ -n "$ZSCALER_CERT" ] && [ -f "$ZSCALER_CERT" ]; then \
        cp "$ZSCALER_CERT" /usr/local/share/ca-certificates/zscaler.crt && \
        update-ca-certificates; \
    fi

# Set proxy environment variables
ENV HTTP_PROXY=${HTTP_PROXY} \
    HTTPS_PROXY=${HTTPS_PROXY} \
    NO_PROXY=${NO_PROXY} \
    http_proxy=${HTTP_PROXY} \
    https_proxy=${HTTPS_PROXY} \
    no_proxy=${NO_PROXY}

# Configure conda environment
WORKDIR /app
COPY environment.yml .
RUN conda env create -f environment.yml

# Configure conda to use proxy if needed
RUN if [ ! -z "$HTTP_PROXY" ]; then \
    conda config --set ssl_verify /etc/ssl/certs/ca-certificates.crt && \
    conda config --set proxy_servers.http $HTTP_PROXY && \
    conda config --set proxy_servers.https $HTTPS_PROXY; \
    fi

# Copy application code
COPY . .

EXPOSE 8501
CMD ["streamlit", "run", "app.py"]
