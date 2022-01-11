proc validInteger {win event X oldX min max} {
    # Make sure min<=max
    if {$min > $max} {
        set tmp $min; set min $max; set max $tmp
    }
    # Allow valid integers, empty strings, sign without number
    # Reject Octal numbers, but allow a single "0"
    # Which signes are allowed ?
    if {($min <= 0) && ($max >= 0)} {   ;# positive & negative sign
        set pattern {^[+-]?(()|0|([1-9][0-9]*))$}
    } elseif {$max < 0} {               ;# negative sign
        set pattern {^[-]?(()|0|([1-9][0-9]*))$}
    } else {                            ;# positive sign
        set pattern {^[+]?(()|0|([1-9][0-9]*))$}
    }
    # Weak integer checking: allow empty string, empty sign, reject octals
    set weakCheck [regexp $pattern $X]
    # if weak check fails, continue with old value
    if {! $weakCheck} {set X $oldX}
    # Strong integer checking with range
    set strongCheck [expr {[string is int -strict $X] && ($X >= $min) && ($X <= $max)}]

    switch $event {
        key {
            $win configure -bg [expr {$strongCheck ? {white} : {yellow}}]
            return $weakCheck
        }
        focusout {
            if {! $strongCheck} {$win configure -bg red}
            return $strongCheck
        }
        default {
            return 1
        }
    }
}

proc checkForm {args} {
    set err 0
    foreach win $args {
        switch -- [$win cget -bg] {
            red -
            yellow {
                incr err
            }
        }
    }
    if {$err} {
        tk_messageBox -type ok -icon error -message "Check $err invalid field(s)"
    } else {
        tk_messageBox -type ok -message {Changes applied successfully}
    }
}

set x1 12; set x2 345; set x3 -678

label .t1 -text {int (10..92)}
entry .e1  -textvariable x1 -validate all -vcmd {validInteger %W %V %P %s +10 +92}
label .t2 -text {int (-256..+1024)}
entry .e2 -textvariable x2 -validate all -vcmd {validInteger %W %V %P %s +1024 -256}
label .t3 -text {int (-768..0)}
entry .e3 -textvariable x3 -validate all -vcmd {validInteger %W %V %P %s -768 0}

button .apply -text {Apply changes} -command {checkForm .e1 .e2 .e3}

grid .t1 .e1 -sticky w
grid .t2 .e2 -sticky w
grid .t3 .e3 -sticky w
grid .apply - -sticky ew