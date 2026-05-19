# OpenCode Docker Image
FROM alpine:3.22.4

RUN adduser -D -u 1000 picode


RUN apk add bash curl libstdc++ gcompat git npm vim rust cargo php go openjdk17 gradle android-tools

RUN apk add composer

RUN curl -fsSL https://pi.dev/install.sh | sh

RUN pi install git:github.com/badlogic/pi-skills

USER picode

CMD ["/picode/entrypoint.bash"]
