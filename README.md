# Steps to use

## Prerequisites
- Hadoop 2.2 or later cluster or Sandbox.
- Apache Hive.
- Between 15 minutes and 2 days to generate data (depending on the Scale Factor you choose and available hardware).
- If you plan to generate 1TB or more of data, using Apache Hive 13+ to generate the data is STRONGLY suggested.
- Have ```gcc``` in installed your system path. If your system does not have it, install it using yum or apt-get.

## Clone
```
git clone https://github.com/kcheeeung/hive-testbench.git
```

## New Cluster / Run Everything
Run all the individual steps. If you already have tables for a scale, just run step 3.

**TPC-DS**
```
nohup sh util_lazyrun.sh tpcds SCALE
```
**TPC-H**
```
nohup sh util_lazyrun.sh tpch SCALE
```

# Individual Steps

## 1. Build the benchmark
Build the benchmark you want to use (do all the prerequisites)

**TPC-DS**
```
./tpcds-build.sh
```
**TPC-H**
```
./tpch-build.sh
```

## 2. Generate the tables
Decide how much data you want. SCALE approximately is about # ~GB.

**TPC-DS**
```
nohup sh util_tablegentpcds.sh SCALE
```
**TPC-H**
```
nohup sh util_tablegentpch.sh SCALE
```

## 3. Run all the queries
- `SCALE` **must be the SAME as before or else it can't find the database name!**
- Add or change your desired `settings.sql` file or path
- Run the queries!

**TPC-DS Benchmark**
```
nohup sh util_runtpcds.sh SCALE
```
**TPC-H Benchmark**
```
nohup sh util_runtpch.sh SCALE
```

# Optional: Enable Performance Analysis Tool (PAT)
## 1. Connect Head to Worker Node 
```
sh util_connect.sh YOURPASSWORD
```

## 2. Enable PAT
Go into `util_runtpcds.sh` or `util_runtpch.sh`.
Switch the command by un/commenting. Example below.
```
# ./util_internalRunQuery.sh "$DATABASE" "$CURR_DIR$SETTINGS_PATH" "$CURR_DIR$query_path" "$CURR_DIR$LOG_PATH" "$i" "$CURR_DIR$REPORT_NAME.csv"

./util_internalGetPAT.sh /$CURR_DIR/util_internalRunQuery.sh "$DATABASE" "$CURR_DIR$SETTINGS_PATH" "$CURR_DIR$query_path" "$CURR_DIR$LOG_PATH" "$i" "$CURR_DIR$REPORT_NAME.csv" tpchPAT"$ID"/query"$i"/
```

# Optional: Run Queries using Different Connection 
Go into `util_internalRunQuery.sh`
Switch the command by un/commenting. Example below.
Add the appropriate information (`CLUSTERNAME` and `PASSWORD`).
```
# beeline -u "jdbc:hive2://`hostname`:10001/$INTERNAL_DATABASE;transportMode=http" -i $INTERNAL_SETTINGSPATH -f $INTERNAL_QUERYPATH &>> $INTERNAL_LOG_PATH

beeline -u "jdbc:hive2://CLUSTERNAME.azurehdinsight.net:443/$INTERNAL_DATABASE;ssl=true;transportMode=http;httpPath=/hive2" -n admin -p PASSWORD -i $INTERNAL_SETTINGSPATH -f $INTERNAL_QUERYPATH &>> $INTERNAL_LOG_PATH
```

# Troubleshooting

## Did my X step finish?
Check the `aaa_clock.txt` or `aab_clock.txt` file.
OR
```
ps -ef | grep '\.sh'
```

## Some errors?
Add into the script you're running
```
export DEBUG_SCRIPT=X
```

## Could not find database?
In the `settings.sql` file, add
```
use DATABASENAME;
```

## TPC-H is more stable than TPC-DS
TPC-DS has some problems for large scales (100+). Pending to fix.
