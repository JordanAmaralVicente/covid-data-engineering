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


def hdfs_setup() -> None:
     os.system('./scripts/setup.sh')


def hdfs_repair() -> None:
    os.system('./scripts/repair.sh')


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
        --setup: Configure and upload files to HDFS -> after cluster is running
        --repair: Repair data in HDFS
    '''
    )


def main():
    try:
        arg = sys.argv[1]
    except:
        print_help()
    
    if arg == '--start':
        docker_start_options()
    elif arg == '--stop':
        stop_docker()
    elif arg == '--setup':
        hdfs_setup()
    elif arg == '--repair':
        hdfs_repair()
    else:
        print_help()


if __name__ == '__main__':
    main()
