VERSION = 0.1.0

commit:
	mix test
	mix purity
	mix format
	git add .
	git cz

builddocker: 
	docker build --file dockerfile --tag madclaws/tres-web .
	docker tag madclaws/tres-web madclaws/tres-web:$(VERSION)

pushdockerdev:
	docker push madclaws/tres-web:$(VERSION)
