FROM docker:27-cli AS dockercli

FROM python:3.12-alpine

COPY --from=dockercli /usr/local/bin/docker /usr/local/bin/docker

WORKDIR /app
COPY server.py /app/server.py

EXPOSE 8080

CMD ["python", "-u", "/app/server.py"]
