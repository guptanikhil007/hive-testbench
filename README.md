# Steps to use

## Prerequisites
- Hadoop 2.2 or later cluster or Sandbox.
- Apache Hive.
- Between 15 minutes and 2 days to generate data (depending on the Scale Factor you choose and available hardware).
- If you plan to generate 1TB or more of data, using Apache Hive 13+ to generate the data is STRONGLY suggested.
- Have ```gcc``` in installed your system path. If your system does not have it, install it using yum or apt-get.

## Build the benchmark
```
git clone https://github.com/kcheeeung/hive-testbench.git
```
Build the benchmark you want to use (do all the prerequisites)

**TPC-DS**
```
./tpcds-build.sh
```
**TPC-H**
```
./tpch-build.sh
```

## Generate the tables
Decide how much data you want. SCALE approximately is about # ~GB.
- Run the table orc gen (might take a while)
- Come back later. `nohup` allows you to close the ssh session

**TPC-DS**
```
nohup sh util_tablegentpcds.sh SCALE
```
**TPC-H**
```
nohup sh util_tablegentpch.sh SCALE
```

## Run all the queries
- `SCALE` **must be the SAME as before or else it can't find the database name!**
- Add or change your desired `settings.sql` file or path
- Run the queries!
- **If you expect it to take long, add:**  `nohup`
- Come back later.

**TPC-DS Benchmark**
```
nohup sh util_runtpcds.sh SCALE
```
**TPC-H Benchmark**
```
nohup sh util_runtpch.sh SCALE
```
