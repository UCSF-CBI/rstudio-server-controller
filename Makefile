shellcheck:
	(cd bin; \
	   shellcheck --shell=bash --external-sources -- incl/*.sh; \
	   shellcheck --external-sources rsc; \
	   shellcheck --external-sources freeport; \
	   shellcheck utils/*; \
	)

spelling:
	Rscript -e "spelling::spell_check_files(c('README.md', 'NEWS.md'), ignore=readLines('WORDLIST'))"
