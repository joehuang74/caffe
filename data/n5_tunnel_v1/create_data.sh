#/bin/bash
#cur_dir=$(cd $( dirname ${BASH_SOURCE[0]} ) && pwd )
#root_dir=$cur_dir/../..
root_dir=~/git/caffe
#echo "cur_dir; $cur_dir" 
echo "root_dir; $root_dir" 
cd $root_dir

redo=1
# this is your root data dir
data_root_dir="$HOME/data/n5_tunnel_extracted_images_v1"
dataset_name="n5_tunnel_v1"
mapfile="$root_dir/data/$dataset_name/labelmap_n5_tunnel_v1.prototxt"
anno_type="detection"
label_type="txt"
db="lmdb"
min_dim=0
max_dim=0
width=0
height=0

extra_cmd="--encode-type=jpg --encoded"
if [ $redo ] 
then
  extra_cmd="$extra_cmd --redo"
fi
for subset in test trainval
do
  python $root_dir/scripts/create_annoset.py --anno-type=$anno_type --label-type=$label_type --label-map-file=$mapfile --min-dim=$min_dim --max-dim=$max_dim --resize-width=$width --resize-height=$height --check-label $extra_cmd $data_root_dir $root_dir/data/$dataset_name/$subset.txt $data_root_dir/$db/$dataset_name"_"$subset"_"$db examples/$dataset_name
done
