# Docker Depencency Delay
<p align="left">
  <a href="https://github.com/RoboMagus/DockerDependencyDelay"><img src="https://img.shields.io/badge/github-grey?logo=github" alt="Github URL"/></a>
  <a href="https://hub.docker.com/r/robomagus/docker-dependency-delay"><img src="https://img.shields.io/badge/docker-hub-blue?logo=docker" alt="DockerHub URL"/></a>
  <img src="https://img.shields.io/docker/image-size/robomagus/docker-dependency-delay/latest" alt="Docker Image Size"/>
</p>

A hacky Docker image that hijacks dockers healthcheck and `depends_on` mechanism to delay startup of _other_ containers. This enables injection of dependencies on non-container related requirements, such as system uptime or file presence.

## Features

This image implements a HealthCheck that will remain in startup / unhealthy until a selection of requirements is satisfied. These can be configured using environment variables listed below. These requirements are skipped when no value is provided, and processed in the order listed.

- `MIN_SYSTEM_UPTIME`: System uptime (in seconds) must be greater than the value provided.
- `REQUIRED_FILES`: A list of Files or Directories that must exist, separated by `|`.
  - Useful for e.g. detecting the presence of removable media.
- `REQUIRED_CONTAINER_NAMES`: A list of Container names that must be up and **Healthy**, separated by `|`.
  - Enables implicit dependency on docker containers without the addional behavior of the `depends_on` option, such as the restart of the services listed under `depends_on` when a service is force-recreated.

## Example docker-compose config:

The following docker compose config causes the startup of `jellyfin` to be delayed until the system has been up at least 5 minutes, The external HDD is mounted (containing the media library), And [Authentik](https://github.com/goauthentik/authentik) authentication system is up and running.

```yaml
services:
  media_stack_delay:
    image: robomagus/docker-dependency-delay:latest
    container_name: media_stack_delay
    restart: unless-stopped
    environment:
      - MIN_SYSTEM_UPTIME=300
      - REQUIRED_FILES=/ext-storage/lost+found
      - REQUIRED_CONTAINER_NAMES=authentik_worker|authentik_server
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /ext-storage:/ext-storage:ro

  jellyfin:
    image: linuxserver/jellyfin:latest
    container_name: jellyfin
    restart: unless-stopped
    depends_on:
      media_stack_delay:
        condition: service_healthy
    volumes:
      - /ext-storage/data/media:/data

```

