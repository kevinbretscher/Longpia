#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <docker|singularity_apptainer>"
    exit 1
fi

MODE="$1"

case "$MODE" in

    docker)
        echo "Mode selected: Docker"
        # 👉 Add your docker-related logic here
        echo "Not implemented yet."
        ;;

    singularity)
        echo "Mode selected: Singularity"
        echo "Downloading Singularity containers from Galaxy Depot..."
        #wget https://depot.galaxyproject.org/singularity/medaka:2.1.1--py39h182ef57_0
        #wget https://depot.galaxyproject.org/singularity/porechop:0.2.4--py39h7cff6ad_2

        singularity pull medaka.sif https://depot.galaxyproject.org/singularity/medaka:2.1.1--py39h182ef57_0
        singularity pull porechop.sif https://depot.galaxyproject.org/singularity/porechop:0.2.4--py39h7cff6ad_2

        https://depot.galaxyproject.org/singularity/checkm-genome%3A1.2.4--pyhdfd78af_2
        https://depot.galaxyproject.org/singularity/checkm2%3A1.1.0--pyh7e72e81_1 
        https://depot.galaxyproject.org/singularity/busco%3A6.0.0--pyhdfd78af_1
        docker pull ezlabgva/busco:v6.0.0_cv1 
        https://depot.galaxyproject.org/singularity/inspector%3A1.3.1--hdfd78af_1 
        https://depot.galaxyproject.org/singularity/craq%3A1.10--hdfd78af_0 
        https://depot.galaxyproject.org/singularity/gtdbtk%3A2.5.2--pyh1f0d9b5_0 

        ;;

    apptainer)
        echo "Mode selected: Apptainer"
        echo "Downloading Apptainer containers from Galaxy Depot..."
        #wget https://depot.galaxyproject.org/singularity/medaka:2.1.1--py39h182ef57_0
        #wget https://depot.galaxyproject.org/singularity/porechop:0.2.4--py39h7cff6ad_2
        ;;

    *)
        echo "Invalid option: $MODE"
        echo "Valid modes: docker, singularity, apptainer"
        exit 1
        ;;
esac
