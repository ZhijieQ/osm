all:
	docker build -t harbor.zhijie.win/services/map-nginx:v1 .
	docker push harbor.zhijie.win/services/map-nginx:v1