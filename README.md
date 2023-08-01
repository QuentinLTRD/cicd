## run FastApi development server locally

`uvicorn --app-dir=. api.main:app --reload`

## build container

`docker build -t pedrojunqueira/mycontainer .`

## run container

`docker run -d -p 80:80 pedrojunqueira/mycontainer`

## push the container to dockerhub

`docker login`

`docker push pedrojunqueira/mycontainer:latest`