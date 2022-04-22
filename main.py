import sys
import os

ROOT_DIR = os.path.dirname(os.path.abspath(__file__))
DOCKER_PATH = os.path.join('docker')
SCRIPTS_PATH = os.path.join('scripts')

def run_docker(docker_file: str) -> None:
    os.system(f'docker-compose -f {DOCKER_PATH}/{docker_file} up -d')


def docker_start_options() -> None:
    print('Choose a docker mode:\nFULL - Run all containers including elastic and kafka\nPARCIAL (default) - Run Hadoop and Jupyter-Spark')

    docker_mode = input(':').upper()

    if docker_mode == 'FULL':
        run_docker('docker-compose-full.yml')
    else:
        run_docker('docker-compose.yml')


def stop_docker() -> None:
    os.system(f'docker-compose -f {DOCKER_PATH}/docker-compose-full.yml stop')


def build_docker(args: str) -> None:
    os.system(f'docker-compose -f {DOCKER_PATH}/docker-compose-full.yml up -d --build {args}')


def hdfs_setup() -> None:
    os.system(f'{SCRIPTS_PATH}/setup.sh')


def hdfs_repair() -> None:
    os.system(f'{SCRIPTS_PATH}/repair.sh')


def print_help() -> None:
    print('Management of the project')
    
    print(
    '''
    USAGE:
        python3.10 main.py [COMMAND] [OPTIONS]

    COMMANDS:
        --help: Show this message
        --start: Start Docker containers
        --stop: Stop Docker containers
        --setup: Configure and upload files to HDFS -> after cluster is running
        --repair: Repair data in HDFS
        --build: Start the specifieds docker containers

    EXAMPLE:
        python3.10 main.py --build jupyter-spark elasticsearch kibana logstash
    '''
    )


def main():
    try:
        arg = sys.argv[1]
    except:
        print_help()
        exit()
    
    if arg == '--start':
        docker_start_options()
    elif arg == '--stop':
        stop_docker()
    elif arg == '--setup':
        hdfs_setup()
    elif arg == '--repair':
        hdfs_repair()
    elif arg == '--build':
        build_args = ' '.join(sys.argv[2:])
        build_docker(build_args)
    else:
        print_help()


if __name__ == '__main__':
    main()
