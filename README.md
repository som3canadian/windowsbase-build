# windowsbase-build

My base windows docker image. Not the best, but working. Still recommending you build one for yourself that fit your needs.

Image details:

- mcr.microsoft.com/windows:ltsc2019-amd64
- git
- nim 1.6.2
- mingw64
- vs_buildtools17
- vs_buildtools19

## Usage (3 options)

1. Pull and run the image
2. Create a new dockerfile on your system and set the "FROM"
3. Git clone and build

### Method 1

```bash
docker pull ghcr.io/som3canadian/windowsbase-build:main
docker run -it ghcr.io/som3canadian/windowsbase-build:main
```

### Method 2

```dockerfile
FROM ghcr.io/som3canadian/windowsbase-build:main

# add your custom commands
RUN dir
RUN whoami
nimble install nimcrypto docopt ptr_math strenc winim
# etc...
```

### Method 3

```bash
git clone https://github.com/som3canadian/windowsbase-build.git
cd windowsbase-build
docker build --platform windows/amd64 --file ./Dockerfile -t .
```
