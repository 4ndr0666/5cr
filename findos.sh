# get the shell name to choice the script for detecting OS
  echo $SHELL
  exit;

# for routeros
  :put [/system resource get platform]

# for fish shell
  if set name (uname) = "Linux"
      cat /etc/*release
  else
      uname
  end

# for others
  HISTFILE=;
  SA_OS_TYPE="Linux"
  REAL_OS_NAME=`uname`
  if [ "$REAL_OS_NAME" != "$SA_OS_TYPE" ] ;
  then
  echo `uname`
  else
  DISTRIB_ID=\"`cat /etc/*release`\"
  echo $DISTRIB_ID;
  fi;
  exit;
