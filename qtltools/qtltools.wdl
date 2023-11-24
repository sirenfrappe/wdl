workflow nominal{
  # run nominal pass
  call nominal_pass
}

task nominal_pass{
   
   # files
   File vcf_file
   File bed_file
   File cov_file
   File qtltools_path
   String out_name


  command{
    mkdir -p input_bed_for_nominal
    cp ${bed_file} input_bed_for_nominal/
    cd input_bed_for_nominal/
    bgzip -f ./*
    tabix -p bed ./*
    cd ../
    bed_dir=$(realpath input_bed_for_nominal)
    echo ${qtltools_path}
    echo ${vcf_file}
    echo "$bed_dir"
    echo ${cov_file}
    echo ${out_name}
    mkdir -p cis
    # cis
    singularity exec --bind ${vcf_file}:/vcf_filepath --bind "$bed_dir":/bed_filepath --bind ${cov_file}:/cov_filepath --bind $(realpath cis):/cis_out_dir \
      --containall \
      ${qtltools_path} /qtltools/bin/QTLtools cis \
      --normal \
      --bed /bed_filepath/$(basename ${bed_file}).gz \
      --vcf /vcf_filepath \
      --cov /cov_filepath \
      --nominal 1 \
      --out /cis_out_dir/${out_name}.txt \
      --std-err \
      --seed 618

  mkdir -p permutation
  # permutation 
  singularity exec --bind ${vcf_file}:/vcf_filepath --bind "$bed_dir":/bed_filepath --bind ${cov_file}:/cov_filepath --bind $(realpath permutation):/permutation_out_dir \
      --containall \
      ${qtltools_path} /qtltools/bin/QTLtools cis \
      --bed /bed_filepath/$(basename ${bed_file}).gz \
      --vcf /vcf_filepath \
      --cov /cov_filepath \
      --permute 1000 \
      --normal \
      --out /permutation_out_dir/${out_name}.txt \
      --seed 618

  # fdr
  mkdir -p fdr
  singularity exec --bind $(realpath permutation):/permutation_out_dir --bind $(realpath fdr):/fdr_out_dir \
      --containall \
      ${qtltools_path} Rscript /qtltools/scripts/qtltools_runFDR_cis.R /permutation_out_dir/${out_name}.txt 0.05 /fdr_out_dir/${out_name}
  }

  output{
    File nominal_mapping_res = "cis/${out_name}.txt"
    File permutation_res = "permutation/${out_name}.txt"
    File fdr_res_1 = "fdr/${out_name}.significant.txt"
    File fdr_res_2 = "fdr/${out_name}.thresholds.txt"
  }
}