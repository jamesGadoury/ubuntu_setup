# ubuntu_setup

```
chmod +x ./initial-setup
sudo ./initial-setup
```

## setup dev-env docker container

For (annoying) cases when I need to work on a non-ubuntu / debian
machine, this container provides me an ubuntu env. To setup:

```
chmod +x ./run-image-build
./run-image-build
```

after image is available I can mount local dirs and work in my typical
ubuntu dev env:

```
# mount current dir into /workspace:
docker run --hostname dev-env --rm -it \
    -v "$(pwd)":/workspace \
    dev-env
```
