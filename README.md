# Oracle Cloud Infrastructure CLI Container

This Docker container has the Oracle Cloud Infrastructure CLI application installed on it.

The container was created because some combination of the OCI CLI app, Ubuntu 24.04/24.10, and Python wasn't working.

You will need your own OCI credentials to start provisioning things with this container.

The [bonus feature](#bonus-feature-repeating-a-command), documented below, allows you to retry OCI commands until they
succeed. If you are getting an error on OCI saying they are 'Out of capacity' for a shape such as 'VM.Standard.A1.Flex',
for example, this will allow you to resend the command every 5 minutes until it succeeds.

## Security

It is always advisable to read the Dockerfile and other content before adding your credentials to them. Note that the
base image is `ubuntu:22.04`, which is considered trustworthy. You can also see from the Dockerfile that the container
doesn't send your credentials anywhere it shouldn't. On Linux hosts, you may want to run `shred -uvz config` to destroy
this local copy of your access credentials to your Oracle Cloud Infrastructure, if you're sure you've used the container
for the last time.

## Prerequisits

- docker
- an Oracle Cloud Infrastructure account
- you must copy `./config.example` to `./config` and insert your own details

## Use

### Your OCI Configuration

You will need a copy of `./config.example`. The file must be called `./config`, and is [documented by
Oracle](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliconfigure.htm).

```
cp ./config.example config
```

Now edit `config` to your satisfaction.

### Handling Other Files

If you are using Terraform, OCI Resource Manager, or OCI CLI + json files, you will have config files that you want to
put on the containter. Just copy them into `./other-files/` before starting your container, and the Dockerfile provided
will make them available at `/root/other-files/`.

### Start Up Container

```
docker build -t oci-cli-container .
docker run -it oci-cli-container
```

You should now have a shell on the container. Try running:

```
oci --version
```

This will verify that the tool is working. It is [documented on the Oracle
website](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/cliconcepts.htm).

### Clean-up

To get rid of the container when it has served your purpose, follow these instructions. (Maybe consider whether you want
to save a copy of your bash `history` first.)

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

## Bonus Feature: Repeating a Command

Additionally, the container comes with a small Go utility for repeating a command. If you are having problems such as
Oracle Cloud Infrastructure not having the capacity you need, you can continually retry. You will find the Go source
code locally in `./repeat-command/main.go`. The compilation is done in the Dockerfile. You will find the resulting
binary in `/app/repeat-command/repeat-command` on your container.

Remember that any terraform files etc. that you put in `./other-files/` locally will end up at `/app/other-files/` on
the container.

For example, this command retries every 5 minutes. After 4 hours it dies.

```
/app/repeat-command/repeat-command --wait=300 --timeout=14400 --command="command-that-doesnt-exist"
```

You can also kill it with `Ctrl + c`.
