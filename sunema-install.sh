#!/usr/bin/env bash

# get the os type
os="$OSTYPE"
echo $os

git clone https://github.com/josfam/sunema && cd sunema

# create a .env file for storing envirionment variables
touch .env
content = "TMDB_API_KEY=\"\"\n
OPENWEATHER_MAP_API_KEY=\"\"\n"
echo "$content" > .env

cd front_end

# install node if it does not exist, and install front end dependencies
if which node > /dev/null 2>&1; then
	echo "========== SKIPPING NODE INSTALLATION. You already have it!"
else
	echo "========== NODE NOT FOUND! LET'S INSTALL IT!"
	curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && sudo apt-get install nodejs -y
fi

npm install

# install backend dependencies
cd ..

python3 -m venv venv-sunema
source venv-sunema/bin/activate
pip install -r requirements.txt

# start the backend servers in a seperate terminal depending on the os
if [[ "$os" == "darwin" ]]; then
	# macos
	open -a Terminal "python3 -m back_end.api.v1.app"
else
	# linux
	gnome-terminal -- bash -c "python3 -m back_end.api.v1.app"
fi

# start the frontend server
cd front_end

# start the backend servers in a seperate terminal depending on the os
if [[ "$os" == "darwin" ]]; then
	# macos
	open -a Terminal "npm run dev"
else
	# linux
	gnome-terminal -- bash -c "npm run dev"
fi

# open the default browser in the vite host
# It is assumed that the default vite port (5173) will be used
if [[ "$os" == "darwin" ]]; then
	# macos
	open http://localhost:5173/
else
	# linux
	xdg-open http://localhost:5173/
fi
