shellcheck:
	(cd bin; \
	   shellcheck --shell=bash --external-sources -- incl/*.sh; \
	   shellcheck --external-sources rsc; \
	   shellcheck freeport; \
	   shellcheck utils/*; \
	)

spelling:
	Rscript -e "spelling::spell_check_files('README.md', ignore=readLines('WORDLIST'))"
