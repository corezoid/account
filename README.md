# Pre-install

## Database: 
For correct database migration application need to be owner of `accounts` database.
Use next sql script for change owner:

```sql
ALTER DATABASE accounts OWNER TO application_user ;
```

where `application_user` is a current user for `single-account` application

Also need change owner for all `table`, `sequences` and `views` in `accounts` database to `application_user`.

Here an example how to do this:

```bash
for tbl in `psql -h single_account_database_host -p 5432 -qAt -c "select tablename from pg_tables where schemaname = 'public';" accounts` ; do  psql -h single_account_database_host -p 5432 -c "alter table \"$tbl\" owner to application_user" accounts ; done

for tbl in `psql -h single_account_database_host -p 5432 -qAt -c "select sequence_name from information_schema.sequences where sequence_schema = 'public';" accounts` ; do  psql -h single_account_database_host -p 5432 -c "alter sequence \"$tbl\" owner to application_user" accounts ; done

for tbl in `psql -h single_account_database_host -p 5432 -qAt -c "select table_name from information_schema.views where table_schema = 'public';" accounts` ; do  psql -h single_account_database_host -p 5432 -c "alter view \"$tbl\" owner to application_user" accounts ; done
```

# Install


```git clone https://github.com/corezoid/account.git```

```cd account```


Create namespace if need:
```kubectl create namespace account```

Make changes in `values.yaml` file and run command:
```helm upgrade --install account -n account -f ./values.yaml .```
