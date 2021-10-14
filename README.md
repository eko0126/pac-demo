# pac-demo
* This is a pipeline as code demo, a best practice to organize your project.
* It allows you to use the same way to run your project anywhere, such as in the pipeline, or locally.
* It is very suitable for you to migrate your project to any pipeline tool, and you only need to simply configure your ci file.
### Run
```
make run
```

### Test
```
curl http://127.0.0.1:8080/hello/
#Response: "Hello World!"
```
### Deploy to k8s
* You need to prepare your k8s and kubeconfig.
```
make deploy
```
### Versioning your database schema
```
make flyway
```
### You also can run it in gitlab ci or github ci or anywhere with pipeline as code
* Just need you update the gitlab-ci.yml or .github/workflows/makefile.yml a bit
