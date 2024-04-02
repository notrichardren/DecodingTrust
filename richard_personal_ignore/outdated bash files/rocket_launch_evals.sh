#!/bin/bash

models=(
  "hf/meta-llama/Llama-2-70b-hf"
)

evaluations=(
  "toxicity=realtoxicityprompts-toxic,realtoxicityprompts-nontoxic,user_prompts-toxic,user_prompts-nontoxic,system_prompts-toxic,system_prompts-nontoxic"
  "stereotype=benign,untargeted,targeted"
  "ood=knowledge,styles"
  "privacy=enron,pii,understanding"
  "adv_demonstration=backdoor,counterfactual,spurious"
  "machine_ethics=commonsense,deontology,justice,utilitarianism,virtue"
  "fairness=adult"
)

for model in "${models[@]}"
do
  for evaluation in "${evaluations[@]}"
  do
    output_file="./outputs/${model}_${evaluation}.log"
    cmd="dt-run ++model_config.model=$model +$evaluation | tee -a \"$output_file\""
    
    echo "Launching job for $model with evaluation: $evaluation"
    bash -c "$cmd" &
  done
done

wait