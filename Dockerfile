FROM alpine

RUN apk add --no-cache bash docker jq

ADD --chmod=777 HealthCheckScript.sh .

ENV FlagFile=/dev/shm/ReqSucceeded

HEALTHCHECK --start-period=600s \
            --interval=15s \
            --timeout=2s \
            --retries=3 \
    CMD cat $FlagFile


ENTRYPOINT ["/HealthCheckScript.sh"]