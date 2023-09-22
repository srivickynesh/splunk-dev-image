ARG SPLUNK_VERSION=9.0.6

FROM docker.io/splunk/splunk:${SPLUNK_VERSION} AS builder
COPY --chmod=777 conf/ /opt/splunk/etc/apps/search/local/
COPY --chmod=755 scripts/splunk.sh /opt/splunk/splunk.sh
USER root
RUN umask 000 && touch "/opt/splunk/output.log" && \
    chmod -R 777 /opt/container_artifact/
USER ansible
RUN bash -o errexit /opt/splunk/splunk.sh

FROM docker.io/splunk/splunk:${SPLUNK_VERSION}
ENV SPLUNKD_SSL_ENABLE=false
EXPOSE 8000 8089 8088
COPY --chmod=777 --from=builder /opt/splunk/etc/apps/search/local/ /opt/splunk/etc/apps/search/local/
ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["start-service"]
