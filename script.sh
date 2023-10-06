#!/bin/bash

# Variables
SOURCE_DB_HOST="a.b.ap-south-1.rds.amazonaws.com"
TARGET_DB_HOST="g.c.ap-south-1.rds.amazonaws.com"
DB_PORT="5432"
DB_NAME="gm”
DB_USER=“user”
SSL_OPTIONS="sslmode=verify-full&sslrootcert=rds-ca-2019-root.pem"
DUMP_FILE="/tmp/gm_backup.dump"

# Generate authentication token for RDS
export PGPASSWORD="$(aws rds generate-db-auth-token --hostname $SOURCE_DB_HOST --port $DB_PORT --region ap-south-1 --username $DB_USER)"

# Dump data from the source database using the custom format
pg_dump -h $SOURCE_DB_HOST -p $DB_PORT -U $DB_USER -F c -b -v -f $DUMP_FILE "postgresql://$DB_USER@$SOURCE_DB_HOST:$DB_PORT/$DB_NAME?$SSL_OPTIONS"

# Generate authentication token for the target RDS
export PGPASSWORD="$(aws rds generate-db-auth-token --hostname $TARGET_DB_HOST --port $DB_PORT --region ap-south-1 --username $DB_USER)"

# Restore data to the target database using the provided pg_restore command
pg_restore --no-owner -h $TARGET_DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -v --dbname="postgresql://$DB_USER@$TARGET_DB_HOST:$DB_PORT/$DB_NAME?$SSL_OPTIONS" $DUMP_FILE

# Clean up
rm $DUMP_FILE
