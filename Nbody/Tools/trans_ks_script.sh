#Used for tran ks_term.out to root------------------------------#
# Need used in the root directory------------------------#
savedir='~/data/rootdata'

if [ -e $savedir ];then
    echo $savedir' exist'
else
    mkdir $savedir
fi

ls |egrep '^[13570]+_[0-9]'>templist
totnum=`wc -l templist|cut -d' ' -f1`
for ((i=1;i<=$totnum;i=i+1))
do
    nowdir=`head -$i templist|tail -1`
    if [ -e $nowdir ]; then
	cd $nowdir
	if [ -e ks_term.out ]; then
	    echo $nowdir
	    trans_ks 1 $nowdir 0 $savedir/ ./
	    if [[ -e ks_finish ]] && [[ -e $savedir/$nowdir'_ks_0.root' ]];then
		rm -f ks_term.out
	    else
		echo $nowdir >>unsuclist_ks
	    fi
	else
	    echo 'No ks_term found in '$nowdir
	fi
	cd ..
    else
	echo 'No '$nowdir' found'
    fi
done
