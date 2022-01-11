label .l0 -text "ENTRY WIDGET VALIDATION EXAMPLES:"

label .l1 -text "Integer:"
entry .e1 -validate key -vcmd {string is int %P}

label .l2 -text "Integer && 7 char limit:"
entry .e2 -validate key \
        -vcmd {expr {[string is int %P] && [string length %P]<8}}

label .l3 -text "Integer with leading +/-:"
entry .e3 -validate key \
        -vcmd {expr {[string match {[-+]} %P] || [string is int %P]}}

label .l4 -text "Integer forbidding leading zero:"
entry .e4 -validate key \
        -vcmd {expr {[string is int %P] && ![string match "0*" %P]}}

label .l5 -text "Real Number:"
entry .e5 -validate key -vcmd {string is double %P}

label .l6 -text "Alpha:"
entry .e6 -validate key -vcmd {string is alpha %P}

label .l7 -text "Hexadecimal:"
entry .e7 -validate key -vcmd {string is xdigit %P}

label .l8 -text "8 char limit:"
entry .e8 -validate key -vcmd {expr {[string len %P] <= 8}}

grid .l0 -columnspan 2 -sticky w
grid .l1 .e1
grid .l2 .e2
grid .l3 .e3
grid .l4 .e4
grid .l5 .e5
grid .l6 .e6
grid .l7 .e7
grid .l8 .e8
grid configure .l1 .l2 .l3 .l4 .l5 .l6 .l7 .l8 -sticky e
grid configure .e1 .e2 .e3 .e4 .e5 .e6 .e7 .e8 -sticky ew
grid columnconfigure . 1 -weight 1