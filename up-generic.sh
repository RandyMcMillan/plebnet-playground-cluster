#This is for internal testing only
if [ -z "$1" ]; then
    $1=5
fi
: ${TRIPLET:=x86_64-linux-gnu}
: ${bitcoind=$1}
: ${lnd=$1}
: ${tor=$1}

$(which python3) plebnet_generate.py TRIPLET=$TRIPLET bitcoind=$bitcoind lnd=$lnd tor=$tor

#Remove
docker-compose down

#Create Datafile
mkdir -p volumes

for (( i=0; i<=$bitcoind-1; i++ ))
do
    mkdir -p volumes/bitcoin_datadir_$i
done
for (( i=0; i<=$lnd-1; i++ ))
do
    mkdir -p volumes/lnd_datadir_$i
done
rm -rf   volumes/tor_*dir_*
for (( i=0; i<=$tor-1; i++ ))
do
    mkdir -p volumes/tor_datadir_$i
    mkdir -p volumes/tor_servicesdir_$i
    mkdir -p volumes/tor_torrcdir_$i
done

#REF: https://docs.docker.com/engine/install/linux-postinstall
while ! docker system info > /dev/null 2>&1; do
    echo "Waiting for docker to start..."
    if [[ "$(uname -s)" == "Linux" ]]; then
        systemctl restart docker.service
    fi
    if [[ "$(uname -s)" == "Darwin" ]]; then
        open --background -a /./Applications/Docker.app/Contents/MacOS/Docker
    fi

    sleep 1;

done

ARCH=$(uname -m)
export ARCH
docker-compose build --build-arg TRIPLET=$TRIPLET
docker-compose up --remove-orphans -d

