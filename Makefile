compose-setup: compose-build compose-install
compose:
	docker-compose up

gcloud-builds-submit:
	gcloud builds submit --config cloudbuild.yaml .

compose-test:
	docker-compose run exercises make test

compose-lint-descriptions:
	docker-compose run exercises make lint-descriptions

compose-schema-validate:
	docker-compose run exercises make schema-validate

compose-check: compose-schema-validate compose-lint compose-test

compose-install:
	docker-compose run exercises npm install

compose-bash:
	docker-compose run exercises bash

compose-build:
	docker-compose build

build:
	docker-compose build

SUBDIRS := $(wildcard modules/**/*/.)

lint-descriptions:
	yamllint modules

lint-code:
	java -jar /opt/checkstyle.jar modules

compile:
	@(for i in $$(find . -type f -name Main.java); do javac $$(dirname $$i)/*.java ; done)

clean:
	@$$(find . -type f -name *.class -delete)

test:
	@(for i in $$(find modules/** -type f -name Makefile); do make test -C $$(dirname $$i) || exit 1; done)

schema-validate: $(SUBDIRS)
$(SUBDIRS):
	yq . $@/description.ru.yml > /tmp/current-description.json && ajv -s /exercises-java/schema.json -d /tmp/current-description.json
	yq . $@/description.en.yml > /tmp/current-description.json && ajv -s /exercises-java/schema.json -d /tmp/current-description.json || true

.PHONY: all test $(SUBDIRS)
