# ubuntu_setup

```
chmod +x ./initial_setup.bash
sudo ./initial_setup.bash
```

## setup dev-env docker container

For (annoying) cases when I need to work on a non-ubuntu / debian
machine, this container provides me an ubuntu env. To setup:

```
chmod +x ./run-image-build.bash
./run-image-build.bash
```

after image is available I can mount local dirs and work in my typical
ubuntu dev env:

```
# mount current dir into /workspace:
docker run --rm -it \
    -v "$(pwd)":/workspace \
    dev-env
```
