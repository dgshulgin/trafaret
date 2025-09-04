.PHONY: build
build:
	/opt/myoffice-standard/mox create --delete --source=./src --package=./bin/trafaret.mox
.PHONY: sign
sign:
	/opt/myoffice-standard/mox sign --package="./bin/trafaret.mox" --certificate="" --private-key=""
