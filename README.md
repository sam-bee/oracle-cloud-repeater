# Oracle Cloud Infrastructure Repeater

A workaround for the OCI `VM.Standard.A1.Flex` 'Out of capacity' error.

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

You can use this project to provision your free virtual private server. You can also keep the container, which comes
with **Terraform** and **OCI CLI**, in case you want to use those for other provisioning-related purposes.

You will need an Oracle Cloud Infrastructure account set up already. It's worth trying to provision your server through
the web interface first.

## Prerequisits

### To provision the free server
- Docker
- An Oracle Cloud Infrastructure account
- if you you must copy `./config.example` to `./config` and insert your own details

### To use OCI CLI
- You will need to copy the config file inside the `resources/` directory: `cp config.example config`. Edit the `config`
  file with the correct data, similarly to the top of your Terraform config, and start the project.

## Use

### Generate necessary Terraform file

Create a copy of the Terraform example file: `./resources/main.tf.example ./resources/main.tf`. There are instructions
within it telling you where in the OCI web interface you will need to get the various settings. The top section is
mostly identity and authentication related. The bottom section describes your instance. You will need to go to
https://cloud.oracle.com/compute/instances/create , configure your desired instance, then select `Save as stack` to
generate the Terraform settings.

A `VM.Standard.A1.Flex` shape with 4 CPU cores and 24GB of RAM is a popular choice - this is within the free tier at
time of writing.

### Start Up Container

```
make setup
make shell
```

You should now have a shell on the container. Try running:

```
oci --version
```

This will verify that the CLI tool is working. It is [documented on the Oracle
website](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/cliconcepts.htm).


### Terraform

Prepare by going to `/app/resources/` and running `terraform init` and `terraform plan`.

Run `terraform apply` once. If you get lucky and it works, you're done.

You may well see `Error: 500-InternalError, Out of host capacity.` however.


### Utility to keep trying Terraform

This is in `/app/repeat-command/repeat-command`. Run it from `/app/resources` with:

```sh
cd /app/resources/
/app/repeat-command/repeat-command --wait=300 --timeout=14400 --command="terraform apply -auto-approve"
```

It should check every 5 minutes for 4 hours, repeatedly checking to see if there are resources available.

If you prefer using the OCI CLI to provision your server, the command would be:

```sh
oci compute instance launch --availability-domain "ad-example" \
    --compartment-id ocid1.compartment.oc1..exampleuniqueID \
    --shape "VM.Standard.A1.Flex" \
    --image-id ocid1.image.oc1..exampleuniqueID \
    --ssh-authorized-keys-file /app/other-files/id_rsa.pub
```

Good luck, and have fun with the free server.

### Clean-up

```
make cleanup
```

To clean up the local copy of your secret access credentials securely, use:

```
shred -uvz [filename]
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
