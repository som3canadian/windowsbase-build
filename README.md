# windowsbase-build

My base windows docker image. Not the best, but working. Still recommending you build one for yourself that fit your needs.

Image details:

- mcr.microsoft.com/windows:ltsc2019-amd64

## Usage (2 options)

1. Use this repo with this dockerfile and build on your system
2. Create a new dockerfile on your system and set the "FROM"

### Method 1

docker pull ...
docker run -it...

### Method 2

Create new Dockerfile

FROM...
