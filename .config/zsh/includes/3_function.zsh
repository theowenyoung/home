#################
### Functions ###
#################


# grep

gr(){
  
  grep -r --text --exclude-dir={node_modules,.git} $1 .
  
}


# urlencode
encode()
{
    local args="$@"
    jq -nr --arg v "$args" '$v|@uri';
}

hex2rgb(){
value="$1";

if [[ "$value" = \#* ]] ; then
  value=${value:1};
fi
hexinput=`echo $value | tr '[:lower:]' '[:upper:]'`  # uppercase-ing
a=`echo $hexinput | cut -c-2`
b=`echo $hexinput | cut -c3-4`
c=`echo $hexinput | cut -c5-6`

r=`echo "ibase=16; $a" | bc`
g=`echo "ibase=16; $b" | bc`
b=`echo "ibase=16; $c" | bc`

echo $r,$g,$b
}

alias decode='python3 -c "import sys, urllib.parse as ul; print(ul.unquote_plus(sys.argv[1]))"'
# create with vim

c() {
   fzf_path=$(fd --type directory | fzf)
   if [ -z "$fzf_path" ]
   then
    return 0
   fi
   file_path=$fzf_path/$1
   parentdir="$(dirname "$file_path")"
   if [ ! -d $parentdir ]
   then
     mkdir -p $parentdir
   fi
   $EDITOR $file_path
}

o() {
   fzf_path=$(fzf)
   if [ -z "$fzf_path" ]
   then
    return 0
   fi
   $EDITOR $fzf_path
}

ct() {
   fzf_path=$(fzf)
   if [ -z "$fzf_path" ]
   then
    return 0
   fi
   cat $fzf_path
}
# chmod file_path

ch() {
    if [ -z "$1" ]
    then
        return 0
    fi
    chmod $1 $(fzf)
}

# run Executed
run() {
        fzf_path=$(fzf)
        if [[ -x "$fzf_path" ]]
        then
        echo "run" $fzf_path
        $fzf_path $1
        else
        echo "File '$file' is not executable or found"
fi
    }


# dns query

di(){
  dig $1 @192.168.50.2 -p 6053
}


localip() {
  local ip=$(ipconfig getifaddr en0)
  echo $ip | tr -d '\n' | pbcopy
  echo $ip
}
realip() {
  curl https://myip.ipip.net
}
publicip() {
  curl icanhazip.com
}
