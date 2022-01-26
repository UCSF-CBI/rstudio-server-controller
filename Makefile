shellcheck:
	shellcheck -x bin/freeport
	(cd bin; shellcheck -x rsc)


spelling:
	Rscript -e "spelling::spell_check_files('README.md', ignore=readLines('WORDLIST'))"
