# Exemplo Docker — aplicação Python

```bash
docker build -t estudo/python-app:1.0.0 .
docker run --rm -d --name python-app -p 8080:8080 estudo/python-app:1.0.0
curl http://localhost:8080/
curl http://localhost:8080/health
docker logs python-app
docker stop python-app
```
