function git-clone(){
	echo "git clone `git remote -v | awk '{ if ($1 == \"origin\" && $3 == \"(fetch)\") print $2 }'` -b `git branch --show-current`"
}

