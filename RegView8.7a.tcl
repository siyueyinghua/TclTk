#!/usr/local/bin/wish

#===========================================#
#       Author:         mingguang.ye        #
#       Version:        V1.0                #
#       last Updated:   2022/01/12          #
#===========================================#

# window properity
wm title . "RegView_V1.0 by mingguang.ye"
wm resizable . 0 0

# Global variable definiton
set CBLOWER 0
set CBUPPER 1
set BITGORUP [list $CBLOWER $CBUPPER]
set BTCLICK  2
set BTENTRY0  3
set BTENTRY1  4
set ENTRYHEX  5
set ENTRYDEC  6
set ENTRYOCT  7
set ENTRYBIN  8
set updatebybitcbflag 0
set setnbits 16
set shiftnbits 32

# >=====bits button area=====<
frame .buttonlist${CBUPPER} -borderwidth 4 -relief ridge
grid .buttonlist${CBUPPER} -padx 20 -pady 10 -row $CBLOWER -column 0
frame .buttonlist${CBLOWER} -borderwidth 4 -relief ridge
grid .buttonlist${CBLOWER} -padx 20 -pady 10 -row $CBUPPER -column 0

set bitvar(0,0) 0
set bitstring(0,0) "0"

proc updatebitcheckbuttontext { group n } {
    global bitvar
    global bitstring
    global BITGORUP
    global valuebin
    global updatebybitcbflag

    set updatebybitcbflag 1
    set bitstring(${group},${n}) $bitvar(${group},${n})
    ## puts stdout "Value Change Detection! ${group}_${n}: $bitvar(${group},${n})"

    set bitscbvaluebin ""
    foreach i $BITGORUP {
        ## puts "i: $i"
        for {set j 0} {$j < 32} {incr j} {
            ## puts "set bitvar(${i},${j})"
            set bitscbvaluebin $bitstring(${i},${j})$bitscbvaluebin
        }
    }
    ## puts "bitscbvaluebin: $bitscbvaluebin"
    # Bin values in entry: valuebin, of wich length may be greater than 64 bits
    # We just change the lower 64bits, preserving the bits higher than 64 bits,
    set valuebinhighthan64bit [string range "$valuebin" 0 end-64]
    set valuebinfullnew $valuebinhighthan64bit$bitscbvaluebin
    set valuedecnew [scan "$valuebinfullnew" %llb]
    set valuebin [format %llb $valuedecnew]
}

proc placebitbutton { group n } {
    global bitvar
    global bitstring

    set fbg [expr {$n/4}]
    set fbgmod [expr {$n%4}]
    ## puts "$fbg $fbgmod"
    if {$fbgmod ==0} {
        frame .buttonlist${group}.fourbit${fbg} -borderwidth 2 -relief ridge
        grid .buttonlist${group}.fourbit${fbg} -row $group -column [expr {7-$fbg}] -padx 4 -pady 2
    }
    ## puts stdout .buttonlist${group}.fourbit${fbg}.bitcb${n}
    label .buttonlist${group}.fourbit${fbg}.bitlb${n} -text "[expr {$group*32+${n}}]"
    grid .buttonlist${group}.fourbit${fbg}.bitlb${n} -padx 2 -pady 2 -row 0 -column [expr {31-$n}]
    checkbutton .buttonlist${group}.fourbit${fbg}.bitcb${n} -variable bitvar(${group},${n}) \
        -textvariable bitstring(${group},${n}) -text "0" \
        -width 2 -height 2 -indicatoron 0 -offrelief sunken \
        -command "updatebitcheckbuttontext ${group} ${n}"
    grid .buttonlist${group}.fourbit${fbg}.bitcb${n} -padx 2 -pady 2 -row 1 -column [expr {31-$n}]
}

for {set i 0} {$i < 32} {incr i} {
    ## puts $i
    placebitbutton $CBLOWER $i
    placebitbutton $CBUPPER $i
}

proc hex2bin {largehex} {
    set binstr 0
    binary scan [binary format H* $largehex] B* binstr
    return $binstr
}

proc setcheckbuttonbitsvalue {setvalue} {
    global BITGORUP
    global bitvar
    global bitstring

    ## puts "setcheckbuttonbitsvalue: $setvalue"
    foreach i $BITGORUP {
        ## puts "i: $i"
        for {set j 0} {$j < 32} {incr j} {
            ## puts "set bitvar(${i},${j})"
            set bitvar(${i},${j}) $setvalue
            set bitstring(${i},${j}) $bitvar(${i},${j})
        }
    }
}

proc updateonset {setbitswidth} {
    ## global bitvar
    ## global bitstring
    ## global valuehex
    ## global valuedec
    ## global valueoct
    global valuebin

    ## puts "-->setbitswidth: $setbitswidth set begin<--"
    if {$setbitswidth != ""} {
        set nbitsvaluebin ""
        # No need to set here, cause trace of entry will update check button bits
        ## setcheckbuttonbitsvalue 1

        ## puts "-->set hex<--"
        for {set j 0} {$j < $setbitswidth} {incr j} {
            set nbitsvaluebin "${nbitsvaluebin}1"
        }
        ## puts "setbitswidth=$setbitswidth, calnbits=[string length $nbitsvaluebin]: $nbitsvaluebin "
        set valuebin $nbitsvaluebin
        ## puts "-->set hex<--"
        # no need to set others, cause they will be set in trace valuehex
        ## set valuedec [format %llu 0x${valuehex}]
        ## set valueoct [format %llo 0x${valuehex}]
        ## set valuebin [format %llb 0x${valuehex}]

        ## set valuebin [hex2bin FFFFFFFFFFFFFFFF]
        ## set valuedec [expr {0x$valuehex}]
    }
    ## puts "-->setbitswidth: $setbitswidth set end<--"
}

proc updateonclear {} {
    global bitvar
    global bitstring
    global valuehex
    global valuedec
    global valueoct
    global valuebin

    ## puts "clear clicked"
    # No need to set here, cause trace of entry will update check button bits
    ## setcheckbuttonbitsvalue 0

    ## puts "-->clear hex<--"
    set valuehex 0
    ## puts "-->clear hex<--"
    # no need to set others, cause they will be set in trace valuehex
    # set valuedec 0
    # set valueoct 0
    # set valuebin 0
}

proc updateonshift {direction shiftbitswidth} {
    ## global bitvar
    ## global bitstring
    ## global valuehex
    ## global valuedec
    ## global valueoct
    global valuebin

    set nbitsvaluebin ""

    ## puts "-->$direction shift $shiftbitswidth bits begin, valuebin: $valuebin<--"
    if {$shiftbitswidth != "" && $valuebin != ""} {
        ## puts "shiftbinwidth not null"
        if {$direction == "left"} {
            set valuebin [format %llb [expr 0b$valuebin << $shiftbitswidth]]
        } elseif {$direction == "right"} {
            set valuebin [format %llb [expr 0b$valuebin >> $shiftbitswidth]]
        }
        ## puts "after shift valuebin: $valuebin "
    }
    ## puts "-->$direction shift $shiftbitswidth bits end, valuebin: $valuebin<--"
}



# Bit click button sub area
set buttonclickpadx 100
set buttonclickpady 5
set buttonclickwidth 12
## frame .buttonlist${BTCLICK} -borderwidth 4 -relief ridge
frame .buttonlist${BTCLICK}
grid .buttonlist${BTCLICK} -padx 20 -pady 20 -row ${BTCLICK} -column 0
button .buttonlist${BTCLICK}.set64bitsbt -text "Set  64  Bits" -width $buttonclickwidth -command {updateonset 64}
grid .buttonlist${BTCLICK}.set64bitsbt -row 0 -column 0 -padx $buttonclickpadx -pady $buttonclickpady
button .buttonlist${BTCLICK}.clearbt -text "clear" -width [expr {$buttonclickwidth-2}] -command {updateonclear}
grid .buttonlist${BTCLICK}.clearbt -row 0 -column 1 -padx $buttonclickpadx -pady $buttonclickpady
button .buttonlist${BTCLICK}.set32bitsbt -text "Set  32  Bits" -width $buttonclickwidth -command {updateonset 32}
grid .buttonlist${BTCLICK}.set32bitsbt -row 0 -column 2 -padx $buttonclickpadx -pady $buttonclickpady

# Bit entry button  sub area
set buttonentrypadx 40
set buttonentrypady 5
## frame .buttonlist${BTENTRY0} -borderwidth 4 -relief ridge
frame .buttonlist${BTENTRY0}
grid .buttonlist${BTENTRY0} -padx 20 -pady 10 -row ${BTENTRY0} -column 0
#===> Shift
button .buttonlist${BTENTRY0}.leftshiftbt -text "left shift <<" -width $buttonclickwidth -command {updateonshift left $shiftnbits}
grid .buttonlist${BTENTRY0}.leftshiftbt -row 0 -column 0 -padx $buttonentrypadx -pady $buttonentrypady
entry .buttonlist${BTENTRY0}.shiftbitsentry -textvariable shiftnbits \
    -width 10 -validate key -vcmd {string is digit %P}
grid .buttonlist${BTENTRY0}.shiftbitsentry -row 0 -column 1
label .buttonlist${BTENTRY0}.shiftbitslabel -text "Bits" -width 4
grid .buttonlist${BTENTRY0}.shiftbitslabel -row 0 -column 2
button .buttonlist${BTENTRY0}.rightshiftbt -text ">> right  shift" -width $buttonclickwidth -command {updateonshift right $shiftnbits}
grid .buttonlist${BTENTRY0}.rightshiftbt -row 0 -column 3 -padx $buttonentrypadx -pady $buttonentrypady

#===> Set n bits
button .buttonlist${BTENTRY0}.setnbitsbt -text "Set  n  Bits" -width $buttonclickwidth -command {updateonset $setnbits}
grid .buttonlist${BTENTRY0}.setnbitsbt -row 0 -column 4 -padx $buttonentrypadx -pady $buttonentrypady
entry .buttonlist${BTENTRY0}.setnbitsentry -textvariable setnbits \
    -width 10 -validate key -vcmd {string is digit %P}
grid .buttonlist${BTENTRY0}.setnbitsentry -row 0 -column 5
label .buttonlist${BTENTRY0}.setnbitslabel -text "Bits" -width 4
grid .buttonlist${BTENTRY0}.setnbitslabel -row 0 -column 6

# >=====Set region bits Area=====<
proc updateonsetvalue {} {
    global valuebin
    global setvaluebeginbit
    global setvalueendbit
    global setvaluevardec

    if {$setvaluebeginbit == "" || $setvalueendbit == "" || $setvaluevardec == "" || [expr $setvaluebeginbit > $setvalueendbit]} {
        return
    }
    ## puts "-->updateonsetvalue set begin valuebin: $valuebin, setvaluevardec: $setvaluevardec<--"
    if {$valuebin == ""} {
        set valuebin 0
    }
    set setvaluebitwidth [expr $setvalueendbit - $setvaluebeginbit + 1]
    ## puts "setvaluebitwidth: $setvaluebitwidth, setvalueendbit: $setvalueendbit"
    set valuebinalign2endbit [format %0[expr ${setvalueendbit} + 1]llb 0b$valuebin]
    set valuebinalign2endbitl2h [string reverse $valuebinalign2endbit]
    ## puts "valuebinalign2endbitl2h: $valuebinalign2endbitl2h"

    set setvaluevarbinalign2setwidth [format %0${setvaluebitwidth}llb $setvaluevardec]
    ## puts "setvaluevarbinalign2setwidth: $setvaluevarbinalign2setwidth"
    set setvaluevarbinalign2setwidthl2h [string reverse $setvaluevarbinalign2setwidth]
    ## puts "setvaluevarbinalign2setwidthl2h: $setvaluevarbinalign2setwidthl2h"
    set setvaluevarbinalign2setwidthl2h [string range $setvaluevarbinalign2setwidthl2h 0 [expr $setvaluebitwidth - 1]]
    ## puts "setvaluevarbinalign2setwidthl2h truncate: $setvaluevarbinalign2setwidthl2h"
    set valuebinalign2endbitnew [string replace $valuebinalign2endbitl2h $setvaluebeginbit $setvalueendbit $setvaluevarbinalign2setwidthl2h]
    ## puts "valuebinalign2endbitnew: $valuebinalign2endbitnew"
    set valuebin [string reverse $valuebinalign2endbitnew]
    ## puts "valuebin: $valuebin"

}

proc tracerset args {
    global setvaluevarhex
    global setvaluevardec
    global setvaluevarbin

    # Remove trace to avoid tracing recursively
    trace remove variable setvaluevarhex write tracerset
    trace remove variable setvaluevardec write tracerset
    trace remove variable setvaluevarbin write tracerset

    set variabletype [lindex $args 0]
    ## puts "$variabletype => begin"
    if {$variabletype == "setvaluevarhex"} {
        if {$setvaluevarhex == ""} {
            ## puts "empty setvaluevarhex: $setvaluevarhex"
            set setvaluevardec $setvaluevarhex
            set setvaluevarbin $setvaluevarhex
        } else {
            set setvaluevarhex [format %llX [scan $setvaluevarhex %llX]]
            set setvaluevardec [format %llu 0x$setvaluevarhex]
            set setvaluevarbin [format %llb 0x$setvaluevarhex]
        }
    } elseif {$variabletype == "setvaluevardec"} {
        if {$setvaluevardec == ""} {
            ## puts "empty setvaluevardec: $setvaluevardec"
            set setvaluevarhex $setvaluevardec
            set setvaluevarbin $setvaluevardec
        } else {
            set setvaluevardec [scan $setvaluevardec %lld]
            set setvaluevarhex [format %llX [scan $setvaluevardec %lld]]
            set setvaluevarbin [format %llb [scan $setvaluevardec %lld]]
        }
    } elseif {$variabletype == "setvaluevarbin"} {
        if {$setvaluevarbin == ""} {
            set setvaluevarhex $setvaluevarbin
            set setvaluevardec $setvaluevarbin
        } else {
            set setvaluevarbin [format %llb [scan $setvaluevarbin %llb]]
            set setvaluevarhex [format %llX 0b$setvaluevarbin]
            set setvaluevardec [format %llu 0b$setvaluevarbin]
        }
    }

    # Add trace again for later tracing
    trace add variable setvaluevarhex write tracerset
    trace add variable setvaluevardec write tracerset
    trace add variable setvaluevarbin write tracerset
}


#===> region sets value
## frame .buttonlist${BTENTRY1} -borderwidth 4 -relief ridge
set btentry1btpadx 80
set btentry1etpadx 5
set btentry1lbpadx 10
frame .buttonlist${BTENTRY1}
grid .buttonlist${BTENTRY1} -padx 10 -pady 20 -row ${BTENTRY1} -column 0
label .buttonlist${BTENTRY1}.setvaluebeginbitlb -text "From(Low)" -anchor e -justify right -width 10
grid .buttonlist${BTENTRY1}.setvaluebeginbitlb -row 2 -column 0 -padx $btentry1lbpadx
entry .buttonlist${BTENTRY1}.setvaluebeginbitsentry -textvariable setvaluebeginbit \
    -width 8 -validate key -vcmd {string is digit %P}
grid .buttonlist${BTENTRY1}.setvaluebeginbitsentry -row 2 -column 1 -padx $btentry1etpadx
label .buttonlist${BTENTRY1}.setvalueendbitlb -text "To(High)"  -anchor e -justify right -width 10
grid .buttonlist${BTENTRY1}.setvalueendbitlb -row 2 -column 2 -padx $btentry1lbpadx
entry .buttonlist${BTENTRY1}.setvalueendbitsentry -textvariable setvalueendbit \
    -width 8 -validate key -vcmd {string is digit %P}
grid .buttonlist${BTENTRY1}.setvalueendbitsentry -row 2 -column 3 -padx $btentry1etpadx

label .buttonlist${BTENTRY1}.setvaluedeclb -text "Values(Dec)"  -anchor e -justify right -width 10
grid .buttonlist${BTENTRY1}.setvaluedeclb -row 1 -column 4 -padx $btentry1lbpadx
entry .buttonlist${BTENTRY1}.setvalueentrydec -textvariable setvaluevardec \
    -width 20 -validate key -vcmd {string is digit %P}
grid .buttonlist${BTENTRY1}.setvalueentrydec -row 1 -column 5 -padx $btentry1etpadx
trace add variable setvaluevardec write tracerset

label .buttonlist${BTENTRY1}.setvaluehexlb -text "Values(Hex)"  -anchor e -justify right -width 10
grid .buttonlist${BTENTRY1}.setvaluehexlb -row 2 -column 4 -padx $btentry1lbpadx
entry .buttonlist${BTENTRY1}.setvalueentryhex -textvariable setvaluevarhex \
    -width 20 -validate key -vcmd {string is xdigit %P}
grid .buttonlist${BTENTRY1}.setvalueentryhex -row 2 -column 5 -padx $btentry1etpadx
trace add variable setvaluevarhex write tracerset

label .buttonlist${BTENTRY1}.setvaluebinlb -text "Values(Bin)"  -anchor e -justify right -width 10
grid .buttonlist${BTENTRY1}.setvaluebinlb -row 3 -column 4 -padx $btentry1lbpadx
entry .buttonlist${BTENTRY1}.setvalueentrybin -textvariable setvaluevarbin \
    -width 20 -validate key -vcmd {expr {![regexp {[^0-1]+} %P]}}
grid .buttonlist${BTENTRY1}.setvalueentrybin -row 3 -column 5 -padx $btentry1etpadx
trace add variable setvaluevarbin write tracerset

button .buttonlist${BTENTRY1}.setvaluebt -text "Set" -width 6 -command {updateonsetvalue}
grid .buttonlist${BTENTRY1}.setvaluebt -row 2 -column 6 -padx $btentry1btpadx -pady $buttonentrypady


# >=====Entry Area=====<
proc tracerentry args {
    global BITGORUP
    global bitvar
    global bitstring
    global valuehex
    global valuedec
    global valueoct
    global valuebin
    global updatebybitcbflag

    # Remove trace to avoid tracing recursively
    trace remove variable valuehex write tracerentry
    trace remove variable valuedec write tracerentry
    trace remove variable valueoct write tracerentry
    trace remove variable valuebin write tracerentry

    set variabletype [lindex $args 0]
    ## puts "$variabletype => begin"
    if {$variabletype == "valuehex"} {
        if {$valuehex == ""} {
            ## puts "empty valuehex: $valuehex"
            set valuedec $valuehex
            set valueoct $valuehex
            set valuebin $valuehex
        } else {
            set valuehex [format %llX [scan $valuehex %llX]]
            set valuedec [format %llu 0x$valuehex]
            set valueoct [format %llo 0x$valuehex]
            set valuebin [format %llb 0x$valuehex]
        }
    } elseif {$variabletype == "valuedec"} {
        if {$valuedec == ""} {
            ## puts "empty valuedec: $valuedec"
            set valuehex $valuedec
            set valueoct $valuedec
            set valuebin $valuedec
        } else {
            set valuedec [scan $valuedec %lld]
            set valuehex [format %llX [scan $valuedec %lld]]
            set valueoct [format %llo [scan $valuedec %lld]]
            set valuebin [format %llb [scan $valuedec %lld]]
        }
    } elseif {$variabletype == "valueoct"} {
        if {$valueoct == ""} {
            ## puts "empty valueoct: $valueoct"
            set valuehex $valueoct
            set valuedec $valueoct
            set valuebin $valueoct
        } else {
            ## puts "not empty valueoct: $valueoct"
            set valueoct [format %llo [scan $valueoct %llo]]
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
            set valuebin [format %llb [scan $valuebin %llb]]
            set valuehex [format %llX 0b$valuebin]
            set valuedec [format %llu 0b$valuebin]
            set valueoct [format %llo 0b$valuebin]
        }
    }

    ## puts "$variabletype => end"

    # Update data to bits check buttons
    # if the value is update by bits check buttons,
    # then no need to update the bits check buttons.
    if {! $updatebybitcbflag} {
        if {$valuebin == ""} {
            set valuebinfullbith2l [format %064llb 0b0]
        } else {
            set valuebinfullbith2l [format %064llb 0b$valuebin]
        }
        ## puts "valuebinfullbith2l: $valuebinfullbith2l"
        set valuebinfullbitl2h [string reverse $valuebinfullbith2l]
        ## puts "valuebinfullbitl2h: $valuebinfullbitl2h"
        set valuebinfullbitl2hlist [split $valuebinfullbitl2h {}]

        foreach i $BITGORUP {
            ## puts "i: $i"
            for {set j 0} {$j < 32} {incr j} {
                ## puts "set bitvar(${i},${j}) -- [expr {$i*31+$j}]"
                set bitvar(${i},${j}) [lindex $valuebinfullbitl2hlist [expr {$i*32+$j}]]
                set bitstring(${i},${j}) $bitvar(${i},${j})
            }
        }
    } else {
        set updatebybitcbflag 0
    }

    # Add trace again for later tracing
    trace add variable valuehex write tracerentry
    trace add variable valuedec write tracerentry
    trace add variable valueoct write tracerentry
    trace add variable valuebin write tracerentry

    ## set i 0
    ## foreach arg $args {
    ##     ## puts "$i: $arg"
    ##     # incr i
    ## }
}

frame .buttonlist${ENTRYHEX} -borderwidth 4 -relief ridge
grid .buttonlist${ENTRYHEX} -padx 20 -pady 20 -row ${ENTRYHEX} -column 0
label .buttonlist${ENTRYHEX}.hexlabel -text "Heximal " -width 10
grid .buttonlist${ENTRYHEX}.hexlabel -row 0 -column 0
entry .buttonlist${ENTRYHEX}.hexentry -textvariable valuehex \
    -width 100 -validate key -vcmd {string is xdigit %P}
grid .buttonlist${ENTRYHEX}.hexentry -row 0 -column 1
trace add variable valuehex write tracerentry

frame .buttonlist${ENTRYDEC} -borderwidth 4 -relief ridge
grid .buttonlist${ENTRYDEC} -padx 20 -pady 10 -row ${ENTRYDEC} -column 0
label .buttonlist${ENTRYDEC}.declabel -text "decimal " -width 10
grid .buttonlist${ENTRYDEC}.declabel -row 0 -column 0
entry .buttonlist${ENTRYDEC}.decentry -textvariable valuedec \
    -width 100 -validate key -vcmd {string is digit %P}
grid .buttonlist${ENTRYDEC}.decentry -row 0 -column 1
trace add variable valuedec write tracerentry

frame .buttonlist${ENTRYOCT} -borderwidth 4 -relief ridge
grid .buttonlist${ENTRYOCT} -padx 20 -pady 10 -row ${ENTRYOCT} -column 0
label .buttonlist${ENTRYOCT}.octlabel -text "octal " -width 10
grid .buttonlist${ENTRYOCT}.octlabel -row 0 -column 0
entry .buttonlist${ENTRYOCT}.octentry -textvariable valueoct \
    -width 100 -validate key -vcmd {expr {![regexp {[^0-7]+} %P]}}
grid .buttonlist${ENTRYOCT}.octentry -row 0 -column 1
trace add variable valueoct write tracerentry

frame .buttonlist${ENTRYBIN} -borderwidth 4 -relief ridge
grid .buttonlist${ENTRYBIN} -padx 20 -pady 10 -row ${ENTRYBIN} -column 0
label .buttonlist${ENTRYBIN}.binlabel -text "binary " -width 10
grid .buttonlist${ENTRYBIN}.binlabel -row 0 -column 0
entry .buttonlist${ENTRYBIN}.binentry -textvariable valuebin \
    -width 100 -validate key -vcmd {expr {![regexp {[^0-1]+} %P]}}
grid .buttonlist${ENTRYBIN}.binentry -row 0 -column 1
trace add variable valuebin write tracerentry

