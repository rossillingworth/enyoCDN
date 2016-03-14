
help:           ## Show this help. First CMD as it is then the default
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

############################################################################
# Why use this Makefile?
# Because you get help, a list of CMDs and auto-complete (TAB)
#
# Add your own cmd line tools
# Especially the ones you have to look up every time you use them
############################################################################


## ENYOjs CDN builder, create a clean install to deply as a cdn
## ======================================================================

###############################
# VARIABLES
###############################
# generated Project name
artifactId=enyo-cnd

###############################
# GAE application details
appId:=enyo-cdn-bizpay
appVersion:=2-5-1

###############################
# versions
gaeVersion:=1.9.32

###############################################################
###############################################################
###############################################################

clean: ## remove all artefacts
	git submodule deinit -f bootplate
	rm -rf bootplate
	rm -rf $(artifactId)


install: ## install NODE & NPM
	curl http://npmjs.org/install.sh | sh


appEngineInit: ## initialise appengine project from an architype
	mvn archetype:generate \
	-Dapplication-id=$(appId) \
	-Dappengine-version=$(gaeVersion) \
	-DarchetypeGroupId=com.google.appengine.archetypes \
	-DarchetypeArtifactId=appengine-skeleton-archetype \
	-DarchetypeVersion=RELEASE \
	-DgroupId=com.techmale \
	-DartifactId=$(artifactId) \
	-Dversion=$(appVersion)  \
	-DinteractiveMode=false \
	&& \
	sed -i -r 's/<app.version>(1)<\/app.version>/<app.version>$(appVersion)<\/app.version>/' $(artifactId)/pom.xml \
	&& echo "pom.xml - application version updated: $(appId)"


enyoInit: ## download allof enyu
	#git submodule add https://github.com/enyojs/bootplate
	git submodule update --init --recursive


enyoModify: ## modify enyo for CDN purposes
	echo "{}" > bootplate/source/app.js
	cp -R demos/* bootplate/
	cd bootplate; node enyo/tools/deploy.js
	#cp -R bootplate/enyo app/enyo
	#cp -R bootplate/deploy app/deploy

enyoPublish:
	cp -R bootplate/deploy/bootplate/*  $(artifactId)/src/main/webapp/
	cp -R bootplate/enyo                $(artifactId)/src/main/webapp/
	cp -R bootplate/lib                 $(artifactId)/src/main/webapp/
	cp -R bootplate/source              $(artifactId)/src/main/webapp/
	cp -R demos/debug.html              $(artifactId)/src/main/webapp/


run:
	cd ${artifactId} \
	&& mvn clean compile package appengine:devserver


tests:
	http-server tests/


all: clean appEngineInit enyoInit enyoModify enyoPublish ## Download, build install, run

deploy:
	cd ${artifactId} \
	&& mvn appengine:update
