#!/bin/bash

sudo rm -fr volumes/elasticsearch/certs/* volumes/elasticsearch/certs/.configured volumes/elasticsearch/data/*
docker run --rm -it \
            -v ./volumes/elasticsearch/certs/:/usr/share/elasticsearch/config/certs \
            -v ./volumes/elasticsearch/instances.yml:/usr/share/elasticsearch/config/instances.yml \
            elasticsearch:8.7.1 \
            bash -c '
              ./bin/elasticsearch-certutil ca --silent --pem -out config/certs/ca.zip;
              unzip config/certs/ca.zip -d config/certs;
              openssl x509 -in config/certs/ca/ca.crt -out config/certs/ca/ca.pem;
              bin/elasticsearch-certutil cert --silent --pem -out config/certs/certs.zip --in config/instances.yml --ca-cert config/certs/ca/ca.crt --ca-key config/certs/ca/ca.key;
              unzip config/certs/certs.zip -d config/certs;
            '

docker-compose up -d

docker exec -it elasticsearch1 bash -c '
              curl -X POST --cacert config/certs/ca/ca.crt -u "elastic:asdfasdfasdfasdfasdfasdf0" -H "Content-Type: application/json" \
                    -d "{\"password\":\"asdfasdfasdfasdfasdfasdf1\"}" \
                    https://localhost:9200/_security/user/kibana_system/_password;
              curl -X POST --cacert config/certs/ca/ca.crt -u "elastic:asdfasdfasdfasdfasdfasdf0" -H "Content-Type: application/json" \
                    -d "{\"email\":\"siggouroglou@gmail.com\", \"password\":\"asdfasdfasdfasdfasdfasdf2\", \"roles\" : [ \"superuser\" ]}" \
                    https://localhost:9200/_security/user/kibana_me;
            '

docker restart kibana && docker container logs -f kibana
