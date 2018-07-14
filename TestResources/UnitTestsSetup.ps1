

##########################################################################

Function Setup-Default {
}

Function TearDown-Default {
    # sometimes the unit tests end and the command prompt is at 'SQLSERVER:>' instead of 'D:\>'
    # so, this tries to ensure that the command prompt is the one currently selected
    D:
}

##########################################################################
