podman kill rocket.chat-mongodb
podman kill rocket.chat-app

podman pod create --name rocket.chat -p 127.0.0.1:3000:3000
podman run -dt --rm --pod rocket.chat --name rocket.chat-mongodb mongo:latest --oplogSize 128 --replSet rs0
sleep 2s
podman run -it --rm --pod rocket.chat mongo mongo localhost/rocketchat --eval "rs.initiate({ _id: 'rs0', members: [ { _id: 0, host: 'localhost:27017' } ]})"
#podman run -it --rm --pod rocket.chat --name rocket.chat-app -v $(pwd):/root/code -e METEOR_ALLOW_SUPERUSER=1 --workdir /root/code rocket-builder:latest bash -c "meteor npm install; meteor npm start"
podman run -it --rm --pod rocket.chat --name rocket.chat-app -e PORT=3000 -e MONGO_OPLOG_URL=mongodb://127.0.0.1:27017/local -e ROOT_URL=https://chat.godotengine.org -e MONGO_URL=mongodb://127.0.0.1:27017/rocketchat rocket-chat:latest


read

podman kill rocket.chat-mongodb
podman kill rocket.chat-app


