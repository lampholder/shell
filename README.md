# setup.sh
Bash script to set up a fresh account to be useable, *INCLUDING CHANGES TO YOUR LOCALE*.

~~~~
curl https://raw.githubusercontent.com/lampholder/terminal/master/setup.sh | sudo bash

or

wget -qO- https://raw.githubusercontent.com/lampholder/terminal/master/setup.sh | sudo bash
~~~~

Or, if you'd like it to hamfistedly overwrite whatever .vimrc etc you already have in place:

~~~~
curl https://raw.githubusercontent.com/lampholder/terminal/master/setup.sh | sudo bash -s brutal

or

wget -qO- https://raw.githubusercontent.com/lampholder/terminal/master/setup.sh | sudo bash -s brutal
~~~~
