resfile=res1


seeds=(
  21113944
  22225055 # 21113944 + 1111111
  22370411 # 21113944 + 1234567
  21927125 # 21113944 + 818181
  21136288 # 21113944 + 223344
  44931112 # Reverse of 21113944 
  46042223 # 44931112 + 1111111
  46187579 # 44931112 + 1234567
  45744293 # 44931112 + 818181
  44953456 # 44931112 + 223344
)

#Print out generated seeds to verify
echo "Generated seeds:"
printf "%s\n" "${seeds[@]}"

# Delete the result file if it exists, without prompting
rm -f $resfile

# Prepare a temporary file for storing individual run results
tmpfile=$(mktemp)

# Header for results
echo "# Lambda Delay_Avg CI_Lower CI_Upper" > $resfile

for lambda in 5 10 15 20 25 28 30 31 32 33 34 35; do
  >$tmpfile # Clear temporary file for this lambda
  
  for seed in "${seeds[@]}"; do
    echo "Running simulations for seed $seed and lambda $lambda"
    ns lab1.tcl $lambda $seed 
    echo -n "Analyzing ... "
    # Process with analyze1.awk and extract the 7th field for delay
    awk -f analyze1.awk /tmp/out.tr | awk '{print $7}' >> $tmpfile
    echo "Done."
  done
  
  # Calculate average delay and confidence interval from $tmpfile
  awk '{sum+=$1; sumsq+=$1*$1} END {mean=sum/NR; variance=sumsq/NR-mean*mean;
  
  stddev=sqrt(variance); ci=1.96*stddev/sqrt(NR); 
  
  printf "%f %f %f\n", mean, mean-ci, mean+ci}' 
  
  $tmpfile >> $resfile
  
  echo "Results summary for lambda $lambda:"
  tail -1 $resfile 
  echo " "
done

rm $tmpfile # Clean up temporary file

printf "\n\n\tDone\n"

printf "\n\tThe results are in $resfile\n\n"
