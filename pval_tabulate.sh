#!/bin/bash

G_SIGN="neg pos"
G_GROUPNUM=3
G_CURVpos="K K1 K2 H S C BE thickness"
G_CURVneg="K K1 K2 H"
G_TYPE="le5"

G_SEPSTRING=""

# User spec'd
HEMI=lh
SURFACE=smoothwm
REGION=frontal

G_SYNPOSIS="

  NAME

        pval_tabulate.sh

  SYNOPSIS
  
        pval_tabulate.sh -h <hemi> -r <region> -s <surface> \
                                [-T <optionalType>]
                                [-S <sepString>] [-G <groupNum>]

  DESC

        'pval_tabulate.sh' is rather simple script that creates
        a table of data suitable for incorporation into papers/presentations.

        It essentially reads the '*-pval' file for a file of name:
        
            <sign>-<group>-<hemi>-<curv>-<region>-<surface>-pval.txt
            
        and creates a table of pvals for groups by curvature functions.

  ARGS

        -h <hemi>
        The hemisphere to process ('lh' or 'rh').
        
        -r <region>
        The region to process ('frontal', 'temporal', 'parietal', 'occipital)'

        -s <surface>
        The surface to process ('smoothwm', 'pial')

        -T <optionalType>
        The pval specifier to tag. This can be one of 'le5' (less than
        equal to 5%) or 'le1' (less than equal to 1%).
        
        -S <sepString>
        Print <sepString> between field columns.
        
        -G <groupNum>
        The number of a priori groupings.

  HISTORY
  
  09 March 2013
  o Type spec.

"

while getopts h:r:s:S:G:T: option ; do
    case "$option" 
    in
        h) HEMI=$OPTARG         ;;
        r) REGION=$OPTARG       ;;
        s) SURFACE=$OPTARG      ;;
        S) G_SEPSTRING=$OPTARG  ;;
        G) G_GROUPNUM=$OPTARG   ;;
        T) G_TYPE=$OPTARG       ;;
    esac
done

# To find the combinations, in MatLAB use:
#       C = combnk(1:5,2)
# for all the combinations of 5 groups.
case "$G_GROUPNUM"
in 
        1) G_GROUPS="1-1"                       ;; # This is actually meaningless
        2) G_GROUPS="1-2"                       ;;
        3) G_GROUPS="1-2 2-3 1-3"               ;;
        4) G_GROUPS="1-2 1-3 1-4 2-3 2-4 3-4"   ;;
        5) G_GROUPS="1-2 1-3 1-4 1-5 2-3 2-4 2-5 3-4 3-5 4-5" ;;
        6) G_GROUPS="1-2 1-3 1-4 1-5 1-6 2-3 2-4 2-5 2-6 3-4 3-5 3-6 4-5 4-6 5-6" ;;
esac

printf "%15s%s" "curv" "$G_SEPSTRING"
for SIGN in $G_SIGN ; do
   for GROUP in $G_GROUPS ; do 
        printf "%15s%s" "$SIGN-$GROUP" "$G_SEPSTRING"
   done
done
printf "\n"

if [[ $G_TYPE == "le5" ]] ; then G_PVAL="le5 le1"; fi
if [[ $G_TYPE == "le1" ]] ; then G_PVAL="le1"; fi


for CURV in $G_CURVpos ; do
    printf "%15s%s" "$CURV" "$G_SEPSTRING"
    for SIGN in $G_SIGN ; do
        for GROUP in $G_GROUPS ; do
          pval="NaN"
          for PVAL in $G_PVAL ; do
            fileName=${SIGN}-${GROUP}-pval-${HEMI}.${CURV}.${REGION}.${SURFACE}-${PVAL}.txt
            if [[ -f $fileName ]] ; then
                pval=$(cat $fileName)
            fi
          done
          printf "%15.5f%s" $pval "$G_SEPSTRING"
        done
    done
    printf "\n"
done
