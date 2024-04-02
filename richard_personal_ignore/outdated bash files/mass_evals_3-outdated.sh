#!/bin/bash

# Define the list of models and their associated chat templates
models=(
  "microsoft/phi-2:Robin"
  "microsoft/phi-1_5:Robin"
  "google/gemma-7b:Robin"
  "google/gemma-2b:Robin"
  "meta-llama/Llama-2-70b-hf:Robin"
  "meta-llama/Llama-2-13b-hf:Robin"
  "meta-llama/Llama-2-7b-hf:Robin"
  "01-ai/Yi-34B:Robin"
  "EleutherAI/gpt-j-6b:Robin"
  "EleutherAI/gpt-neox-20b:Robin"
  "EleutherAI/gpt-neo-1.3B:Robin"
  "EleutherAI/gpt-neo-2.7B:Robin"
  "EleutherAI/gpt-neo-125m:Robin"
  "EleutherAI/pythia-12b-deduped:Robin"
  "EleutherAI/pythia-6.9b-deduped:Robin"
  "EleutherAI/pythia-2.8b-deduped:Robin"
  "openai-community/gpt2:Robin"
  "mistralai/Mixtral-8x7B-Instruct-v0.1:mistral7b"
  "mistralai/Mistral-7B-Instruct-v0.2:mistral7b"
  "lmsys/vicuna-13b-v1.5:vicuna_v1.1"
  "lmsys/vicuna-33b-v1.3:vicuna_v1.1"
  "meta-llama/Llama-2-70b-chat-hf:llama-2"
  "meta-llama/Llama-2-13b-chat-hf:llama-2"
  "meta-llama/Llama-2-7b-chat-hf:llama-2"
  "google/gemma-7b-it:gemma"
  "google/gemma-2b-it:gemma"
)

for model_info in "${models[@]}"
do
  IFS=':' read -ra model_parts <<< "$model_info"
  model="${model_parts[0]}"
  chat_template="${model_parts[1]}"
  
  output_dir="outputs/${model//[\/]/_}"
  mkdir -p "$output_dir"
  
  # TOXICITY EVALUATIONS

  sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=tox_real_${model//[\/]/_}
#SBATCH --output=${output_dir}/tox_real_%j.txt

dt-run +toxicity=realtoxicityprompts-toxic \
  ++model=$model \
  ++model_config.conv_template=$chat_template \
  ++toxicity.n=25 \
  ++toxicity.template=1
EOF

  sbatch <<EOF
#!/bin/bash  
#SBATCH --job-name=tox_real_${model//[\/]/_}
#SBATCH --output=${output_dir}/tox_real_%j.txt

dt-run +toxicity=realtoxicityprompts-toxic \
  ++model=$model \
  ++model_config.conv_template=$chat_template \
  ++toxicity.n=25 \
  ++toxicity.template=1
EOF

  for i in {0..32}; do
    sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=tox_real_${model//[\/]/_}_${i}
#SBATCH --output=${output_dir}/tox_real_${i}_%j.txt

dt-run +toxicity=realtoxicityprompts-toxic \
  ++model=$model \
  ++model_config.conv_template=$chat_template \
  ++toxicity.n=1 \
  ++toxicity.template=${i} \
  ++toxicity.t=0
EOF
  done

  sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=tox_gpt4_${model//[\/]/_}
#SBATCH --output=${output_dir}/tox_gpt4_%j.txt

dt-run +toxicity=toxic-gpt4 \
  ++model=$model \
  ++model_config.conv_template=$chat_template \
  ++toxicity.n=25 \
  ++toxicity.template=1
EOF

  # STEREOTYPE EVALUATIONS

  sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=stereo_benign_${model//[\/]/_}
#SBATCH --output=${output_dir}/stereo_benign_%j.txt

dt-run ++model_config.model=$model ++model_config.conv_template=$chat_template ++dry_run=False +stereotype=benign ++stereotype.n_gens=25 ++stereotype.skip_generation=False
EOF

  sbatch <<EOF
#!/bin/bash  
#SBATCH --job-name=stereo_untargeted_${model//[\/]/_}
#SBATCH --output=${output_dir}/stereo_untargeted_%j.txt

dt-run ++model_config.model=$model ++model_config.conv_template=$chat_template ++dry_run=False +stereotype=untargeted ++stereotype.n_gens=25 ++stereotype.skip_generation=False
EOF

  sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=stereo_targeted_${model//[\/]/_}  
#SBATCH --output=${output_dir}/stereo_targeted_%j.txt

dt-run ++model_config.model=$model ++model_config.conv_template=$chat_template ++dry_run=False +stereotype=targeted ++stereotype.n_gens=25 ++stereotype.skip_generation=False
EOF

  # PRIVACY EVALUATIONS

  sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=priv_extract_50_${model//[\/]/_}
#SBATCH --output=${output_dir}/priv_extract_50_%j.txt

dt-run +privacy=email_extraction_context50 ++dry_run=True ++model_config.model=$model ++model_config.conv_template=$chat_template
EOF

  sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=priv_extract_100_${model//[\/]/_}  
#SBATCH --output=${output_dir}/priv_extract_100_%j.txt

dt-run +privacy=email_extraction_context100 ++dry_run=True ++model_config.model=$model ++model_config.conv_template=$chat_template
EOF

  sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=priv_extract_200_${model//[\/]/_}
#SBATCH --output=${output_dir}/priv_extract_200_%j.txt

dt-run +privacy=email_extraction_context200 ++dry_run=True ++model_config.model=$model ++model_config.conv_template=$chat_template
EOF

  sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=priv_known_zero_a_${model//[\/]/_}
#SBATCH --output=${output_dir}/priv_known_zero_a_%j.txt

dt-run +privacy=email_extraction_known_zeroshot_a ++dry_run=True ++model_config.model=$model ++model_config.conv_template=$chat_template
EOF

  sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=priv_known_zero_b_${model//[\/]/_}
#SBATCH --output=${output_dir}/priv_known_zero_b_%j.txt

dt-run +privacy=email_extraction_known_zeroshot_b ++dry_run=True ++model_config.model=$model ++model_config.conv_template=$chat_template
EOF

  sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=priv_known_zero_c_${model//[\/]/_}
#SBATCH --output=${output_dir}/priv_known_zero_c_%j.txt

dt-run +privacy=email_extraction_known_zeroshot_c ++dry_run=True ++model_config.model=$model ++model_config.conv_template=$chat_template
EOF

  sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=priv_known_zero_d_${model//[\/]/_}
#SBATCH --output=${output_dir}/priv_known_zero_d_%j.txt

dt-run +privacy=email_extraction_known_zeroshot_d ++dry_run=True ++model_config.model=$model ++model_config.conv_template=$chat_template
EOF

  sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=priv_known_one_a_${model//[\/]/_}
#SBATCH --output=${output_dir}/priv_known_one_a_%j.txt

dt-run +privacy=email_extraction_known_oneshot_a ++dry_run=True ++model_config.model=$model ++model_config.conv_template=$chat_template
EOF

  sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=priv_known_one_b_${model//[\/]/_}  
#SBATCH --output=${output_dir}/priv_known_one_b_%j.txt

dt-run +privacy=email_extraction_known_oneshot_b ++dry_run=True ++model_config.model=$model ++model_config.conv_template=$chat_template
EOF

  sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=priv_known_one_c_${model//[\/]/_}
#SBATCH --output=${output_dir}/priv_known_one_c_%j.txt

dt-run +privacy=email_extraction_known_oneshot_c ++dry_run=True ++model_config.model=$model ++model_config.conv_template=$chat_template
EOF

  sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=priv_known_one_d_${model//[\/]/_}
#SBATCH --output=${output_dir}/priv_known_one_d_%j.txt

dt-run +privacy=email_extraction_known_oneshot_d ++dry_run=True ++model_config.model=$model ++model_config.conv_template=$chat_template
EOF

  sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=priv_known_five_a_${model//[\/]/_}
#SBATCH --output=${output_dir}/priv_known_five_a_%j.txt

dt-run +privacy=email_extraction_known_fiveshot_a ++dry_run=True ++model_config.model=$model ++model_config.conv_template=$chat_template
EOF

  sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=priv_known_five_b_${model//[\/]/_}
#SBATCH --output=${output_dir}/priv_known_five_b_%j.txt

dt-run +privacy=email_extraction_known_fiveshot_b ++dry_run=True ++model_config.model=$model ++model_config.conv_template=$chat_template
EOF

  sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=priv_known_five_c_${model//[\/]/_}
#SBATCH --output=${output_dir}/priv_known_five_c_%j.txt

dt-run +privacy=email_extraction_known_fiveshot_c ++dry_run=True ++model_config.model=$model ++model_config.conv_template=$chat_template
EOF

  sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=priv_known_five_d_${model//[\/]/_}
#SBATCH --output=${output_dir}/priv_known_five_d_%j.txt

dt-run +privacy=email_extraction_known_fiveshot_d ++dry_run=True ++model_config.model=$model ++model_config.conv_template=$chat_template
EOF

  sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=priv_unknown_zero_a_${model//[\/]/_}
#SBATCH --output=${output_dir}/priv_unknown_zero_a_%j.txt

dt-run +privacy=email_extraction_unknown_zeroshot_a ++dry_run=True ++model_config.model=$model ++model_config.conv_template=$chat_template
EOF

  sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=priv_unknown_zero_b_${model//[\/]/_}
#SBATCH --output=${output_dir}/priv_unknown_zero_b_%j.txt

dt-run +privacy=email_extraction_unknown_zeroshot_b ++dry_run=True ++model_config.model=$model ++model_config.conv_template=$chat_template
EOF

  sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=priv_unknown_zero_c_${model//[\/]/_}
#SBATCH --output=${output_dir}/priv_unknown_zero_c_%j.txt

dt-run +privacy=email_extraction_unknown_zeroshot_c ++dry_run=True ++model_config.model=$model ++model_config.conv_template=$chat_template
EOF

  sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=priv_unknown_zero_d_${model//[\/]/_}
#SBATCH --output=${output_dir}/priv_unknown_zero_d_%j.txt

dt-run +privacy=email_extraction_unknown_zeroshot_d ++dry_run=True ++model_config.model=$model ++model_config.conv_template=$chat_template
EOF

  sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=priv_unknown_one_a_${model//[\/]/_}
#SBATCH --output=${output_dir}/priv_unknown_one_a_%j.txt

dt-run +privacy=email_extraction_unknown_oneshot_a ++dry_run=True ++model_config.model=$model ++model_config.conv_template=$chat_template
EOF

  sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=priv_unknown_one_b_${model//[\/]/_}
#SBATCH --output=${output_dir}/priv_unknown_one_b_%j.txt

dt-run +privacy=email_extraction_unknown_oneshot_b ++dry_run=True ++model_config.model=$model ++model_config.conv_template=$chat_template
EOF

  sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=priv_unknown_one_c_${model//[\/]/_}
#SBATCH --output=${output_dir}/priv_unknown_one_c_%j.txt

dt-run +privacy=email_extraction_unknown_oneshot_c ++dry_run=True ++model_config.model=$model ++model_config.conv_template=$chat_template
EOF

  sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=priv_unknown_one_d_${model//[\/]/_}
#SBATCH --output=${output_dir}/priv_unknown_one_d_%j.txt

dt-run +privacy=email_extraction_unknown_oneshot_d ++dry_run=True ++model_config.model=$model ++model_config.conv_template=$chat_template
EOF

  sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=priv_unknown_five_a_${model//[\/]/_}
#SBATCH --output=${output_dir}/priv_unknown_five_a_%j.txt

dt-run +privacy=email_extraction_unknown_fiveshot_a ++dry_run=True ++model_config.model=$model ++model_config.conv_template=$chat_template
EOF

  sbatch <