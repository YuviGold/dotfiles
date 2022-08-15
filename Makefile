install:
	./install.sh

lint:
	find -name '*.sh' -type f -print -exec \
		docker run --rm -v ${PWD}:/app -w /app koalaman/shellcheck -S error {} +
