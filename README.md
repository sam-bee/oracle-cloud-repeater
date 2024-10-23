# Oracle Cloud Infrastructure CLI Repeater

The **Oracle Cloud Infrastructure (OCI)** free tier is rather generous at time of writing, if a little oversubscribed. A
4-core, 24GB VPS using ARM processors is available for free, using what OCI call their 'VM.Standard.A1.Flex' shape.

However, messages saying they are 'out of capacity' are common. Some Reddit users have been writing Javascript into
their Chrome console to keep pushing the button every 30 seconds for four hours until a VPS is provisioned.

This project takes a similar 'keep nagging' approach, using a different tech stack:
- Docker
- Ubuntu 22.04 (attempts to use Ubuntu 24.xx with OCI CLI were thwarted by the Python ecosystem)
- Terraform (for supplying the provisioning command)
- Go (for running the provisioning command again and again until it gets what it wants)
- OCI CLI (not used for the initial provisioning, but you may use this later)

You can use this project to provision your free virtual private server. You can also keep the container, which comes with **Terraform** and **OCI CLI**, in case you want to use those for other purposes.

You will need an Oracle Cloud Infrastructure account set up already. It's worth trying to provision your server through
the web interface a couple of times first.

## Security

It is always advisable to read the Dockerfile and other content before adding your credentials to them. Note that the
base image is `ubuntu:22.04`, which is considered trustworthy. You can also see from the Dockerfile that the container
doesn't send your credentials anywhere it shouldn't. On Linux hosts, you may want to run `shred -uvz config` to destroy
this local copy of your API keys, if you're sure you've used the container for the last time.

## Prerequisits


### To provision the free server
- Docker
- An Oracle Cloud Infrastructure account
- if you you must copy `./config.example` to `./config` and insert your own details
### To use OCI CLI
- You will need to copy config.example

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

Here is an example of a command you might want to run:

```
oci compute instance launch --availability-domain "ad-example" \
    --compartment-id ocid1.compartment.oc1..exampleuniqueID \
    --shape "VM.Standard.A1.Flex" \
    --image-id ocid1.image.oc1..exampleuniqueID \
    --ssh-authorized-keys-file /app/other-files/id_rsa.pub
```

Note that this assumes you have already got an SSH key in your `./other-files/` directory. If not, you will need to put
the necessary credentials there and build the container again.
