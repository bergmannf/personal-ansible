#!/usr/bin/env sh

SOURCE=""
DESTINATION=""
PASSWORD_FILE=""

function usage() {
    echo "$0 -p <password_file> -s <source_directory> -d <destination_directory>"
}

while getopts ":d:s:p:" o; do
    case "$o" in
        d)
            DESTINATION="$OPTARG"
        ;;
        s)
            SOURCE="$OPTARG"
        ;;
        p)
            PASSWORD_FILE="$OPTARG"
        ;;
        *) usage
           ;;
    esac
done

echo "Backup running with Source: $SOURCE - Destination: $DESTINATION - PW: $PASSWORD_FILE"

if [ -z "$SOURCE" ]; then
    echo "No source directory passed"
    exit 1
fi
if [ -z "$DESTINATION" ]; then
    echo "No destination directory passed"
    exit 1
fi
if [ -z "$PASSWORD_FILE" ]; then
    echo "No password file passed"
    exit 1
fi


restic init --password-file "$PASSWORD_FILE" --repo "$DESTINATION"

restic --repo "$DESTINATION" --password-file "$PASSWORD_FILE" backup "$SOURCE/" --verbose
