Phusion=false

## Define usage function:
function usage()
{
        echo -e "\nUsage : $0 -l [list.txt] -f [Allfasta.fna] -o [out_file.txt] -z [Debugging mode] -p [Phusion primers] \n"
}


while getopts l:f:o:zp options ; do
case $options in
    l)
        list=$OPTARG;;
    f)
        fasta_file=$OPTARG;;
    o)
        outfile=$OPTARG;;
    z)
        Debugging=true;;
    p)
        Phusion=true;;
    *)
        usage
        echo -e "\n Invalid argument"
esac
done

shift "$((OPTIND-1))"

if [ -z "${list}" ]; then
           printf "  Option -l must be specified\n"
           usage
           exit
fi
if [ -z "${fasta_file}" ]; then
           printf "  Option -f must be specified\n"
           usage
           exit
fi
if [ -z "${outfile}" ]; then
           printf "  Option -o must be specified\n"
           usage
           exit
fi


faSomeRecords ${fasta_file} ${list} sequences.out

#replace everything with correct formatting and leave only locus tag
sed -i -e 's/>/SEQUENCE_ID=/g' sequences.out

awk '{print ((NR%2 ==0)? "SEQUENCE_TEMPLATE=":"") $0}' sequences.out > sequences2.out

awk ' {print;} NR % 2 == 0 { print "SEQUENCE_FORCE_LEFT_START=0"; }' sequences2.out > sequences3.out
awk ' {print;} NR % 3 == 0 { print "="; }' sequences3.out > primer3.in



settings="/Users/Nick/Bioinformatics/primer3-2.4.0/Settings/settings.txt"

Primer3_path="Bioinformatics/primer3-2.4.0/src/primer3_core"

~/${Primer3_path} -p3_settings_file=${settings} < primer3.in > designed_primers.txt

if [ "${Phusion}" = true ] ; then
  sed -i -e 's/PRIMER_LEFT_0_SEQUENCE=/PRIMER_LEFT_0_SEQUENCE=TTTGGGCTAACAGGAGGCTAGCAT/g; s/PRIMER_RIGHT_0_SEQUENCE=/PRIMER_RIGHT_0_SEQUENCE=CCGTTTAAACATTTAAATCTGCAG/g' designed_primers.txt 
fi

settings_verify="/Users/Nick/Bioinformatics/primer3-2.4.0/Settings/settings_verify.txt"
~/${Primer3_path} -p3_settings_file=${settings_verify} < primer3.in > primer3_verify.out.txt

awk '/'SEQUENCE_ID'|'PRIMER_RIGHT_0_SEQUENCE'|'PRIMER_PAIR_0_PRODUCT_SIZE'/{print}' primer3_verify.out.txt > primer3_verify2.out
(echo "VERIFICATION PRIMERS" && cat primer3_verify2.out) > primer3_verify3.out

cat designed_primers.txt <(echo) primer3_verify3.out > ${outfile}.txt

rm *.out*
rm designed_primers*