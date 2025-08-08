# ==============================================================================
# Add https://gitlab.com/pipeline-components/org/base-entrypoint
# ------------------------------------------------------------------------------
FROM pipelinecomponents/base-entrypoint:0.5.0 as entrypoint

# ==============================================================================
# Build process
# ------------------------------------------------------------------------------
FROM python:3.13.6-alpine3.22 as build
ENV PYTHONUSERBASE /app
ENV PATH "$PATH:/app/bin/"

WORKDIR /app/
COPY app /app/

# Adding dependencies
# hadolint ignore=DL3018
RUN \
    apk add --no-cache py3-install maturin cargo && \
    pip3 install --user --no-cache-dir --prefer-binary \
	-r requirements.txt

# ==============================================================================
# Component specific
# ------------------------------------------------------------------------------
FROM python:3.13.6-alpine3.22
ENV PYTHONUSERBASE /app
WORKDIR /app/
COPY app /app/
RUN pip install --no-cache-dir -r requirements.txt

# ==============================================================================
# Generic for all components
# ------------------------------------------------------------------------------
COPY --from=entrypoint /entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
ENV DEFAULTCMD ruff

WORKDIR /code/

# ==============================================================================
# Container meta information
# ------------------------------------------------------------------------------
ARG BUILD_DATE
ARG BUILD_REF

LABEL \
    maintainer="Robbert Müller <dev@pipeline-components.dev>" \
    org.opencontainers.image.title="Ruff" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="Pipeline Components" \
    org.opencontainers.image.authors="Robbert Müller <dev@pipeline-components.dev>" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://pipeline-components.dev/" \
    org.opencontainers.image.source="https://gitlab.com/pipeline-components/ruff/" \
    org.opencontainers.image.documentation="https://gitlab.com/pipeline-components/ruff/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION} \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.description="Ruff in a container for gitlab-ci" \
    org.label-schema.name="Ruff" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.url="https://pipeline-components.dev/" \
    org.label-schema.usage="https://gitlab.com/pipeline-components/ruff/blob/main/README.md" \
    org.label-schema.vcs-ref=${BUILD_REF} \
    org.label-schema.vcs-url="https://gitlab.com/pipeline-components/ruff/" \
    org.label-schema.vendor="Pipeline Components"
