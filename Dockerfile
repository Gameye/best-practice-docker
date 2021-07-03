# debian 10 has tini in the repository and it's a well known distro
FROM debian:10

# first install some deps!
# by putting all of this in one run statement in stead of three seperate run statements
# we reduce the number of layers in the docker image and save a few bytes!
# we advice to install tini to run the game, for the rest it's up to you to figure out
# what dependencies your game needs
RUN apt-get update && \
    apt-get --yes install \
        tini \
        ca-certificates \
        curl \
    && \
    apt-get clean

# create a user that will run the server
# it is not recommended and sometimes not even possible to run the server as root
# so we need to create a user that we use to run the game
RUN useradd --create-home --uid 2000 game-user

# copy files and set owner to game-user
# without the chown argument here the files would be copied as root this would
# cause problems when the server does a write.
# also copy files that don't change a lot first, in a seperate command. This could
# dramatically improve the load time of your image as the previous layers, that contain
# files that changes less often, may already have been loaded by a previous version of
# the image
ADD --chown=game-user:game-user ./server /home/game-user/

# when building on windows we need to give the server execute permissions. When building on
# linux this step is often not neccessary
RUN chmod +x /home/game-user/server

# copy the entrypoint last, so the entrypoint will be one of the
# last layers in the docker image. This way only a few small layers have to be loaded
# when loading an image that is similar. This is important when loading images that are
# a different game mode if the game mode is set in the entrypoint
ADD --chown=game-user:game-user ./entrypoint.sh /home/game-user/

# switch to the user that will run the game
USER game-user
# set dir to the users home dir
WORKDIR /home/game-user

# use entrypoint.sh as the entrypoint execute it via tini. Tini will pass signals to
# the server that is executed via the entrypoint so we can gracefully shutdown the
# game server via a signal
ENTRYPOINT ["tini", "/home/game-user/entrypoint.sh"]

# Ports that the server will listen to
EXPOSE 2000/tcp
EXPOSE 3000/udp
