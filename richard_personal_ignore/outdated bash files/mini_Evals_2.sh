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
  # "llama-2-70b-chat:2"
  "llama-2-13b-chat:1"
  # "llama-2-7b-chat:1"
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
  

  # STEREOTYPE EVALUATIONS -- running?

  sbatch <<EOF
#!/bin/bash
#SBATCH --time=24:00:00
#SBATCH --job-name=${model//[\/]/_}_stereo_1
#SBATCH --output=${output_dir}/${model//[\/]/_}_stereo_1_%j.txt
#SBATCH --nodes=1
#SBATCH --gpus-per-node=$gpus_per_node
#SBATCH --partition=cais
dt-run +model_config=$model ++dry_run=False +stereotype=benign ++stereotype.n_gens=25 ++stereotype.skip_generation=False
EOF

  sbatch <<EOF
#!/bin/bash
#SBATCH --time=24:00:00
#SBATCH --job-name=${model//[\/]/_}_stereo_2
#SBATCH --output=${output_dir}/${model//[\/]/_}_stereo_2_%j.txt
#SBATCH --nodes=1
#SBATCH --gpus-per-node=$gpus_per_node
#SBATCH --partition=cais
dt-run +model_config=$model ++dry_run=False +stereotype=untargeted ++stereotype.n_gens=25 ++stereotype.skip_generation=False
EOF

  sbatch <<EOF
#!/bin/bash
#SBATCH --time=24:00:00
#SBATCH --job-name=${model//[\/]/_}_stereo_3
#SBATCH --output=${output_dir}/${model//[\/]/_}_stereo_3_%j.txt
#SBATCH --nodes=1
#SBATCH --gpus-per-node=$gpus_per_node
#SBATCH --partition=cais
dt-run +model_config=$model ++dry_run=False +stereotype=targeted ++stereotype.n_gens=25 ++stereotype.skip_generation=False
EOF

#   # PRIVACY EVALUATIONS -- running?

#   sbatch <<EOF
# #!/bin/bash
# #SBATCH --time=24:00:00
# #SBATCH --job-name=${model//[\/]/_}_priv_1
# #SBATCH --output=${output_dir}/${model//[\/]/_}_priv_1_%j.txt
# #SBATCH --nodes=1
# #SBATCH --gpus-per-node=$gpus_per_node
# #SBATCH --partition=cais
# dt-run +privacy=email_extraction_context50  +model_config=$model
# dt-run +privacy=email_extraction_context100  +model_config=$model
# dt-run +privacy=email_extraction_context200  +model_config=$model
# EOF

#   sbatch <<EOF
# #!/bin/bash
# #SBATCH --time=24:00:00
# #SBATCH --job-name=${model//[\/]/_}_priv_2
# #SBATCH --output=${output_dir}/${model//[\/]/_}_priv_2_%j.txt
# #SBATCH --nodes=1
# #SBATCH --gpus-per-node=$gpus_per_node
# #SBATCH --partition=cais
# dt-run +privacy=email_extraction_known_zeroshot_a  +model_config=$model
# dt-run +privacy=email_extraction_known_zeroshot_b  +model_config=$model
# dt-run +privacy=email_extraction_known_zeroshot_c  +model_config=$model
# dt-run +privacy=email_extraction_known_zeroshot_d  +model_config=$model
# EOF

#   sbatch <<EOF
# #!/bin/bash
# #SBATCH --time=24:00:00
# #SBATCH --job-name=${model//[\/]/_}_priv_3
# #SBATCH --output=${output_dir}/${model//[\/]/_}_priv_3_%j.txt
# #SBATCH --nodes=1
# #SBATCH --gpus-per-node=$gpus_per_node
# #SBATCH --partition=cais
# dt-run +privacy=email_extraction_known_oneshot_a  +model_config=$model
# dt-run +privacy=email_extraction_known_oneshot_b  +model_config=$model
# dt-run +privacy=email_extraction_known_oneshot_c  +model_config=$model
# dt-run +privacy=email_extraction_known_oneshot_d  +model_config=$model
# EOF

#   sbatch <<EOF
# #!/bin/bash
# #SBATCH --time=24:00:00
# #SBATCH --job-name=${model//[\/]/_}_priv_4
# #SBATCH --output=${output_dir}/${model//[\/]/_}_priv_4_%j.txt
# #SBATCH --nodes=1
# #SBATCH --gpus-per-node=$gpus_per_node
# #SBATCH --partition=cais
# dt-run +privacy=email_extraction_known_fiveshot_a  +model_config=$model
# dt-run +privacy=email_extraction_known_fiveshot_b  +model_config=$model
# dt-run +privacy=email_extraction_known_fiveshot_c  +model_config=$model
# dt-run +privacy=email_extraction_known_fiveshot_d  +model_config=$model
# EOF

#   sbatch <<EOF
# #!/bin/bash
# #SBATCH --time=24:00:00
# #SBATCH --job-name=${model//[\/]/_}_priv_5
# #SBATCH --output=${output_dir}/${model//[\/]/_}_priv_5_%j.txt
# #SBATCH --nodes=1
# #SBATCH --gpus-per-node=$gpus_per_node
# #SBATCH --partition=cais
# dt-run +privacy=email_extraction_unknown_zeroshot_a  +model_config=$model
# dt-run +privacy=email_extraction_unknown_zeroshot_b  +model_config=$model
# dt-run +privacy=email_extraction_unknown_zeroshot_c  +model_config=$model
# dt-run +privacy=email_extraction_unknown_zeroshot_d  +model_config=$model
# EOF

#   sbatch <<EOF
# #!/bin/bash
# #SBATCH --time=24:00:00
# #SBATCH --job-name=${model//[\/]/_}_priv_6
# #SBATCH --output=${output_dir}/${model//[\/]/_}_priv_6_%j.txt
# #SBATCH --nodes=1
# #SBATCH --gpus-per-node=$gpus_per_node
# #SBATCH --partition=cais
# dt-run +privacy=email_extraction_unknown_oneshot_a  +model_config=$model
# dt-run +privacy=email_extraction_unknown_oneshot_b  +model_config=$model
# dt-run +privacy=email_extraction_unknown_oneshot_c  +model_config=$model
# dt-run +privacy=email_extraction_unknown_oneshot_d  +model_config=$model
# EOF

#   sbatch <<EOF
# #!/bin/bash
# #SBATCH --time=24:00:00
# #SBATCH --job-name=${model//[\/]/_}_priv_7
# #SBATCH --output=${output_dir}/${model//[\/]/_}_priv_7_%j.txt
# #SBATCH --nodes=1
# #SBATCH --gpus-per-node=$gpus_per_node
# #SBATCH --partition=cais
# dt-run +privacy=email_extraction_unknown_fiveshot_a  +model_config=$model
# dt-run +privacy=email_extraction_unknown_fiveshot_b  +model_config=$model
# dt-run +privacy=email_extraction_unknown_fiveshot_c  +model_config=$model
# dt-run +privacy=email_extraction_unknown_fiveshot_d  +model_config=$model
# EOF

#   sbatch <<EOF
# #!/bin/bash
# #SBATCH --time=24:00:00
# #SBATCH --job-name=${model//[\/]/_}_priv_8
# #SBATCH --output=${output_dir}/${model//[\/]/_}_priv_8_%j.txt
# #SBATCH --nodes=1
# #SBATCH --gpus-per-node=$gpus_per_node
# #SBATCH --partition=cais
# dt-run +privacy=pii_zeroshot  +model_config=$model
# dt-run +privacy=pii_fewshot_protect  +model_config=$model
# dt-run +privacy=pii_fewshot_attack  +model_config=$model
# EOF

#   sbatch <<EOF
# #!/bin/bash
# #SBATCH --time=24:00:00
# #SBATCH --job-name=${model//[\/]/_}_priv_9
# #SBATCH --output=${output_dir}/${model//[\/]/_}_priv_9_%j.txt
# #SBATCH --nodes=1
# #SBATCH --gpus-per-node=$gpus_per_node
# #SBATCH --partition=cais
# dt-run +privacy=understanding_q1  +model_config=$model
# dt-run +privacy=understanding_q2  +model_config=$model
# dt-run +privacy=understanding_q3  +model_config=$model
# EOF

# #   # OOD EVALUATIONS

#   sbatch <<EOF
# #!/bin/bash
# #SBATCH --time=24:00:00
# #SBATCH --job-name=${model//[\/]/_}_ood_1
# #SBATCH --output=${output_dir}/${model//[\/]/_}_ood_1_%j.txt
# #SBATCH --nodes=1
# #SBATCH --gpus-per-node=$gpus_per_node
# #SBATCH --partition=cais
# dt-run +ood=style \
#   +model_config=$model
# EOF

#   sbatch <<EOF
# #!/bin/bash
# #SBATCH --time=24:00:00
# #SBATCH --job-name=${model//[\/]/_}_ood_2
# #SBATCH --output=${output_dir}/${model//[\/]/_}_ood_2_%j.txt
# #SBATCH --nodes=1
# #SBATCH --gpus-per-node=$gpus_per_node
# #SBATCH --partition=cais
# dt-run +ood=knowledge_standard \
#   +model_config=$model
# EOF

#   sbatch <<EOF
# #!/bin/bash
# #SBATCH --time=24:00:00
# #SBATCH --job-name=${model//[\/]/_}_ood_3
# #SBATCH --output=${output_dir}/${model//[\/]/_}_ood_3_%j.txt
# #SBATCH --nodes=1
# #SBATCH --gpus-per-node=$gpus_per_node
# #SBATCH --partition=cais
# dt-run +ood=knowledge_idk \
#   +model_config=$model
# EOF

#   sbatch <<EOF
# #!/bin/bash
# #SBATCH --time=24:00:00
# #SBATCH --job-name=${model//[\/]/_}_ood_4
# #SBATCH --output=${output_dir}/${model//[\/]/_}_ood_4_%j.txt
# #SBATCH --nodes=1
# #SBATCH --gpus-per-node=$gpus_per_node
# #SBATCH --partition=cais
# dt-run +ood=style_8shot \
#   +model_config=$model
# EOF

#   sbatch <<EOF
# #!/bin/bash
# #SBATCH --time=24:00:00
# #SBATCH --job-name=${model//[\/]/_}_ood_5
# #SBATCH --output=${output_dir}/${model//[\/]/_}_ood_5_%j.txt
# #SBATCH --nodes=1
# #SBATCH --gpus-per-node=$gpus_per_node
# #SBATCH --partition=cais
# dt-run +ood=knowledge_2020_5shot \
#   +model_config=$model
# EOF



  # MACHINE ETHICS -- running?

#   sbatch <<EOF
# #!/bin/bash
# #SBATCH --time=24:00:00
# #SBATCH --job-name=${model//[\/]/_}_ethics_1
# #SBATCH --output=${output_dir}/${model//[\/]/_}_ethics_1_%j.txt
# #SBATCH --nodes=1
# #SBATCH --gpus-per-node=$gpus_per_node
# #SBATCH --partition=cais
# dt-run +machine_ethics=ethics_commonsense_short \
# +model_config=$model

# dt-run +machine_ethics=ethics_commonsense_short \
# +model_config=$model \
# ++machine_ethics.few_shot_num=32
# EOF

#   sbatch <<EOF
# #!/bin/bash
# #SBATCH --time=24:00:00
# #SBATCH --job-name=${model//[\/]/_}_ethics_2
# #SBATCH --output=${output_dir}/${model//[\/]/_}_ethics_2_%j.txt
# #SBATCH --nodes=1
# #SBATCH --gpus-per-node=$gpus_per_node
# #SBATCH --partition=cais
# dt-run +machine_ethics=ethics_commonsense_long \
# +model_config=$model

# dt-run +machine_ethics=ethics_commonsense_long \
# +model_config=$model \
# ++machine_ethics.few_shot_num=8
# EOF

#   sbatch <<EOF
# #!/bin/bash
# #SBATCH --time=24:00:00
# #SBATCH --job-name=${model//[\/]/_}_ethics_3
# #SBATCH --output=${output_dir}/${model//[\/]/_}_ethics_3_%j.txt
# #SBATCH --nodes=1
# #SBATCH --gpus-per-node=$gpus_per_node
# #SBATCH --partition=cais
# dt-run +machine_ethics=jiminy  \
# +model_config=$model

# dt-run +machine_ethics=jiminy  \
# +model_config=$model \
# ++machine_ethics.few_shot_num=3
# EOF

#   sbatch <<EOF
# #!/bin/bash
# #SBATCH --time=24:00:00
# #SBATCH --job-name=${model//[\/]/_}_ethics_4
# #SBATCH --output=${output_dir}/${model//[\/]/_}_ethics_4_%j.txt
# #SBATCH --nodes=1
# #SBATCH --gpus-per-node=$gpus_per_node
# #SBATCH --partition=cais
# for i in {1..5}; do
# dt-run +machine_ethics=ethics_commonsense_short  \
#     +model_config=$model \
#     ++machine_ethics.test_num=200 \
#     ++machine_ethics.jailbreak_prompt=\${i}
# done
# EOF

#   sbatch <<EOF
# #!/bin/bash
# #SBATCH --time=24:00:00
# #SBATCH --job-name=${model//[\/]/_}_ethics_5
# #SBATCH --output=${output_dir}/${model//[\/]/_}_ethics_5_%j.txt
# #SBATCH --nodes=1
# #SBATCH --gpus-per-node=$gpus_per_node
# #SBATCH --partition=cais
# for i in {1..5}; do
# dt-run +machine_ethics=jiminy  \
#     +model_config=$model \
#     ++machine_ethics.test_num=200 \
#     ++machine_ethics.jailbreak_prompt=\${i}
# done
# EOF

#   sbatch <<EOF
# #!/bin/bash
# #SBATCH --time=24:00:00
# #SBATCH --job-name=${model//[\/]/_}_ethics_6
# #SBATCH --output=${output_dir}/${model//[\/]/_}_ethics_6_%j.txt
# #SBATCH --nodes=1
# #SBATCH --gpus-per-node=$gpus_per_node
# #SBATCH --partition=cais
# dt-run +machine_ethics=jiminy_conditional_harm_self  \
# +model_config=$model

# dt-run +machine_ethics=jiminy_conditional_harm_others  \
# +model_config=$model

# dt-run +machine_ethics=jiminy_conditional_minor_harm  \
# +model_config=$model

# dt-run +machine_ethics=jiminy_conditional_moderate_harm  \
# +model_config=$model
# EOF


#     # ADVERSARIAL DEMONSTRATIONS

#   sbatch <<EOF
# #!/bin/bash
# #SBATCH --time=24:00:00
# #SBATCH --job-name=${model//[\/]/_}_advdem_1
# #SBATCH --output=${output_dir}/${model//[\/]/_}_advdem_1_%j.txt
# #SBATCH --nodes=1
# #SBATCH --gpus-per-node=$gpus_per_node
# #SBATCH --partition=cais

# datasets=("snli_premise" "snli_hypothesis" "control_raising" "irregular_form" "main_verb" "syntactic_category")
# seeds=(42 2333 10007)

# for dataset in "\${datasets[@]}"
# do
#   for seed in "\${seeds[@]}"
#   do
#     dt-run +adv_demonstration=counterfactual_\${dataset}_cf +model_config=$model +seed=\$seed
#     dt-run +adv_demonstration=counterfactual_\${dataset} +model_config=$model +seed=\$seed
#     dt-run +adv_demonstration=counterfactual_\${dataset}_cf +model_config=$model adv_demonstration.only=True +seed=\$seed
#     dt-run +adv_demonstration=counterfactual_\${dataset} +model_config=$model adv_demonstration.only=True +seed=\$seed
#   done
# done
# EOF

#   sbatch <<EOF
# #!/bin/bash
# #SBATCH --time=24:00:00
# #SBATCH --job-name=${model//[\/]/_}_advdem_2
# #SBATCH --output=${output_dir}/${model//[\/]/_}_advdem_2_%j.txt
# #SBATCH --nodes=1
# #SBATCH --gpus-per-node=$gpus_per_node
# #SBATCH --partition=cais
# heuristics=("PP" "adverb" "embedded_under_verb" "l_relative_clause" "passive" "s_relative_clause")
# seeds=(0 42 2333 10007 12306)

# for heuristic in "\${heuristics[@]}"
# do
#   for seed in "\${seeds[@]}"
#   do
#     dt-run +adv_demonstration=spurious_\${heuristic}_zero +model_config=$model +seed=\$seed
#     dt-run +adv_demonstration=spurious_\${heuristic}_entail-bias +model_config=$model +seed=\$seed
#     dt-run +adv_demonstration=spurious_\${heuristic}_non-entail-bias +model_config=$model +seed=\$seed
#   done 
# done
# EOF

#   sbatch <<EOF
# #!/bin/bash
# #SBATCH --time=24:00:00
# #SBATCH --job-name=${model//[\/]/_}_advdem_3
# #SBATCH --output=${output_dir}/${model//[\/]/_}_advdem_3_%j.txt
# #SBATCH --nodes=1
# #SBATCH --gpus-per-node=$gpus_per_node
# #SBATCH --partition=cais
# methods=("badword" "addsent" "synbkd" "stylebkd") 
# setups=("setup1" "setup2" "setup3")
# seeds=(42 2333 10007)

# for method in "\${methods[@]}"
# do
#   for setup in "\${setups[@]}"
#   do
#     for seed in "\${seeds[@]}"
#     do
#       dt-run +adv_demonstration=backdoor_exp1_\${method}_\${setup} +model_config=$model +seed=\$seed
#     done
#   done
# done
# EOF

#   sbatch <<EOF
# #!/bin/bash
# #SBATCH --time=24:00:00
# #SBATCH --job-name=${model//[\/]/_}_advdem_4
# #SBATCH --output=${output_dir}/${model//[\/]/_}_advdem_4_%j.txt
# #SBATCH --nodes=1
# #SBATCH --gpus-per-node=$gpus_per_node
# #SBATCH --partition=cais
# seeds=(42 2333 10007)
# for seed in "\${seeds[@]}"
# do
#   dt-run +adv_demonstration=backdoor adv_demonstration.path=./data/adv_demonstration/backdoor/experiment2/sst-2_setup2_badword_1 +model_config=$model +seed=\$seed
#   dt-run +adv_demonstration=backdoor adv_demonstration.path=./data/adv_demonstration/backdoor/experiment2/sst-2_setup2_badword_0 +model_config=$model +seed=\$seed
# done
# EOF

#   sbatch <<EOF
# #!/bin/bash
# #SBATCH --time=24:00:00
# #SBATCH --job-name=${model//[\/]/_}_advdem_5
# #SBATCH --output=${output_dir}/${model//[\/]/_}_advdem_5_%j.txt
# #SBATCH --nodes=1
# #SBATCH --gpus-per-node=$gpus_per_node
# #SBATCH --partition=cais
# setups=("setup2" "setup3") 
# locations=("first" "end" "middle")
# seeds=(42 2333 10007)

# for setup in "\${setups[@]}"
# do
#   for location in "\${locations[@]}"
#   do
#     for seed in "\${seeds[@]}"
#     do  
#       dt-run +adv_demonstration=backdoor adv_demonstration.path=./data/adv_demonstration/backdoor/experiment3/\${setup}_cf_\${location} +model_config=$model +seed=\$seed
#     done
#   done
# done
# EOF

#   sbatch <<EOF
# #!/bin/bash
# #SBATCH --time=24:00:00
# #SBATCH --job-name=${model//[\/]/_}_advdem_6
# #SBATCH --output=${output_dir}/${model//[\/]/_}_advdem_6_%j.txt
# #SBATCH --nodes=1
# #SBATCH --gpus-per-node=$gpus_per_node
# #SBATCH --partition=cais
# seeds=(42 2333 10007)
# for seed in "\${seeds[@]}"
# do
#   dt-run +adv_demonstration=backdoor_exp1_badword_setup1 +model_config=$model adv_demonstration.task=badword +seed=\$seed
# done
# EOF

#   # ADVGLUE

  sbatch <<EOF
#!/bin/bash
#SBATCH --time=24:00:00
#SBATCH --job-name=${model//[\/]/_}_advglue_1
#SBATCH --output=${output_dir}/${model//[\/]/_}_advglue_1_%j.txt
#SBATCH --nodes=1
#SBATCH --gpus-per-node=$gpus_per_node
#SBATCH --partition=cais

dt-run +advglue=alpaca  \
+model_config=$model
EOF

  sbatch <<EOF
#!/bin/bash
#SBATCH --time=24:00:00
#SBATCH --job-name=${model//[\/]/_}_advglue_2
#SBATCH --output=${output_dir}/${model//[\/]/_}_advglue_2_%j.txt
#SBATCH --nodes=1
#SBATCH --gpus-per-node=$gpus_per_node
#SBATCH --partition=cais
dt-run +advglue=stable-vicuna  \
+model_config=$model
EOF

  sbatch <<EOF
#!/bin/bash
#SBATCH --time=24:00:00
#SBATCH --job-name=${model//[\/]/_}_advglue_3
#SBATCH --output=${output_dir}/${model//[\/]/_}_advglue_3_%j.txt
#SBATCH --nodes=1
#SBATCH --gpus-per-node=$gpus_per_node
#SBATCH --partition=cais
dt-run +advglue=vicuna  \
+model_config=$model
EOF

  sbatch <<EOF
#!/bin/bash
#SBATCH --time=24:00:00
#SBATCH --job-name=${model//[\/]/_}_advglue_4
#SBATCH --output=${output_dir}/${model//[\/]/_}_advglue_4_%j.txt
#SBATCH --nodes=1
#SBATCH --gpus-per-node=$gpus_per_node
#SBATCH --partition=cais
dt-run +advglue=benign  \
+model_config=$model
EOF

 echo "Finished evaluations for model: $model with chat template: $gpus_per_node"
 echo "------------------------------------"
done

