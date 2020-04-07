#!/bin/ash

base_dir=${PWD}

# Get original ids for mounted volume
orig_uid=$(stat -c "%u" ${base_dir})
orig_gid=$(stat -c "%g" ${base_dir})

reset_rights() {
	chown -R ${orig_uid}:${orig_gid} ${base_dir}
}
trap reset_rights ABRT EXIT QUIT HUP

log_inf() {
  local msg="$1"
  ts=$(date '+%Y-%m-%d %H:%M:%S')
  echo -e "\n[$ts] [INFO] $msg\n"
}

quack(){
  log_inf "PHPstan :"
    phpstan --no-ansi --no-progress analyse ${1} | tee /report/phpstan.log
  log_inf "PHPMD :"
    phpmd ${1} html cleancode,codesize,controversial,design,naming,unusedcode --reportfile /report/pmd.html
    phpmd ${1} text cleancode,codesize,controversial,design,naming,unusedcode | tee /report/phpmd.log
  log_inf "PHPCPD :"
    phpcpd --fuzzy --no-ansi ${1} | tee /report/phpcpd.log
  log_inf "phploc :"
    phploc --no-ansi -n ${1} | tee /report/phploc.log
  log_inf "PHP_CodeSniffer :"
    phpcs -q --standard=MySource,PEAR,PSR1,PSR12,PSR2,Squiz,Zend --report-file=/report/phpcs.log ${1}
  log_inf "PhpMetrics :"
    phpmetrics --report-html=/report/phpmetrics --report-xml=/report/phpmetrics.xml --violations-xml=/report/phpmetrics-violations.xml ${1}
}

quack_ci() {
  phpstan --no-ansi --no-progress --error-format=checkstyle analyse ${1} > /report/phpstan.xml
  phpmd ${1} xml cleancode,codesize,controversial,design,naming,unusedcode --reportfile /report/pmd.xml
  phpcpd -q --fuzzy --no-ansi --log-pmd /report/pmd-cpd.xml ${1}
  phploc -q --no-ansi --log-xml=/report/phploc.xml -n ${1}
  phpcs -q --report=checkstyle --report-file=/report/phpcs.xml --standard=MySource,PEAR,PSR1,PSR12,PSR2,Squiz,Zend ${1}
  phpmetrics --report-html=/report/phpmetrics --report-xml=/report/phpmetrics.xml --violations-xml=/report/phpmetrics-violations.xml ${1}
}

"$@"
