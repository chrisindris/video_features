#!/bin/bash
# This script is to run the program one video at a time automatically, and ensure that each folder has only one videos.
#

IFS=$'\n'
set -f

for ARGUMENT in "$@"; do
	KEY=$(echo $ARGUMENT | cut -f1 -d=)

	KEY_LENGTH=${#KEY}
	VALUE="${ARGUMENT:$KEY_LENGTH+1}"

	export "$KEY"="$VALUE"
done

actionformer_subset="/data/i5O/THUMOS14/actionformer_subset/"

# -------------------------------------------------

# build lst
lst="["

count=0
for vid in $(find $actionformer_subset -name "*video*"); do

  # ensure that there is at least 20GB of data left
  if [ $(expr $(df -B1 /data/ | awk 'NR==2 {print $4}') / 1000000000) -gt 10 ]; then

	unset IFS
	set +f
 
  if [[ $count -ne 0 ]]; then
    lst="$lst, $vid"
  else
    lst="${lst}${vid}"
  fi

  count=$(expr $count + 1)

  IFS=$'\n'
	set -f

  fi

done

lst="$lst]"

# run the script
python ./main.py \
  feature_type=i3d \
  device="cuda:1" \
  streams=flow \
  flow_type=raft \
  video_paths=$lst \
  stack_size=16 \
  step_size=4 \
  output_path="/root/models/video_features/output_video-features_thumos_i3d_flow/" \
  on_extraction="save_numpy"



unset IFS
set +f
