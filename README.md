# site-docker
Dockerfile for running a [DMOJ site](https://github.com/DMOJ/site).

```bash
docker build --tag dmoj-site .
docker network create -d bridge --subnet 172.25.0.0/16 isolated_nw
docker run --name dmoj-mysql --network=isolated_nw --ip=172.25.3.3 -v /code/docker-data/mysql:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=dmoj -d mysql/mysql-server:5.7
docker run --name=dmoj-site --network=isolated_nw -p 10080:80 -t -i -d dmoj-site /bin/bash
docker exec dmoj-mysql mysql -uroot -pdmoj --execute="CREATE DATABASE dmoj DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;"
docker exec dmoj-mysql mysql -uroot -pdmoj --execute="GRANT ALL PRIVILEGES ON dmoj.* to 'dmoj'@'%' IDENTIFIED BY 'dmoj';"
docker exec dmoj-site python manage.py migrate
docker exec dmoj-site sh /site/loaddata.sh
```

