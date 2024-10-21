# Oracle Cloud Infrastructure CLI Container

This Docker container, when built, will have the Oracle Cloud Infrastructure CLI application installed on it.

The container was created because some combination of the OCI CLI app, Ubuntu 24.04/24.10, and Python wasn't working.

You will need your own OCI credentials to start provisioning things with this container.

## Security

It is always advisable to read the Dockerfile and other content before adding your credentials to them. Note that the base image is `ubuntu:22.04`, which is considered trustworthy. You can also see from the Dockerfile that the container doesn't send your credentials anywhere it shouldn't. On Linux hosts, you may want to run `shred -uvz config` to destroy this local copy of your access credentials to your Oracle Cloud Infrastructure, if you're sure you've finished with the container for the last time.

## Prerequisits

- docker
- an Oracle Cloud Infrastructure account
- you must copy `./config.example` to `./config` and insert your own details

## Use

You will need a copy of `./config.example`. The file must be called `./config`, and is [documented by Oracle](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliconfigure.htm).

```
cp ./config.example config
```

Now edit `config` to your satisfaction.

```
docker build -t oci-cli-container .
docker run -it oci-cli-container
```

You should now have a shell on the container. Try running:

```
oci --version
```

This will verify that the tool is working. It is [documented in on the Oracle website](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/cliconcepts.htm).

## Clean-up

To get rid of the container when it has served your purpose, follow these instructions. (Maybe ask yourself if you want to save a copy of your bash history first.)

```
docker ps
```

Identify relevant container ID from output.

```
docker kill [container ID]
docker rm [container ID]
```

To clean up the local copy of your secret access credentials securely, after you are done with the container:

```
shred -uvz config
```

