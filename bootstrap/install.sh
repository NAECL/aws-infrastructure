#!/bin/bash -ux

config=/etc/build_custom_config

if [ -f ${config} ]
then
    . ${config}
fi

PATH=/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin

# Connect to remote repos without question
mkdir -p /root/.ssh
chmod 0700 /root/.ssh
echo "StrictHostKeyChecking no" > /root/.ssh/config
rm -f /root/.ssh/known_hosts >/dev/null 2>&1
# ln -sf /dev/null /root/.ssh/known_hosts

# Set default installer, environment, and repositories these can be modified by a tag, or on non AWS instances,
# They can be modified by env variable. USeful for on site images, and testing
#
DEFAULT_ANSIBLE_REPO=${ANSIBLE_REPO:=ansible-public}
DEFAULT_PUPPET_REPO=${PUPPET_REPO:=puppet-public}
DEFAULT_CHEF_REPO=${CHEF_REPO:=chef-public}
DEFAULT_CONFIG_REPO=${CONFIG_REPO:=ssh://git-codecommit.eu-west-1.amazonaws.com/v1/repos/config}
DEFAULT_ENVIRONMENT=${ENVIRONMENT:=production}
DEFAULT_INSTALLER=${INSTALLER:=puppet}
DEFAULT_GIT_URL=${GIT_URL:=https://github.com/NAECL}
DEFAULT_GIT_SUFFIX=${GIT_SUFFIX:=.git}
AWS_INSTALL=${AWS_INSTALL:=true}
REBOOT=${REBOOT:=true}

# lsb_release is installed on Ubuntu by default. Not on other platforms. Do what it takes to install it
yum install -y redhat-lsb >/dev/null 2>&1

if [ ! -x /usr/bin/lsb_release ]
then
    echo "Error: Unable to run lsb_release"
    exit 1
fi

distro=$(lsb_release -i | awk '{print $3}')
release=$(lsb_release -r | awk '{print $2}' | sed 's/\..*//')

# Now interrogate the tags and metadata to find ot about this ami
#
if [ "${AWS_INSTALL}" = "true" ]
then
    if [ "${distro}" == "CentOS" -o "${distro}" == "RedHatEnterpriseServer" ]
    then
        # Install initial needed packages and tools
        #
        yum install -y http://dl.fedoraproject.org/pub/epel/epel-release-latest-${release}.noarch.rpm
        yum install -y awscli
    fi

    if [ "${distro}" == "Ubuntu" ]
    then
        # Install initial needed packages and tools
        #
        apt-get update
        apt-get install awscli -y
    fi

    instance=$(curl http://169.254.169.254/latest/meta-data/instance-id/ 2>/dev/null)
    zone=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone/ 2>/dev/null)
    region=$(echo ${zone} | sed 's/.$//')

    role=$(/usr/bin/aws --region ${region} ec2 describe-instances --instance-id ${instance}  --query 'Reservations[*].Instances[*].[InstanceId,ImageId,Tags[*]]' --output text | awk '/^Role/ {print $2}')

    environment=$(/usr/bin/aws --region ${region} ec2 describe-instances --instance-id ${instance}  --query 'Reservations[*].Instances[*].[InstanceId,ImageId,Tags[*]]' --output text | awk '/^Environment/ {print $2}')

    hostname=$(/usr/bin/aws --region ${region} ec2 describe-instances --instance-id ${instance}  --query 'Reservations[*].Instances[*].[InstanceId,ImageId,Tags[*]]' --output text | awk '/^Name/ {print $2}')

    installer=$(/usr/bin/aws --region ${region} ec2 describe-instances --instance-id ${instance}  --query 'Reservations[*].Instances[*].[InstanceId,ImageId,Tags[*]]' --output text | awk '/^Installer/ {print $2}')

    repository=$(/usr/bin/aws --region ${region} ec2 describe-instances --instance-id ${instance}  --query 'Reservations[*].Instances[*].[InstanceId,ImageId,Tags[*]]' --output text | awk '/^Repository/ {print $2}')

    config_repo=$(/usr/bin/aws --region ${region} ec2 describe-instances --instance-id ${instance}  --query 'Reservations[*].Instances[*].[InstanceId,ImageId,Tags[*]]' --output text | awk '/^Config_Repo/ {print $2}')

    git_url=$(/usr/bin/aws --region ${region} ec2 describe-instances --instance-id ${instance}  --query 'Reservations[*].Instances[*].[InstanceId,ImageId,Tags[*]]' --output text | awk '/^Git_Url/ {print $2}')

    git_suffix=$(/usr/bin/aws --region ${region} ec2 describe-instances --instance-id ${instance}  --query 'Reservations[*].Instances[*].[InstanceId,ImageId,Tags[*]]' --output text | awk '/^Git_Suffix/ {print $2}')

    region_dns=$(/usr/bin/aws --region ${region} ec2 describe-instances --instance-id ${instance}  --query 'Reservations[*].Instances[*].[InstanceId,ImageId,Tags[*]]' --output text | awk '/^Region_DNS/ {print $2}')

    ssh_key_value=$(/usr/bin/aws --region ${region} ec2 describe-instances --instance-id ${instance}  --query 'Reservations[*].Instances[*].[InstanceId,ImageId,Tags[*]]' --output text | awk '/^SSH_Key_Value/ {print $2}')

    ssh_key_id=$(/usr/bin/aws --region ${region} ec2 describe-instances --instance-id ${instance}  --query 'Reservations[*].Instances[*].[InstanceId,ImageId,Tags[*]]' --output text | awk '/^SSH_Key_ID/ {print $2}')

    resource_group=$(/usr/bin/aws --region ${region} ec2 describe-instances --instance-id ${instance}  --query 'Reservations[*].Instances[*].[InstanceId,ImageId,Tags[*]]' --output text | awk '/^Resource_Group/ {print $2}')

    # This bit takes the option of setting up access to a code commit repo. It takes the contents from terraform. Would like to improve
    id_file=/root/.ssh/id_rsa.${ssh_key_id}
    echo -e "${ssh_key_value}" > ${id_file}
    echo -e "User ${ssh_key_id}\nIdentityFile ${id_file}" >> /root/.ssh/config
    chmod 0600 ${id_file}
else
    role=${ROLE:=base}
    hostname=${HOSTNAME:=hostname}
    region_dns=${REGION_DNS:=local.com}
    hostname=$(echo $hostname | sed 's/\..*//')
    environment=""
    installer=""
    repository=""
    resource_group=""
    config_repo=""
    git_url=""
    git_suffix=""
fi

# If installer isn't specified, use default
#
if [ "${installer}" = "" ]
then
    installer=${DEFAULT_INSTALLER}
fi

# If environment isn't specified, use default
#
if [ "${environment}" = "" ]
then
    environment=${DEFAULT_ENVIRONMENT}
fi

# If git_url isn't specified, use default
#
if [ "${git_url}" = "" ]
then
    git_url=${DEFAULT_GIT_URL}
fi

# If git_suffix isn't specified, use default
#
if [ "${git_suffix}" = "" ]
then
    git_suffix=${DEFAULT_GIT_SUFFIX}
fi

# Naff workaround to exporting an empty class
#
if [ "${git_suffix}" = "null" ]
then
    git_suffix=""
fi

case ${installer} in
    puppet)     REPOSITORY=${DEFAULT_PUPPET_REPO}
                ;;
    chef)       REPOSITORY=${DEFAULT_CHEF_REPO}
                ;;
    ansible)    REPOSITORY=${DEFAULT_ANSIBLE_REPO}
                ;;
    *)          echo "Error Invalid Installer Specified"
                exit 1
                ;;
esac

# If repository isn't specified, use default
#
if [ "${repository}" = "" ]
then
    repository=${REPOSITORY}
fi

# If config repository isn't specified, use default
#
if [ "${config_repo}" = "" ]
then
    config_repo=${DEFAULT_CONFIG_REPO}
fi

# Prepare git
git_dir=/etc/git
yum install -y git
mkdir -p ${git_dir}

# Now do installer mechanism specific stuff
#
if [ "${installer}" = "puppet" ]
then

    # Set Hostname and Environment for later use by custom facts
    #
    sed -i '/^HOSTNAME=/d' /etc/build_custom_config >/dev/null 2>&1
    echo "HOSTNAME=${hostname}" >> /etc/build_custom_config
    sed -i '/ENVIRONMENT=/d' /etc/build_custom_config >/dev/null 2>&1
    echo "ENVIRONMENT=${environment}" >> /etc/build_custom_config
    sed -i '/RESOURCE_GROUP=/d' /etc/build_custom_config >/dev/null 2>&1
    echo "RESOURCE_GROUP=${resource_group}" >> /etc/build_custom_config

    if [ "${distro}" == "CentOS" -o "${distro}" == "RedHatEnterpriseServer" ]
    then
        yum install -y https://yum.puppetlabs.com/puppet5/puppet5-release-el-${release}.noarch.rpm
        puppet=/opt/puppetlabs/bin/puppet
        puppet_root=/etc/puppetlabs/puppet
        module_dir=${puppet_root}/code/environments/${environment}/modules
        yum install -y puppet
    fi

    if [ "${distro}" == "AmazonAMI" ]
    then
        puppet=/usr/bin/puppet
        puppet_root=/etc/puppet
        module_dir=${puppet_root}/environments/${environment}/modules
        yum install -y puppet
    fi

    if [ "${distro}" == "Ubuntu" ]
    then
        codename=$(lsb_release -c | awk '{print $2}')
        wget https://apt.puppetlabs.com/puppet5-release-${codename}.deb
        dpkg -i puppet5-release-${codename}.deb
        add-apt-repository ppa:certbot/certbot -y
        apt-get update
        apt-get install puppet-agent -y
        puppet=/opt/puppetlabs/bin/puppet
        puppet_root=/etc/puppetlabs/puppet
        module_dir=${puppet_root}/code/environments/${environment}/modules
    fi

    mkdir -p ${module_dir}

    if [ ! -L ${module_dir} ]
    then
        rm -rf ${module_dir}
        ln -sf ${git_dir}/${repository}/modules ${module_dir}
    fi

    if [ ! -d ${git_dir}/${repository} ]
    then
        cd ${git_dir}
        git clone ${git_url}/${repository}${git_suffix}
        git clone ${config_repo}
        config_repo_name=$(basename ${config_repo} .git)
        if [ ! -f ${git_dir}/config ]
        then
            ln -sf ${git_dir}/${config_repo_name} ${git_dir}/config
        fi
        mkdir -p ${puppet_root}/hieradata
        ln -sf ${git_dir}/config/hieradata/hiera.yaml ${puppet_root}/hiera.yaml
        ln -sf ${git_dir}/config/hieradata/global.yaml ${puppet_root}/hieradata/global.yaml
        ln -sf ${git_dir}/config/hieradata/${region_dns}.yaml ${puppet_root}/hieradata/region.yaml
        ln -sf ${git_dir}/config/hieradata/${environment}.yaml ${puppet_root}/hieradata/environment.yaml
        ln -sf ${git_dir}/config/hieradata/${hostname}.${region_dns}.yaml ${puppet_root}/hieradata/hostname.yaml
    else
        cd ${git_dir}/${repository}
        git pull
    fi

    ${puppet} apply --modulepath=${module_dir} -e "include base" 2>&1
    /usr/local/bin/puppetBuildStandalone -r ${role}
fi

if [ "${installer}" = "chef" ]
then
    rpm -q chefdk >/dev/null 2>&1
    if [ $? -ne 0 ]
    then
        yum install -y http://aws.naecl.co.uk/public/build/dsl/chefdk-3.1.0-1.el7.x86_64.rpm
    fi
    chef_master=${CHEF_MASTER:="192.168.0.203 chef-master"}
    sed -i '/chef-master/d' /etc/hosts
    echo ${chef_master} >> /etc/hosts
fi

if [ "${installer}" = "ansible" ]
then
    if [ ! -d ${git_dir}/${repository} ]
    then
        cd ${git_dir}
        git clone ${git_url}/${repository}${git_suffix}
    else
        cd ${git_dir}/${repository}
        git pull
    fi
fi

if [ "${REBOOT}" = "true" ]
then
    init 6
fi
