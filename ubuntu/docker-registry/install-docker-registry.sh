#refer:https://dev.to/fuksito/how-to-setup-private-docker-registry-for-your-projects-to-save-money-1ed7
#su root
mkdir /root/docker-registry

# Get parameters
. ./env.sh 
cp ./env.sh /root/docker-registry/env.sh

# Create folders to store registry users
cd /root/
mkdir docker-volumes
mkdir docker-volumes/registry/
mkdir docker-volumes/registry/registry
mkdir docker-volumes/registry/auth



cd /root/docker-registry

# Create docker-compose.yml for setup registry
rm ./docker-compose.yml
cat <<EOF | sudo tee ./docker-compose.yml
version: "2.0"
services:
  registry:
    restart: always
    image: 'registry:2'
    ports:
      - "${docker_registry_port}:5000"
    environment:
      REGISTRY_AUTH: htpasswd
      REGISTRY_AUTH_HTPASSWD_PATH: /auth/htpasswd
      REGISTRY_AUTH_HTPASSWD_REALM: Registry Realm
      REGISTRY_STORAGE_DELETE_ENABLED: 'true'
    volumes:
      - /root/docker-volumes/registry/registry:/var/lib/registry
      - /root/docker-volumes/registry/auth:/auth
      - /root/docker-registry/config.yml:/etc/docker/registry/config.yml
EOF

#config for registry
# add validation.disabled:true to fix "invalid URL on layer" error
# bug refer:https://github.com/docker/distribution/issues/2795
rm /root/docker-registry/config.yml
cat <<EOF | sudo tee /root/docker-registry/config.yml
version: 0.1
log:
  fields:
    service: registry
storage:
  cache:
    blobdescriptor: inmemory
  filesystem:
    rootdirectory: /var/lib/registry
http:
  addr: :5000
  headers:
    X-Content-Type-Options: [nosniff]
health:
  storagedriver:
    enabled: true
    interval: 10s
    threshold: 3
validation:
  disabled: true 
EOF

# Create a task to automatically start docker registry on startup
echo "@reboot     root    /root/docker-registry/start.sh" >> /etc/crontab


# Create a startup script for docker registry and it's web UI app
rm /root/docker-registry/start.sh
cat <<EOF | sudo tee /root/docker-registry/start.sh
# run garbage collection
. ./garbage-collect.sh

# stop docker registry
docker stop \$(docker ps | grep registry:2 | awk '{print \$1}')

# stop docker registry frontend
docker stop \$(docker ps | grep registry-frontend:v2 | awk '{print \$1}')

# delete all stopped containers
docker rm \$(docker ps -a -q)

cd /root/docker-registry/



# get environment variables
. ./env.sh

#run backend registry service
docker-compose up -d 
#run frontend Web UI of the registry
sudo docker run \
  --restart=always \
  -d \
  -e ENV_DOCKER_REGISTRY_HOST=\${server_name} \
  -e ENV_DOCKER_REGISTRY_PORT=\${docker_registry_port} \
  -p ${docker_registry_web_prot}:80 \
  konradkleine/docker-registry-frontend:v2

# Docker UI
docker run -d -p 81:80 -e URL=https://repository.imrc.be -e DELETE_IMAGES=true joxit/docker-registry-ui:static
EOF


#Run garbage Collection

rm /root/docker-registry/garbage-collect.sh
cat <<EOF | sudo tee /root/docker-registry/garbage-collect.sh
registry_container_id=\$(docker ps | grep registry:2 | awk '{print \$1}')
docker exec -it -u root \$registry_container_id bin/registry garbage-collect --delete-untagged /etc/docker/registry/config.yml
EOF

#rm -R /root/docker-volumes/registry/registry/docker/registry/v2/repositories/ipm


# Add a docker registry user
docker run --entrypoint htpasswd registry:2 -Bbn $username $passwd > /root/docker-volumes/registry/auth/htpasswd
# Enable Docker registry
cd /root/docker-registry/
. /root/docker-registry/start.sh
