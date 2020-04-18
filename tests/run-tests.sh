
for t in $(ls $PWD/test_*.sh); do 
    (
        echo -e "\n\n=================================="
        echo "= running test $t"
        TESTDIR=${TMPDIR:-/tmp}/${t//\//_}
        mkdir -pv $TESTDIR
        cd $TESTDIR

        export HOME_OVERRRIDE=/tmp
        bash $t
    )
done
