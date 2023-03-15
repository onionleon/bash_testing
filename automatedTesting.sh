#!/bin/bash
#usage: ./goodPasswordWithChecks.sh [suite-file] [program]

for stem in $(cat $1); do
#checks if the stem that is provided in the suite file has the .expect file with the 
#equivalent name	
  if [ ! -r "$stem.expect" ]; then
    echo "This file doesn't exit" >&2
    exit 5
  elif [ -r "$stem.in" ] && [ -r "$stem.args" ]; then 
# if both the .in file and .args exists it runs the script with the .in and .args files 
# equivalent to the stem file if the output doesn't match the contents of the .expect file 
# the contents of the contents of the .in, .args and the .expect files are printed with 
# the actual output	  
    TEMPFILE=$(mktemp)
    $2 $(cat "$stem.args") < $stem.in >$TEMPFILE
    diff $stem.expect $TEMPFILE >/dev/null
    isdiff=$?
    if [ $isdiff -ne 0 ]; then
      echo "Test failed: $stem"
      echo "Args:"
      echo "$(cat $stem.args)"
      echo "Input:"
      echo "$(cat $stem.in )"
      echo "Expected:"
      echo "$(cat $stem.expect)"
      echo "Actual:"
      echo "$(cat $TEMPFILE)"
    fi
    rm $TEMPFILE
  elif [ -r "$stem.in" ] && [ ! -r "$stem.args" ]; then 
#if there only exists a .in file the provided script is only being run with the .in file
# if the output doesn't match the contents of the .expect file the .in and .expect file 
# is printed out with the actual output
     TEMPFILE=$(mktemp)
    $2 < $stem.in >$TEMPFILE
    diff $stem.expect $TEMPFILE >/dev/null
    isdiff=$?
    if [ $isdiff -ne 0 ]; then 
	echo "Test failed: $stem"
        echo "Input:"
        echo "$(cat $stem.in)" 
        echo "Expected:" 
        echo "$(cat $stem.expect)"
        echo "Actual:"
        echo "$(cat $TEMPFILE)"
    fi
    rm $TEMPFILE
  elif [ ! -r "$stem.in" ] && [ -r "$stem.args" ]; then 
# if there is no provided .in file the script is run with only the .args file if the 
# output is not equal to the contents of the .expect file the contents of the .args file 
# and the .expect file as well as the output is printed out
    TEMPFILE=$(mktemp)
    $2 $(cat "$stem.args") >$TEMPFILE
    diff $stem.expect $TEMPFILE >/dev/null
    isdiff=$?
    if [ $isdiff -ne 0 ]; then 
      echo "Test failed: $stem"
      echo "Args:"
      echo "$(cat $stem.in)"
      echo "Expected:"
      echo "$(cat $stem.args)" 
      echo "Actual:" 
      echo "$(cat $TEMPFILE)"
    fi
    rm $TEMPFILE
  else 
# if there is no provided .in file and no provided .args file the script is run without 
# both and if the output is not equal to the content provided in the .expect files 
# then the output and the .expect files are printed
    TEMPFILE=$(mktemp)
    $2 >$TEMPFILE
    isdiff=$?
    diff $stem.expect $TEMPFILE >/dev/null
    if [ $isdiff -ne 0 ]; then
      echo "Test failed: $stem"
      echo "Expected:"
      echo "$(cat $stem.expect)"
      echo "Actual:"
      echo "$(cat $TEMPFILE)"
    fi
    rm $TEMPFILE
  fi
done    
   
