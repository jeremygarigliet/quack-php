# QuAck-php

## Usage

Reports will be generated in the `report/` directory.

### Human-readable

`docker run -t --rm -v $(pwd):/project -v $(pwd)/report:/report jeremygarigliet/quack-php quack <path/relative/to/pwd>`

### CI

`docker run -t --rm -v $(pwd):/project -v $(pwd)/report:/report jeremygarigliet/quack-php quack_ci <path/relative/to/pwd>`
