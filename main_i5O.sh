#!/bin/bash
# This script is to run the program one video at a time automatically, and ensure that each folder has only one videos.
#

#IFS=$'\n'
#set -f

for ARGUMENT in "$@"; do
        KEY=$(echo $ARGUMENT | cut -f1 -d=)

        KEY_LENGTH=${#KEY}
        VALUE="${ARGUMENT:$KEY_LENGTH+1}"

        export "$KEY"="$VALUE"
done

# default values
[[ $dataset_head ]] || dataset_head="/data/i5O/i5OData/"
[[ $dataset_side ]] || dataset_side="*" # undercover-left vs right
[[ $dataset_subset ]] || dataset_subset="*" # something like "videos"
[[ $start ]] || start=0 # starting index
[[ $end ]] || end=-0 # end index; -0 indicates to take all videos

# print the variable values
echo "dataset_head = $dataset_head"
echo "dataset_side = $dataset_side"
echo "dataset_subset = $dataset_subset"
echo "start = $start"
echo "end = $end"

# -------------------------------------------------

# build lst
lst="["

count=0

vid_list="$(find $dataset_head -type f -wholename "*/${dataset_side}/${dataset_subset}/*.mp4" | sort | head -n $end)"
#echo $vid_list
vid_list_len=$(echo $vid_list | wc -w)
#echo $vid_list_len
IFS=" "
set -f
vid_list=$(echo $vid_list | tail -n $(expr $vid_list_len - $start + 1))
echo $vid_list
IFS=$'\n'
set -f


for vid in $vid_list; do

  # ensure that there is at least 20GB of data left
  if [ $(expr $(df -B1 /data/ | awk 'NR==2 {print $4}') / 1000000000) -gt 10 ]; then

    echo $vid

          #unset IFS
          #set +f
 
    if [[ $count -ne 0 ]]; then
      lst="${lst}, ${vid}"
    else
      lst="${lst}${vid}"
    fi

    count=$(expr $count + 1)

    #IFS=$'\n'
          #set -f

  fi

done

lst="$lst]"

echo $lst

#unset IFS
#set +f

time python main.py \
  feature_type=r21d \
  model_name=r2plus1d_18_16_kinetics \
  stack_size=16 \
  step_size=4 \
  device="cuda:0" \
  video_paths=$lst \
  on_extraction=save_numpy \
  output_path=/data/i5O/i5OData/video_features/
