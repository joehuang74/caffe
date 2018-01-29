#!/bin/bash
# Create annotation files for each of the images and corresponding list

bash_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
data_root_dir=$HOME/data/n5_tunnel_extracted_images_v2.1
data_sub_dirs="nfbCCTV-N5-N-10.8-M nfbCCTV-N5-N-16.9157-M nfbCCTV-N5-N-19.3544-M nfbCCTV-N5-N-21.0597-M nfbCCTV-N5-N-22.5147-M nfbCCTV-N5-S-18.2993-M nfbCCTV-N5-S-19.7003-M nfbCCTV-N5-S-23.1961-M nfbCCTV-N5-S-26.6923-M"
output_anno_list=${bash_dir}/alldata.txt
output_anno_trainval_list=${bash_dir}/trainval.txt
output_anno_test_list=${bash_dir}/test.txt
output_test_name_size_file=${bash_dir}/test_name_size.txt

echo "data_root_dir: $data_root_dir"
echo "bash_dir: $bash_dir"
echo "output_anno_list: ${output_anno_list}"
echo "output_anno_trainval_list: ${output_anno_trainval_list}"
echo "output_anno_test_list: ${output_anno_test_list}"

if [ ! -d ${data_root_dir} ]; then
	echo "[ERROR] data_root_dir: ${data_root_dir} does NOT exist."
	exit 1
fi

if [ -f ${output_anno_list} ]; then
	echo "rm -f ${output_anno_list} ${output_anno_trainval_list} ${output_anno_test_list}"
	rm -f ${output_anno_list} ${output_anno_trainval_list} ${output_anno_test_list}
fi

cd $data_root_dir
for sub_dir in $data_sub_dirs
do
	echo "### Processing for image sub_dir: $sub_dir"
	input_image_dir=${data_root_dir}/${sub_dir}
	echo " input_image_dir: ${input_image_dir}"
	if [ ! -d ${input_image_dir} ]; then
		echo "[ERROR] ${input_image_dir} does NOT exist."
		exit 1
	fi

	input_anno_dir=${input_image_dir}_xml
	echo "input_anno_dir: $input_anno_dir"
	if [ ! -d ${input_anno_dir} ]; then
		echo "[ERROR] ${input_anno_dir} does NOT exist."
		exit 1
	fi

        for image_file in `ls -v ${sub_dir}/*.jpg`
        do
                anno_file=`basename ${input_anno_dir}`/`basename ${image_file} | sed 's/.jpg/.xml/g'`
                echo "${image_file} ${anno_file}" >> ${output_anno_list}
        done
	
done

# Split file list to trainval and test set
grep -v ^nfbCCTV-N5-S-18.2993-M ${output_anno_list} > ${output_anno_trainval_list}
grep ^nfbCCTV-N5-S-18.2993-M ${output_anno_list} > ${output_anno_test_list}
echo "### ${output_anno_trainval_list} and ${output_anno_test_list} has been created."

# Shuffle trainval annotation list
rand_file=${output_anno_trainval_list}.random
cat ${output_anno_trainval_list} | perl -MList::Util=shuffle -e 'srand 123; print shuffle(<STDIN>);' > $rand_file
mv $rand_file ${output_anno_trainval_list}

# Generate image name and size infomation for the test annotation list
$bash_dir/../../build/tools/get_image_size $data_root_dir ${output_anno_test_list} ${output_test_name_size_file}
echo "### ${output_test_name_size_file} has been created."

