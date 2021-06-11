## Windows

Modified config and dashboard are in the [windows branch](https://github.com/retzkek/chiamon/tree/windows).

* Install [Docker Desktop](https://www.docker.com/products/docker-desktop)
* Install [Visual Studio Code](https://code.visualstudio.com/)
* Install [git](https://git-scm.com/)
* Install [Windows exporter](https://github.com/prometheus-community/windows_exporter/releases/download/v0.16.0/windows_exporter-0.16.0-386.msi)
* Clone the chiamon repository with VSCode
* Modify `docker-compose.yml`:
    - Change volume paths to point to your home directory.
* Run services. In VSCode with docker extension you can just right-click on `docker-compose.yml` and select "Compose Up"
* Check target status in Prometheus at http://localhost:9090/targets 
* Access Grafana at http://localhost:3000 (admin/admin).
