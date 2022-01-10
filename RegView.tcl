#!/usr/local/bin/wish

# window properity
wm title . "RegView"
wm resizable . 0 0

# bitlist area
set LOWER 0
set UPPER 1
set BITGORUP [list $LOWER $UPPER]
set CLICK  2
set ENTRYHEX  3
set ENTRYDEC  4
set ENTRYOCT  5
set ENTRYBIN  6
frame .buttonlist${UPPER} -borderwidth 4 -relief ridge
grid .buttonlist${UPPER} -padx 20 -pady 10 -row $LOWER -column 0
frame .buttonlist${LOWER} -borderwidth 4 -relief ridge
grid .buttonlist${LOWER} -padx 20 -pady 10 -row $UPPER -column 0

set bitvar(0,0) 0
set bitstring(0,0) "0"

proc updatebuttontext { group n } {
    global bitvar
    global bitstring
    global BITGORUP
    global valuebin

    set bitstring(${group},${n}) $bitvar(${group},${n})
    # puts stdout "Value Change Detection! ${group}_${n}: $bitvar(${group},${n})"

    set valuebintmp ""
    foreach i $BITGORUP {
        # puts "i: $i"
        for {set j 0} {$j < 32} {incr j} {
            # puts "set bitvar(${i},${j})"
            set valuebintmp $bitstring(${i},${j})$valuebintmp
        }
    }
    puts "valuebintmp: $valuebintmp"
    set valuedectmp [scan "$valuebintmp" %llb]
    set valuebin [format %llb $valuedectmp]
}

proc placebitbutton { group n } {
    global bitvar
    global bitstring

    set fbg [expr $n/4]
    set fbgmod [expr $n%4]
    # puts "$fbg $fbgmod"
    if {$fbgmod ==0} {
        frame .buttonlist${group}.fourbit${fbg}
        grid .buttonlist${group}.fourbit${fbg} -row $group -column [expr 7-$fbg] -padx 4 -pady 2
    }
    # puts stdout .buttonlist${group}.fourbit${fbg}.bitcb${n}
    label .buttonlist${group}.fourbit${fbg}.bitlb${n} -text "[expr $group*32+${n}]"
    grid .buttonlist${group}.fourbit${fbg}.bitlb${n} -padx 2 -pady 2 -row 0 -column [expr 31-$n]
    checkbutton .buttonlist${group}.fourbit${fbg}.bitcb${n} -variable bitvar(${group},${n}) \
        -textvariable bitstring(${group},${n}) -text "0" \
        -width 2 -height 2 -indicatoron 0 -offrelief sunken \
        -command "updatebuttontext ${group} ${n}"
    grid .buttonlist${group}.fourbit${fbg}.bitcb${n} -padx 2 -pady 2 -row 1 -column [expr 31-$n]
}

for {set i 0} {$i < 32} {incr i} {
    # puts $i
    placebitbutton $LOWER $i
    placebitbutton $UPPER $i
}

proc hex2bin {largehex} {
    set binstr 0
    binary scan [binary format H* $largehex] B* binstr
    return $binstr
}

proc setbitsgroupvalue {setvalue} {
    global BITGORUP

    foreach i $BITGORUP {
        # puts "i: $i"
        for {set j 0} {$j < 32} {incr j} {
            # puts "set bitvar(${i},${j})"
            set bitvar(${i},${j}) $setvalue
            set bitstring(${i},${j}) $bitvar(${i},${j})
        }
    }
}

proc updateonset {} {
    global bitvar
    global bitstring
    global valuehex
    global valuedec
    global valueoct
    global valuebin

    # puts "set clicked"
    setbitsgroupvalue 1

    puts "-->set hex<--"
    set valuehex "FFFFFFFFFFFFFFFF"
    puts "-->set hex<--"
    # no need to set others, cause they will be set in trace valuehex
    ## set valuedec [format %llu 0x${valuehex}]
    ## set valueoct [format %llo 0x${valuehex}]
    ## set valuebin [format %llb 0x${valuehex}]

    ## set valuebin [hex2bin FFFFFFFFFFFFFFFF]
    ## set valuedec [expr 0x$valuehex]
}

proc updateonclear {} {
    global bitvar
    global bitstring
    global valuehex
    global valuedec
    global valueoct
    global valuebin

    # puts "clear clicked"
    setbitsgroupvalue 1

    puts "-->clear hex<--"
    set valuehex 0
    puts "-->clear hex<--"
    # no need to set others, cause they will be set in trace valuehex
    # set valuedec 0
    # set valueoct 0
    # set valuebin 0
}

## frame .buttonlist${CLICK} -borderwidth 4 -relief ridge
frame .buttonlist${CLICK}
grid .buttonlist${CLICK} -padx 20 -pady 10 -row ${CLICK} -column 0
button .buttonlist${CLICK}.setbt -text "set" -width 10 -command {updateonset}
grid .buttonlist${CLICK}.setbt -row 0 -column 0 -padx 100 -sticky w
button .buttonlist${CLICK}.clearbt -text "clear" -width 10 -command {updateonclear}
grid .buttonlist${CLICK}.clearbt -row 0 -column 1 -padx 100 -sticky e


proc tracer args {
    global valuehex
    global valuedec
    global valueoct
    global valuebin

    # Remove trace to avoid tracing recursively
    trace remove variable valuehex write tracer
    trace remove variable valuedec write tracer
    trace remove variable valueoct write tracer
    trace remove variable valuebin write tracer

    set variabletype [lindex $args 0]
    puts "$variabletype => begin"
    if {$variabletype == "valuehex"} {
        if {$valuehex == ""} {
            set valuedec $valuehex
            set valueoct $valuehex
            set valuebin $valuehex
        } else {
            set valuedec [format %llu 0x$valuehex]
            set valueoct [format %llo 0x$valuehex]
            set valuebin [format %llb 0x$valuehex]
        }

    } elseif {$variabletype == "valuedec"} {
      if {$valuedec == ""} {
          set valuehex $valuedec
          set valueoct $valuedec
          set valuebin $valuedec
      } else {
          set valuehex [format %llX $valuedec]
          set valueoct [format %llo $valuedec]
          set valuebin [format %llb $valuedec]
      }
    } elseif {$variabletype == "valueoct"} {
        if {$valueoct == ""} {
            set valuehex $valueoct
            set valuedec $valueoct
            set valuebin $valueoct
        } else {
            set valuehex [format %llX 0o$valueoct]
            set valuedec [format %llu 0o$valueoct]
            set valuebin [format %llb 0o$valueoct]
        }
    } elseif {$variabletype == "valuebin"} {
        if {$valuebin == ""} {
            set valuehex $valuebin
            set valuedec $valuebin
            set valueoct $valuebin
        } else {
            set valuehex [format %llX 0b$valuebin]
            set valuedec [format %llu 0b$valuebin]
            set valueoct [format %llo 0b$valuebin]
        }
    }
    puts "$variabletype => end"

    # Add trace again for later tracing
    trace add variable valuehex write tracer
    trace add variable valuedec write tracer
    trace add variable valueoct write tracer
    trace add variable valuebin write tracer

    set i 0
    foreach arg $args {
        # puts "$i: $arg"
        # incr i
    }
}

frame .buttonlist${ENTRYHEX} -borderwidth 4 -relief ridge
grid .buttonlist${ENTRYHEX} -padx 20 -pady 10 -row ${ENTRYHEX} -column 0
label .buttonlist${ENTRYHEX}.hexlabel -text "Heximal " -width 10
grid .buttonlist${ENTRYHEX}.hexlabel -row 0 -column 0
entry .buttonlist${ENTRYHEX}.hexentry -textvariable valuehex -width 100
grid .buttonlist${ENTRYHEX}.hexentry -row 0 -column 1
trace add variable valuehex write tracer

frame .buttonlist${ENTRYDEC} -borderwidth 4 -relief ridge
grid .buttonlist${ENTRYDEC} -padx 20 -pady 10 -row ${ENTRYDEC} -column 0
label .buttonlist${ENTRYDEC}.declabel -text "decimal " -width 10
grid .buttonlist${ENTRYDEC}.declabel -row 0 -column 0
entry .buttonlist${ENTRYDEC}.decentry -textvariable valuedec -width 100
grid .buttonlist${ENTRYDEC}.decentry -row 0 -column 1
trace add variable valuedec write tracer

frame .buttonlist${ENTRYOCT} -borderwidth 4 -relief ridge
grid .buttonlist${ENTRYOCT} -padx 20 -pady 10 -row ${ENTRYOCT} -column 0
label .buttonlist${ENTRYOCT}.octlabel -text "octal " -width 10
grid .buttonlist${ENTRYOCT}.octlabel -row 0 -column 0
entry .buttonlist${ENTRYOCT}.octentry -textvariable valueoct -width 100
grid .buttonlist${ENTRYOCT}.octentry -row 0 -column 1
trace add variable valueoct write tracer

frame .buttonlist${ENTRYBIN} -borderwidth 4 -relief ridge
grid .buttonlist${ENTRYBIN} -padx 20 -pady 10 -row ${ENTRYBIN} -column 0
label .buttonlist${ENTRYBIN}.binlabel -text "binary " -width 10
grid .buttonlist${ENTRYBIN}.binlabel -row 0 -column 0
entry .buttonlist${ENTRYBIN}.binentry -textvariable valuebin -width 100
grid .buttonlist${ENTRYBIN}.binentry -row 0 -column 1
trace add variable valuebin write tracer

