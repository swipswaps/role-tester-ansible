ANSIBLES=ansible1.6.1 \
	ansible1.7.2 \
	ansible1.8.4 \
	ansible1.9.4 \
	ansible2.0.0 \

all: test

virtualenvs: $(ANSIBLES)

clean:
	find . -name "*~" -exec rm \{\} \;
	rm -rf fake-role/role-tester

ansible1.6.1:
	test -d $@ || virtualenv $@
	# without --no-use-wheel, module command scripts end up in
	# ansible1.6.1/lib/python2.7/site-packages/
	#    ANOTHER_PATH.../ansible1.6.1/ANSIBLE_LIBRARY/commands/raw
	# ANSIBLE_LIBRARY is required because otherwise the package tries
	# to write to /usr/share
	# (. $@/bin/activate; env ANSIBLE_LIBRARY=../../../../share/ansible \
	#	$@/bin/easy_install ansible==1.6.1)
	env VIRTUAL_ENV="$@" ANSIBLE_LIBRARY=share/ansible \
		./withnopydist.sh $@/bin/pip install --no-use-wheel ansible==1.6.1

ansible1.7.2:
	test -d $@ || virtualenv $@
	# without --no-use-wheel, module command scripts end up in
	# ansible1.6.1/lib/python2.7/site-packages/
	#    ANOTHER_PATH.../ansible1.6.1/ANSIBLE_LIBRARY/commands/raw
	# ANSIBLE_LIBRARY is required because otherwise the package tries
	# to write to /usr/share
	env VIRTUAL_ENV="$@" ANSIBLE_LIBRARY=share/ansible \
		./withnopydist.sh $@/bin/pip install --no-use-wheel ansible==1.7.2

ansible%:
	test -d $@ || virtualenv $@
	env VIRTUAL_ENV="$@" ./withnopydist.sh $@/bin/pip install ansible==$*

vendor/bundle:
	bundle install --path "$@"

test: vendor/bundle virtualenvs
	bundle exec kitchen test all
