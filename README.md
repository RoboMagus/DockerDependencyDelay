
# Docker Depencency Delay

A hacky Docker image that can be used to force a delayed startup on dependent containers.

## Features

This image implements a HealthCheck that will remain in startup / unhealthy until a selection of requirements is satisfied. These can be configured using environment variables listed below. These requirements are skipped when no value is provided, and processed in the order listed.

- `MIN_SYSTEM_UPTIME`: System uptime (in seconds) must be greater than the value provided.
- `REQUIRED_FILES`: A list of Files or Directories that must exist, separated by `|`.
  - Useful for e.g. detecting the presence of removable media.
- `REQUIRED_CONTAINER_NAMES`: A list of Container names that must be up and **Healthy**, separated by `|`.
  - Enables implicit dependency on docker containers without the addional behavior of the `depends_on` option.


