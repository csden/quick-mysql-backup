#!/bin/bash
#
# Perform quick rotating dumps of a MySql database using mysqldump.

rotate() {
    name=$1
    n=$2
    
    n_max=0
    
    if ls ${name}-* &> /dev/null; then
        for i in $(ls ${name}-*); do
            suffix=`echo $i | awk -F '-' '{print $NF}'`
            if [ $suffix -gt $n_max ]; then
                n_max=$suffix
            fi
        done
        
        for i in $(seq ${n_max} -1 1); do
            echo $i;
            if [ $i -gt $n ]; then
                rm -f "${name}-${i}"
            else
                mv "${name}-${i}" "${name}-$(($i+1))"
            fi
        done
    fi
    
    mv $name "${name}-1" &> /dev/null
}

db=$1 # Database name.
of=$2 # Output file path.
nr=$3 # Number of file rotations to keep.

if [ -z $of ]; then
  echo "Usage: backup.sh <database> <output-file> <rotation-limit>"
  exit 1
fi

if [ -f $of ]; then
    rotate $of $nr
fi

# dump the database
mysqldump $db > $of
