#!/bin/bash
# period.sh
# Copyright 2002 Stefano Falsetto <falsetto@gnu.org>
# Copyright 2008 David Egan Evans <sinuhe@gnu.org>
#
# This program is free software.  You can redistribute it, or modify it,
# or both, under the terms of the GNU General Public License version 3
# (or any later version) as published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses>.
#

STATDIR="tmp"
DEBUG=1

E_BAD_PERIOD=100
E_INTERNAL=101
E_BAD_RANGE=102
E_BAD_TIME=103
E_BAD_DAY=104
E_BAD_OR=105


debecho () {
  if [ ! -z "$DEBUG" ]; then
    echo "$1" >&2
  fi
}

fill_timevar () {
  local string_date=$(LANG=en date -d "$1" "+%s %m %d %Y %H %M %a %b %A %B"|\
                      tr A-Z a-z)

  set -- $string_date
  stamp_now=$1
  today=$3
  date_now="$2/$3/$4 $5:$6"
  now_hour=$5
  now_min=$6
  name_today=$7
  name_month=$8
  long_name_today=$9
  long_name_month=${10}
  ldom=$(cal -1|tail -2|head -n 1|rev|cut -d' ' -f1|rev)
}

update_stamp() {
    echo "stamp:$stamp_now"  >$STATDIR/.$log.ts
    echo "date:$date_now"   >>$STATDIR/.$log.ts
}

check_mwd () {
  local p=$(echo $token|cut -d"$1" -f1)
  local date_file=$(cat $STATDIR/.$log.ts 2>/dev/null|grep "^date:"|\
                    cut -d':' -f2-)
  # For further expansion
  local stamp_file=$(cat $STATDIR/.$log.ts 2>/dev/null|grep "^stamp:"|\
                     cut -d':' -f2)

  if [ $p -lt 1 ]; then
    echo "$p is not a valid period!"
    USCITA=$E_BAD_PERIOD
    exit $USCITA
  fi

  case $1 in
    w) offset="weeks" ;;
    M) offset="months" ;;
    d) offset="days" ;;
    *) echo "Internal Error!"
       USCITA=$E_INTERNAL
       exit $USCITA
       ;;
  esac
  
  # First time a log is handled must be rotated anyway
  if [ -z "$stamp_file" ]; then
    stamp_file=$(date -d "$date_now $p $offset ago" "+%s")
    date_file=$(date -d "$date_now $p $offset ago" "+%m/%d/%Y %H:%M")
    update_stamp
  fi

  local check_p=$(date --date "$date_file $p $offset" "+%s")
  if [ -z "$NOT" ]; then
    crit="$crit && [ $stamp_now -ge $check_p ]"
  else
    crit="$crit && [ $stamp_now -lt $check_p ]"
  fi
}

checkitem () {
  if [ $(expr " $1 " : ".* $2 .*") -eq 0 ]; then
    echo "Error in bound definition!"
    USCITA=$E_BAD_RANGE
    exit $USCITA
  fi
}

parse_period () {
  local exit_t=
  local OLDIFS="$IFS"
  local list_elem_lday="monday tuesday wednesday thursday friday \
                        saturday sunday"
  local list_elem_lmonth="january february march april may june july august \
                          september october november december"
  local list_elem_sday="mon tue wed thu fri sat sun"
  local list_elem_smonth="jan feb mar apr may jun jul aug sep oct nov dec"

  local crit=
  local pieces="$1"

  while [ 0 ]; do
    local IFS=","
    local len_opt=0
    for opt in $pieces; do
      [ -z "$opt" -o "$opt" = "," ] && continue 
      len_opt=$[ len_opt + ${#opt}  + 1 ] # +1 per lo spazio tra gli opt
      local ltoken=0
      local token=
      local rest=
      local first=
      local NOT=
      opt=$(echo $opt|tr -s ' ')
      [ "${opt:0:1}" = " " ] && opt=${opt:1}
      IFS="$OLDIFS"
      for token in $opt; do
        debecho "Here token=$token"
        ltoken=$[ ltoken + ${#token} + 1 ] # +1 per lo spazio tra i tokens
        rest=${opt:ltoken}
        if [ "${token:0:1}" = '!' ]; then
          debecho "Operator NOT"
          NOT='!'
          token=${token:1}
          #rest=${opt:ltoken+1}
        fi
        case "$token" in
          *+*)
              debecho "Expanding inline OR operator"
              op=$(echo "$token"|cut -d'+' -f1)
              allop=${token//+/ }
              if [ -z "$op" ]; then
                echo "Error in OR definition"
                USCITA=$E_BAD_OR
                exit $USCITA
              fi
              case "$op" in
                monday|tuesday|wednesday|thursday|friday|\
                saturday|sunday)
                  local list_elem=$list_elem_lday
                  ;;
                january|february|march|april|may|june|july|\
                august|september|october|november|december)
                  local list_elem=$list_elem_lmonth
                  ;;
                mon|tue|wed|thu|fri|sat|sun)
                  local list_elem=$list_elem_sday
                  ;;
                jan|feb|mar|apr|may|jun|jul|aug|sep|oct|\
                nov|dec)
                  local list_elem=$list_elem_smonth
                  ;;
                *)
                  echo "Error in inline OR definition!"
                  USCITA=$E_BAD_OR
                  exit $USCITA
                  ;;
              esac
              for lop in $allop; do
                checkitem "$list_elem" "$lop"
                if [ -z "$NOT" ]; then
                  exit_t="$exit_t, $first $lop $rest"
                else
                  exit_t="$exit_t $NOT$lop"
                fi
              done
              [ ! -z "$NOT" ] && exit_t="$first $exit_t $rest"
              ;; # end case on *+*
          *-*) 
              debecho "Expanding range: $token"
              case $token in
                *monday*|*tuesday*|*wednesday*|*thursday*|*friday*|\
                *saturday*|*sunday*)
                  local default_begin="monday"
                  local default_end="sunday"
                  local list_elem=$list_elem_lday
                  ;;
                *january*|*february*|*march*|*april*|*may*|*june*|*july*|\
                *august*|*september*|*october*|*november*|*december*)
                  local default_begin="january"
                  local default_end="december"
                  local list_elem=$list_elem_lmonth
                  ;;
                *mon*|*tue*|*wed*|*thu*|*fri*|*sat*|*sun*)
                  local default_begin="mon"
                  local default_end="sun"
                  local list_elem=$list_elem_sday
                  ;;
                *jan*|*feb*|*mar*|*apr*|*may*|*jun*|*jul*|*aug*|*sep*|*oct*|\
                *nov*|*dec*)
                  local default_begin="jan"
                  local default_end="dec"
                  local list_elem=$list_elem_smonth
                  ;;
                *)
                  echo "Error in range definition!"
                  USCITA=$E_BAD_RANGE
                  exit $USCITA
                  ;;
              esac
              begin_t=$(echo "$token"|cut -d'-' -f1)
              end_t=$(echo "$token"|cut -d'-' -f2)
              # Se è un range tipo -xxx
              if [ -z "$begin_t" ]; then
                local begin_t="$default_begin"
              fi
              # Se è un range tipo xxx-
              if [ -z "$end_t" ]; then
                local end_t="$default_end"
              else
                case "$end_t" in
                  monday|tuesday|wednesday|thursday|friday|saturday|sunday)
                       checkitem "$list_elem_lday" "$begin_t"
                       ;;
                  january|february|march|april|may|june|july|august|\
                  september|october|november|december)
                       checkitem "$list_elem_lmonth" "$begin_t"
                       ;;
                  mon|tue|wed|thu|fri|sat|sun)
                       checkitem "$list_elem_sday" "$begin_t"
                       ;;
                  jan|feb|mar|apr|may|jun|jul|aug|sep|oct|\
                  nov|dec)
                       checkitem "$list_elem_smonth" "$begin_t"
                       ;;
                  *)
                       echo "Error on end range!"
                       USCITA=$E_BAD_RANGE
                       exit $USCITA
                       ;;
                esac
              fi
              # Expanding range xxx-yyy
              local append=
              local exit_t=
              for i in $list_elem; do
                [ $i = "$begin_t" ] && append=1
                if [ ! -z "$append" ]; then
                  if [ -z "$NOT" ]; then
                    exit_t="$exit_t, $first $i $rest"
                  else
                    exit_t="$exit_t $NOT$i"
                  fi
                fi
                [ $i = "$end_t" ] && append=
              done
              [ ! -z "$NOT" ] && exit_t="$first $exit_t $rest"
              ;;
          esac # End case on *-*
  
          if [ ! -z "$exit_t" ]; then
            debecho "using len_opt=$len_opt in pieces=$pieces"
            while [ "${pieces:$len_opt:1}" = ' ' ]; do
              len_opt=$[ len_opt - 1 ]
            done
            pieces="$exit_t ${pieces:$len_opt}"
            dont_exit=1
            break 2
          fi

          # vedo se c'è un - o un + in opt ed è prima di ltoken
          if [ $(expr "$opt" : ".*-.*") -gt $ltoken ] || \
             [ $(expr "$opt" : ".*+.*") -gt $ltoken ]; then
            debecho "Non yet filling criteria. Waiting for following iteration"
          else
            debecho "checking token=$token"
            case $token in
            # Add HHh and MMm ???
              0)
                  debecho "--> Always"
                  crit="$crit && [ 1 ]"
                  ;;
              [[:digit:]][[:digit:]]:[[:digit:]][[:digit:]])
                  debecho "--> HH:MM"
                  local ch="$(echo $token|cut -d':' -f1)"
                  local cm="$(echo $token|cut -d':' -f2)"
                  if [ $ch -gt 23 ] || [ $cm -gt 59 ]; then
                    echo "Bad time definition!"
                    USCITA=$E_BAD_TIME
                    exit $USCITA
                  fi
                  #Use timestamp??
                  crit="$crit && [ \"$ch:$cm\" $NOT= \"$now_hour:$now_min\" ]"
                  ;;
              mon|tue|wed|thu|fri|sat|sun)
                  debecho "--> abbreviated weekday"
                  local wday="$token"
                  crit="$crit && [ $wday $NOT= $name_today ]"
                  ;;
              monday|tuesday|wednesday|thursday|friday|saturday|sunday)
                  debecho "--> long weekday"
                  local wday="$token"
                  crit="$crit && [ $wday $NOT= $long_name_today ]"
                  ;;
              jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)
                  debecho "--> abbreviated monthname"
                  local wmonth="$token"
                  crit="$crit && [ $wmonth $NOT= $name_month ]"
                  ;;
              january|ferbruary|march|april|may|june|july|august|september|\
              october|november|december)
                  debecho "--> long monthname"
                  local wmonth="$token"
                  crit="$crit && [ $wmonth $NOT= $long_name_month ]"
                  ;;
              [[:digit:]]d|[[:digit:]][[:digit:]]d)
                  debecho "--> days period"
                  check_mwd "d"
                  ;;
              [[:digit:]]w|[[:digit:]][[:digit:]]w)
                  debecho "--> weeks period"
                  check_mwd "w"
                  ;;
              [[:digit:]]M|[[:digit:]][[:digit:]]M)
                  debecho "--> month period"
                  check_mwd "M"
                  ;;
              [[:digit:]]|[[:digit:]][[:digit:]])
                  debecho "--> Exact day"
                  if [ $token -gt 31 ]; then
                    echo "There is no month long $token days!"
                    USCITA=$E_BAD_DAY
                    exit $USCITA
                  fi
                  if [ $token -gt $ldom ]; then
                    debecho "Adjusting to last day of month"
                    token=$ldom
                  fi
                  if [ -z "$NOT" ]; then
                    crit="$crit && [ $today -eq $token ]"
                  else
                    crit="$crit && [ $today -ne $token ]"
                  fi
                  ;;
              *)
                  echo "Error in period definition. Token: $token"
                  USCITA=$E_BAD_PERIOD
                  exit $USCITA
                  ;;
            esac
          fi
          if [ -z "$first" ]; then
            first="$NOT$token"
          else
            first="$first $NOT$token"
          fi
          NOT=
        done
        crit=${crit:4}
        debecho "evaluating:"
        debecho "$crit"
        eval "if $crit; then update_stamp; return 1; else crit=; fi"
      done
      if [ -z $dont_exit ]; then
        break
      else
        dont_exit=
        exit_t=
      fi
    IFS="$OLDIFS"
  done
  return 0
}

debecho "Filling time-related variables"
date_refer=$(date "+%m/%d/%Y %H:%M:%S")

fill_timevar "$date_refer"

log="piripìcchiocchiò.chiò"
parse_period "$1"
if [ $? -eq 1 ]; then
  echo "VERIFIED"
else
  echo "not verified"
fi

