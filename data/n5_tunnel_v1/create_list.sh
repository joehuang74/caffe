#!/bin/bash
# Create annotation files for each of the images and corresponding list

bash_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
data_root_dir=$HOME/data/n5_tunnel_extracted_images_v1
data_sub_dirs="nfbCCTV-N5-S-0.254-M_LBMixtureOfGaussians nfbCCTV-N5-S-10.8-M_LBMixtureOfGaussians nfbCCTV-N5-S-16.8923-M_LBMixtureOfGaussians nfbCCTV-N5-S-18.2993-M_LBMixtureOfGaussians"
output_anno_list=${bash_dir}/alldata.txt
output_anno_trainval_list=${bash_dir}/trainval.txt
output_anno_test_list=${bash_dir}/test.txt

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
	input_anno_list=${input_image_dir}.xyminmax.txt
	if [ ! -f ${input_anno_list} ]; then
		echo "[ERROR] ${input_anno_list} does NOT exist."
		exit 1
	fi
	echo " input_anno_list: ${input_anno_list}"

	output_anno_dir=${input_image_dir}_Annotations
	echo "output_anno_dir: $output_anno_dir"
	if [ -d ${output_anno_dir} ]; then
		echo "rm -f ${output_anno_dir}/*.txt"
		rm -f ${output_anno_dir}/*.txt
	fi
	mkdir -p ${output_anno_dir}
	
	for image_file in `ls -v ${sub_dir}/*.jpg`
	do
		anno_file=`basename ${output_anno_dir}`/`basename ${image_file} | sed 's/.jpg/.txt/g'`
		echo "${image_file} ${anno_file}" >> ${output_anno_list}
		grep "`basename ${image_file}`" $input_anno_list | awk '{print $2 " " $3 " " $4 " " $5 " " $6}' | sed 's/vehicle/1/g' > ${anno_file}
	done
done

# Shuffle annotation list
rand_file=${output_anno_list}.random
cat ${output_anno_list} | perl -MList::Util=shuffle -e 'srand 123; print shuffle(<STDIN>);' > $rand_file
mv $rand_file ${output_anno_list}

# Split file list to trainval and test set
num_trainval_data=800
echo "num_trainval_data: $num_trainval_data"
split -l $num_trainval_data ${output_anno_list} ${output_anno_list}.
mv ${output_anno_list}.aa ${output_anno_trainval_list}
mv ${output_anno_list}.ab ${output_anno_test_list}

echo "${output_anno_trainval_list} and ${output_anno_test_list} has been created."

