#!/bin/bash

# Define the list of models and their associated chat templates
models=(
  # "hf/microsoft/phi-2:default:1"
  # "hf/microsoft/phi-1_5:default:1"
  # "hf/google/gemma-7b:default:1" # doesn't work
  # "hf/google/gemma-2b:default:1" # doesn't work
  # "hf/meta-llama/Llama-2-70b-hf:default:2"
  # "hf/meta-llama/Llama-2-13b-hf:default:1"
  # "hf/meta-llama/Llama-2-7b-hf:default:1"
  # "hf/01-ai/Yi-34B:default:1"
  # "hf/EleutherAI/gpt-j-6b:default:1"
  # "hf/EleutherAI/gpt-neox-20b:default:2"
  # "hf/EleutherAI/gpt-neo-1.3B:default:1"
  # "hf/EleutherAI/gpt-neo-2.7B:default:1"
  # "hf/EleutherAI/gpt-neo-125m:default:1"
  # "hf/EleutherAI/pythia-12b-deduped:default:1"
  # "hf/EleutherAI/pythia-6.9b-deduped:default:1"
  # "hf/EleutherAI/pythia-2.8b-deduped:default:1"
  # "hf/openai-community/gpt2:default:1"
  # "hf/mistralai/Mixtral-8x7B-Instruct-v0.1:mistral7b:1"
  # "hf/mistralai/Mistral-7B-Instruct-v0.2:mistral7b:1" # doesn't work
  # "hf/lmsys/vicuna-13b-v1.5:vicuna_v1.1:1"
  # "hf/lmsys/vicuna-33b-v1.3:vicuna_v1.1:2"
  "llama-2-70b-chat:2"
  "llama-2-13b-chat:1"
  "llama-2-7b-chat:1"
  # "hf/google/gemma-7b-it:gemma:1" # doesn't work
  # "hf/google/gemma-2b-it:gemma:1" # doesn't work
)

for model_info in "${models[@]}"
do
  IFS=':' read -ra model_parts <<< "$model_info"
  model="${model_parts[0]}"
  # chat_template="${model_parts[1]}"
  gpus_per_node="${model_parts[1]}"
  
  output_dir="outputs/${model//[\/]/_}"
  mkdir -p "$output_dir"
  
  # TOXICITY EVALUATIONS
  
  sbatch <<EOF
#!/bin/bash
#SBATCH --time=00:30:00
#SBATCH --job-name=${model//[\/]/_}_toxic_1
#SBATCH --output=${output_dir}/${model//[\/]/_}_toxic_1_%j.txt
#SBATCH --nodes=1
#SBATCH --gpus-per-node=$gpus_per_node
#SBATCH --partition=cais
dt-run +toxicity=realtoxicityprompts-toxic  \
+model_config=$model \
++toxicity.n=25 \
++toxicity.template=1
EOF

  # STEREOTYPE EVALUATIONS -- running?

  sbatch <<EOF
#!/bin/bash
#SBATCH --time=00:30:00
#SBATCH --job-name=${model//[\/]/_}_stereo_1
#SBATCH --output=${output_dir}/${model//[\/]/_}_stereo_1_%j.txt
#SBATCH --nodes=1
#SBATCH --gpus-per-node=$gpus_per_node
#SBATCH --partition=cais
dt-run +model_config=$model ++dry_run=False +stereotype=benign ++stereotype.n_gens=25 ++stereotype.skip_generation=False
EOF


  # PRIVACY EVALUATIONS -- running?

  sbatch <<EOF
#!/bin/bash
#SBATCH --time=00:30:00
#SBATCH --job-name=${model//[\/]/_}_priv_1
#SBATCH --output=${output_dir}/${model//[\/]/_}_priv_1_%j.txt
#SBATCH --nodes=1
#SBATCH --gpus-per-node=$gpus_per_node
#SBATCH --partition=cais
dt-run +privacy=email_extraction_context50  +model_config=$model
dt-run +privacy=email_extraction_context100  +model_config=$model
dt-run +privacy=email_extraction_context200  +model_config=$model
EOF

#   # OOD EVALUATIONS

  sbatch <<EOF
#!/bin/bash
#SBATCH --time=00:30:00
#SBATCH --job-name=${model//[\/]/_}_ood_1
#SBATCH --output=${output_dir}/${model//[\/]/_}_ood_1_%j.txt
#SBATCH --nodes=1
#SBATCH --gpus-per-node=$gpus_per_node
#SBATCH --partition=cais
dt-run +ood=style \
  +model_config=$model
EOF


  sbatch <<EOF
#!/bin/bash
#SBATCH --time=00:30:00
#SBATCH --job-name=${model//[\/]/_}_ethics_5
#SBATCH --output=${output_dir}/${model//[\/]/_}_ethics_5_%j.txt
#SBATCH --nodes=1
#SBATCH --gpus-per-node=$gpus_per_node
#SBATCH --partition=cais
for i in {1..5}; do
dt-run +machine_ethics=jiminy  \
    +model_config=$model \
    ++machine_ethics.test_num=200 \
    ++machine_ethics.jailbreak_prompt=${i}
done
EOF

  sbatch <<EOF
#!/bin/bash
#SBATCH --time=00:30:00
#SBATCH --job-name=${model//[\/]/_}_advdem_2
#SBATCH --output=${output_dir}/${model//[\/]/_}_advdem_2_%j.txt
#SBATCH --nodes=1
#SBATCH --gpus-per-node=$gpus_per_node
#SBATCH --partition=cais
heuristics=("PP" "adverb" "embedded_under_verb" "l_relative_clause" "passive" "s_relative_clause")
seeds=(0 42 2333 10007 12306)

for heuristic in "\${heuristics[@]}"
do
  for seed in "\${seeds[@]}"
  do
    dt-run +adv_demonstration=spurious_\${heuristic}_zero +model_config=$model +seed=\$seed
    dt-run +adv_demonstration=spurious_\${heuristic}_entail-bias +model_config=$model +seed=\$seed
    dt-run +adv_demonstration=spurious_\${heuristic}_non-entail-bias +model_config=$model +seed=\$seed
  done 
done
EOF


 echo "Finished evaluations for model: $model with chat template: $gpus_per_node"
 echo "------------------------------------"
done

