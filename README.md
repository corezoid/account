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

## Nginx

Need to add this block to current nGinx config file for single-account domain:

```nginx
location ~ ^/(client|face|webhook) {
	proxy_http_version     1.1;
	proxy_set_header       Connection "";
	proxy_set_header       Host $host;
	proxy_hide_header      x-amz-id-2;
	proxy_hide_header      x-amz-request-id;
	proxy_hide_header      x-amz-meta-server-side-encryption;
	proxy_hide_header      x-amz-server-side-encryption;
	proxy_hide_header      Set-Cookie;
	proxy_ignore_headers   Set-Cookie;
	proxy_intercept_errors on;
	proxy_buffering        off;
	proxy_pass             https://AWS_NLB_WITH_SINGLESPACE_ENDPOINT;
}
```

## Single-account appication

Add block above in `single_account.config` file inside block `{single_account, []}`:

```
{single_space, [
  {disabled, false}
]},
```

# Install


```git clone https://github.com/corezoid/singlespace.git```

```cd singlespace```


Create namespace if need:
```kubectl create namespace sa```

Make changes in `values.yaml` file and run command:
```helm upgrade --install singlespace -n sa -f ./values.yaml .```
