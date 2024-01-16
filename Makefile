SHELL: bash

check: shellcheck test spelling

assert_bats:
	command -v "bats"
	echo "BATS_SUPPORT_HOME=$${BATS_SUPPORT_HOME:?}"
	echo "BATS_ASSERT_HOME=$${BATS_ASSERT_HOME:?}"

assert_rstudio:
	command -v "rserver"

check-cli: assert_bats assert_rstudio
	(cd tests/; PATH="../bin:$${PATH}" bats *.bats)

shellcheck:
	(cd bin; \
	   shellcheck --shell=bash --external-sources -- incl/*.sh; \
	   shellcheck --external-sources rsc; \
	   shellcheck utils/*; \
	)

spelling:
	Rscript -e "spelling::spell_check_files(c('README.md', 'NEWS.md'), ignore=readLines('WORDLIST'))"

new-version/%:
	@ \
	new_version=$(@F); \
	pattern="\b[[:digit:]][.][[:digit:]]+[.][[:digit:]]+\b"; \
	old_version=$$(grep -E ".*curl.*/$${pattern}[.]tar[.]gz" README.md | sed -E "s|.*curl.*/($${pattern})[.]tar[.]gz|\1|"); \
	echo "Old version=$${old_version}"; \
	echo "New version=$${new_version}"; \
	sed -i -E "s/### Version: $${old_version}-[[:digit:]]+ */### Version: $${new_version}/" bin/rsc; \
	sed -i -E "s/\b$${old_version}\b/$${new_version}/g" README.md; \
	sed -i -E "s/^## Version [(]development version[)] */## Version $${new_version} [$$(date "+%F")]/g" NEWS.md; \
	git diff -u -w

