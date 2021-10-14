# pac-demo
* This is a pipeline as code demo, a best practice to organize your project.
* It allows you to use the same way to run your project anywhere, such as in the pipeline, or locally.
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

### You also can run it in gitlab ci or github ci or anywhere with pipeline as code
* Just need you update the gitlab-ci.yml or .github/workflows/makefile.yml a bit
