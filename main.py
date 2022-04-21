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


def stop_docker() -> None:
    os.system('docker-compose -f docker/docker-compose-full.yml stop')

def print_help() -> None:
    print('Management of the project')
    
    print(
    '''
    USAGE:
        python3.10 main.py [COMMAND]

    COMMANDS:
        --help: Show this message
        --start: Start Docker containers
        --stop: Stop Docker containers
    '''
    )


def main():
    try:
        arg = sys.argv[1]
    except:
        print('insira uma opcao')
    
    if arg == '--start':
        docker_start_options()
    elif arg == '--stop':
        stop_docker()
    else:
        print_help()