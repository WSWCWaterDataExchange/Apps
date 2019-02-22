# Deploying Shiny apps with Ansible and Docker on Amazon EC2

## 1. Create an Amazon Web Services account and a new EC2 Instance


## 2. Deploying the applications

To deploy the apps using Ansible you need the __key pair__ that you use to connect to the EC2 instance, likely this file is called `WATER.pem`

Cloned this repository to your local machine, run this command: 

`git clone https://github.com/WSWCWaterDataExchange/Apps`

Now that you have the key pair and the cloned project, open a terminal on your local machine and change directory to the __ansible__ folder of the cloned repository. You may want to check the Ansible documentation on the `README.md` file on this folder, to learn about the parameters you can change to customize the deployment: https://github.com/WSWCWaterDataExchange/Apps/tree/master/ansible#ansible-playbooks

When you are done customizing, run this command to deploy:

```
ansible-playbook -i hosts deploy.yml --private-key /<path-to-the-ec2-key>/WATER.pem
```

e. g:

```
ansible-playbook -i hosts deploy.yml --private-key /home/user/my-aws-keys/WATER.pem
```


## Adding new shiny applications

If you want to add more shiny applications on this repository you just need to copy the application folder into the root of this repository and follow the instructions here https://github.com/WSWCWaterDataExchange/Apps/tree/master/ansible#shiny_serverj2

to add its configuration for the nginx webserver. There is an scenario when adding a new shiny application brings new dependencies to the mix, in this case it is necesary to figure out what is the dependency missing and once found, add it to the `dockerfile.j2` template. This process of finding missing dependencies may need a development environment so it won't be covered in full detail in this document. 

## Updating shiny applications

From time to time you may need to update the source code of your shiny applications. It's very important that you check if the new code uses software that was not previously on the docker image dependencies `dockerfile.j2`. 

Inside the shiny applications folder is likely to see a file named `global.R` where the dependencies names are stated, if not then at the beginning of the `server.R` file. What you need to do is to make sure that all the library names required by your applications are also on the `dockerfile.j2` file.

e. g: 

Suppose your shiny application has the following list of required libraries on it's code: 

```
library(ggplot2)
library(XML)
library(RColorBrewer)
library(RCurl)
library(plotly)
```

then you must make sure that your `dockerfile.j2` looks like this: 

```
FROM rocker/shiny:latest
RUN apt update && apt install -y libxml2-dev libssl-dev
RUN install.r ggplot2 XML RCurl plotrix plotly
EXPOSE 3838
WORKDIR /srv/shiny-server
```

it's not an obvious fact to notice, but the libray `plotly` also requires a system dependency to be installed, that's why `libssl-dev` is listed on the system packages dependencies list. So the recommendation is to make a little research about the new dependencies to make sure you add all the kind of dependencies you need. 

If you update the shiny apps source, then deploy and the result is that the apps are no longer working, here are some things you can try. First login into the container with the command `docker exec -it shiny bash` then run `cat /var/log/shiny-server/*`. You will see a lot of output which will hopefully provide  insights about packages that were not correctly installed, most likely because of unmet dependencies.

Then you can try to install those packages manually with the following command 

```
# if it's a system library
# system library name's are not always easy to figure out
# so you may need to research a bit on google
apt install <library-name>

# if it's an R package
install.r <package-name>

# if it's a github package
installGithub.r <github-user/repository-name>
```

After trying manual installation and checking that dependencies are met, exit the container with `ctrl + d` and then try restarting the shiny and nginx containers

```
docker restart shiny

docker restart nginx
```


## How to uninstall the applications

If you want to uninstall the shiny applications run the following commands from the EC2 instance, to remove the nginx virtualhost

```
# It is assumed that the 'clone_location' variable is set to "/home/ubuntu/env"
# if not, you need to change the code below to reflect its actual value
sudo rm -f /home/ubuntu/env/conf.d/shiny.conf
```

and then to remove the container

```
# Same as above, if you changed the 'shiny_container' variable value then you have
# to reflect the changes in the code below
sudo docker rm -f shiny
```

lastly restart the nginx container

```
sudo docker restart nginx
```
