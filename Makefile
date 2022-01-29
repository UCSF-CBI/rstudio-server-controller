shellcheck:
	shellcheck --shell=bash -- bin/incl/*.sh
	(cd bin; shellcheck --external-sources rsc)
	shellcheck bin/freeport
	shellcheck bin/utils/*

spelling:
	Rscript -e "spelling::spell_check_files('README.md', ignore=readLines('WORDLIST'))"
