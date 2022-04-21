import sys
import os


def run_docker(docker_file: str) -> None:
    os.system(f'docker-compose -f {docker_file} up -d')


def docker_start_options() -> None:
    print('Choose a docker mode:\nFULL - Run all containers including elastic and kafka\nPARCIAL (default) - Run Hadoop and Jupyter-Spark')

    docker_mode == input(':').upper()

    if docker_mode == 'FULL':
        run_docker('docker/docker-compose-full.yml')
    else:
        run_docker('docker/docker-compose.yml')


def main():
    try:
        arg = sys.argv[1]
    except:
        print('insira uma opcao')
    
    if arg == '--start':
        docker_start_options()