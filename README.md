# Download image
```shell
docker pull jenkins/jenkins:lts
```

# Deploy Jenkins
```shell
$ docker run -d -v ./jenkins_home:/var/jenkins_home -p 8080:8080 -p 50000:50000 --restart=on-failure --name jenkins jenkins/jenkins:latest
```

# Docker compose
- To start
```shell
$ docker compose -f docker-compose.yaml up -d
```
- To stop
```shell
$ docker compose -f docker-compose.yaml down -v
```
Refer https://www.cloudbees.com/blog/how-to-install-and-run-jenkins-with-docker-compose for more details regarding setup.

# Updating plugins file
Ref: [updating-plugins-file](https://github.com/jenkinsci/docker/blob/master/README.md#updating-plugins-file)

# Backup & Restore Jenkins
## Backup
```shell
$ scripts/backup_restore.sh backup ./jenkins_home ./jenkins_home_backup
```

## Restore
```shell
$ scripts/backup_restore.sh restore ./jenkins_home_backup ./jenkins_home
```
