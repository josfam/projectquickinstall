#!/usr/bin/env bash

os="$OSTYPE"
echo $os
return

git clone https://github.com/josfam/tictacs-backend && cd tictacs-backend

# install mongodb
if which mongod > /dev/null 2>&1; then
	echo "========== SKIPPING MONGODB INSTALLATION. You already have it!"
else
	if [[ "$os" == "darwin"* ]]; then
		echo "========== INSTALLING MONGODB VIA HOMEBREW"
		brew tap mongodb/brew
		brew install mongodb-community@7.0
	else
		sudo apt-get install -y gnupg
		curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
		sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
		--dearmor \
		&& echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list \
		&& sudo apt-get update \
		&& sudo apt-get install -y mongodb-org \
		&& echo "mongodb-org hold" | sudo dpkg --set-selections \
		&& echo "mongodb-org-database hold" | sudo dpkg --set-selections \
		&& echo "mongodb-org-server hold" | sudo dpkg --set-selections \
		&& echo "mongodb-mongosh hold" | sudo dpkg --set-selections \
		&& echo "mongodb-org-mongos hold" | sudo dpkg --set-selections \
		&& echo "mongodb-org-tools hold" | sudo dpkg --set-selections
	fi
fi

# install node if it does not exist
if which node > /dev/null 2>&1; then
	echo "========== SKIPPING NODE INSTALLATION. You already have it!"
else
echo "========== NODE NOT FOUND! LET'S INSTALL IT!"
	curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && sudo apt-get install nodejs -y
fi

get_random_secret() {
	local len=40
	local collection="A-Za-z0-9!@#$%^&*()=<>?"
	local secret=$(cat /dev/urandom | tr -dc "$collection" | head -c "$len")
	echo "$secret"
}

# add a new .env file to the project.
touch .env
envcontent="SESSION_SECRET=\"$(get_random_secret)\"
DB_HOST=\"127.0.0.1\"
DB_PORT=\"27017\"
DB_NAME=\"tictacs\""
echo "$envcontent" > .env

# install dependencies with npm
echo "========== INSTALLING PROJECT DEPENDENCIES"
sleep 2
npm install

# start mongodb
if [[ "$os" == "darwin"* ]]; then
	# macos
	brew services start mongodb-community
else
	# linux
	systemctl start mongod &
fi

# start the local server in a separate terminal window
if [[ "$os" == "darwin"* ]]; then
	# macos
	open -a Terminal "npm run devstart"
else
	# linux
	gnome-terminal -- bash -c "npm run devstart; exec bash"
fi


# wait for the server to start up
echo "========== STARTING THE SERVER, wait for 5 seconds"
sleep 5

# open the default browser to the correct url
if [[ "$os" == "darwin"* ]]; then
	# macos
	open http://localhost:3000
else
	# linux
	xdg-open http://localhost:3000
fi
