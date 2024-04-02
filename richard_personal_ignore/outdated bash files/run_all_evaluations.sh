#!/bin/bash

models=(
  "hf/meta-llama/Llama-2-70b-hf"
  # "hf/togethercomputer/RedPajama-INCITE-7B-Instruct"
  # "hf/tiiuae/falcon-7b-instruct"
  # "hf/lmsys/vicuna-7b-v1.3"
  # "hf/chavinlo/alpaca-native"
  # "openai/gpt-3.5-turbo-0301"
  # "openai/gpt-4-0314"
)

for model in "${models[@]}"
do
  output_file="output_${model//[\/]/_}.txt"
  
  echo "Running evaluations for model: $model" | tee -a "$output_file"

  # TOXICITY WORKING
  # ADV WORKING -- needed to pip install --upgrade datasets

  dt-run ++model_config.model=$model $model_config.conv_template="" ++dry_run=False +stereotype=benign ++stereotype.n_gens=25 ++stereotype.skip_generation=False

  dt-run +toxicity=realtoxicityprompts-toxic  \
    ++model=$model \
    ++toxicity.n=25 \
    ++toxicity.template=1
  
  # Toxicity
  dt-run ++model_config.model=$model ++model_config.conv_template +toxicity=realtoxicityprompts-nontoxic | tee -a "$output_file"

  # Stereotype and bias
  # dt-run +privacy=email_extraction_context50 ++dry_run=True ++model_config.key="" ++model_config.model=$model  | tee -a "$output_file"

  # OOD
  # dt-run +ood=style ++dry_run=True \
  #   ++model=$model \
  #   ++ood.out_file=data/ood/results/gpt-3.5-turbo-0301/style.json

  # Machine ethics
  dt-run +ood=style \
    ++model=$model \
    ++oods.out_file=data/ood/results/gpt-3.5-turbo-0301/style.json 
  
  # Fairness

  # Adv glue
  # dt-run +advglue=alpaca ++dry_run=True \
  #   ++model=$model \
  #   ++advglue.data_file=data/adv-glue-plus-plus/data/alpaca.json
  #   ++advglue.out_file=hi.txt

  # Adv demonstration
  dt-run +adv_demonstration=counterfactual_control_raising ++model=$model adv_demonstration.zero=True

  # dt-run +adv_demonstration=backdoor_exp1_badword_setup1 ++model=$model

  # dt-run +machine_ethics=jiminy_conditional_minor_harm ++dry_run=True \
    # ++model=$model

  # Harmfulness
  
  
#   # Adversarial robustness
#   dt-run +model_config.model=$model \
#          +advglue=data_file:./data/adv-glue-plus-plus/data/alpaca.json \
#          +advglue=out_file:./data/adv-glue-plus-plus/results/alpaca.json \
#          +advglue=task:["sst2","qqp","mnli"] | tee -a "$output_file"
  
#   # Out-of-Distribution Robustness
#   dt-run +model_config.model=$model \
#          +ood=data_file:./data/ood/knowledge/knowledge.json \
#          +ood=out_file:./data/ood/generations/knowledge/"${model//[\/]/_}"_knowledge.json \
#          +ood=task:knowledge | tee -a "$output_file"
  
#   dt-run +model_config.model=$model \
#          +ood=data_file:./data/ood/styles/style.json \
#          +ood=out_file:./data/ood/generations/styles/"${model//[\/]/_}"_style.json \
#          +ood=task:style | tee -a "$output_file"
  
#   # Privacy
#   dt-run +model_config.model=$model \
#          +privacy=scenario_name:enron \
#          +privacy=data_file:./data/privacy/enron_data \
#          +privacy=out_file:./data/privacy/generations/enron/"${model//[\/]/_}"_enron.json | tee -a "$output_file"
  
#   # Robustness to Adversarial Demonstrations
#   dt-run +model_config.model=$model \
#          +adv_demonstration=path:./data/adv_demonstration/ \
#          +adv_demonstration=task:backdoor | tee -a "$output_file"
  
#   # Machine Ethics
#   dt-run +model_config.model=$model \
#          +machine_ethics=data_name:ethics/commonsense \
#          +machine_ethics=test_data_file:./data/machine_ethics/jiminy_test.json \
#          +machine_ethics=train_data_file:./data/machine_ethics/jiminy_train.json \
#          +machine_ethics=out_file:./data/machine_ethics/generations/"${model//[\/]/_}"_commonsense.json | tee -a "$output_file"
  
#   # Fairness
#   dt-run +model_config.model=$model \
#          +fairness=data_dir:./data/fairness/fairness_data/ \
#          +fairness=prompt_file:./data/fairness/data_generation/adult_32_200.jsonl \
#          +fairness=gt_file:./data/fairness/fairness_data/gt_labels_adult_32_200.npy \
#          +fairness=sensitive_attr_file:./data/fairness/fairness_data/sensitive_attr_adult_32_200.npy \
#          +fairness=out_file:./data/fairness/generations/"${model//[\/]/_}"_adult_32_200.jsonl | tee -a "$output_file"
  
  # echo "Finished evaluations for model: $model" | tee -a "$output_file"
  # echo "------------------------------------" | tee -a "$output_file"
done