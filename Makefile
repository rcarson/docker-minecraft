build:
	docker-compose -p minecraft build

run:
	docker-compose -p minecraft run minecraft

clean:
	docker-compose -p minecraft rm minecraft

clean-data:
	docker-compose -p minecraft rm data

clean-images:
	docker rmi `docker images --filter dangling=true -q`
