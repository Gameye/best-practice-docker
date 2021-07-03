# Exit immediately if a command exits with a non-zero status.
set -e

# run some scripts here, maybe curl an endpoint or do whatever you need before starting
# the game session
echo session setup

# Setting +e will continue when there is an error (exit code not equal to zero) This
# could be useful, for instance if you want peform some actions after running the game
# like uploading some data
set +e

# The game server is started via the timeout command. So the game server will be terminated
# when it is running for a set period of time. Also various arguments that do not change like
# ports are set here.
# The game mode is also set here, every game mode should be a different image
timeout 1h \
    /home/game-user/server \
    --port1=2000 \
    --port2=3000 \
    --mode=battle_royale \
    "$@"

# you could run teardown scripts here, for instance uploading some files
echo session teardown
