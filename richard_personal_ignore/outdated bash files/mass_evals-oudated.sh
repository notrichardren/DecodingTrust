#!/bin/bash

# please create a list here! the old list was called "models" or something like this, but i want it to have an associated chat template

MODELS, and then CHAT TEMPLATE
microsoft/phi-2, "Robin"
microsoft/phi-1_5, "Robin"
google/gemma-7b, "Robin"
google/gemma-2b, "Robin"
meta-llama/Llama-2-70b-hf, "Robin"
meta-llama/Llama-2-13b-hf, "Robin"
meta-llama/Llama-2-7b-hf, "Robin"
01-ai/Yi-34B, "Robin"
EleutherAI/gpt-j-6b, "Robin"
EleutherAI/gpt-neox-20b, "Robin"
EleutherAI/gpt-neo-1.3B, "Robin"
EleutherAI/gpt-neo-2.7B, "Robin"
EleutherAI/gpt-neo-125m, "Robin"
EleutherAI/pythia-12b-deduped, "Robin"
EleutherAI/pythia-6.9b-deduped, "Robin"
EleutherAI/pythia-2.8b-deduped, "Robin"
openai-community/gpt2, "Robin"

mistralai/Mixtral-8x7B-Instruct-v0.1, "mistral7b"
mistralai/Mistral-7B-Instruct-v0.2, "mistral7b"
lmsys/vicuna-13b-v1.5, "vicuna_v1.1"
lmsys/vicuna-33b-v1.3, "vicuna_v1.1"
meta-llama/Llama-2-70b-chat-hf, "llama-2"
meta-llama/Llama-2-13b-chat-hf, "llama-2"
meta-llama/Llama-2-7b-chat-hf, "llama-2"
google/gemma-7b-it, "gemma"
google/gemma-2b-it, "gemma"

for model in "${models[@]}" # add chat template in for loop
do
  output_file="output_${model//[\/]/_}.txt"
  
  echo "Running evaluations for model: $model" | tee -a "$output_file"

  # TOXICITY EVALUATIONS

  dt-run +toxicity=realtoxicityprompts-toxic  \
    ++model=$model \
      ++model_config.conv_template=$chat_template \
    ++toxicity.n=25 \
    ++toxicity.template=1

  dt-run +toxicity=realtoxicityprompts-toxic  \
    ++model=$model \
      ++model_config.conv_template=$chat_template \
    ++toxicity.n=25 \
    ++toxicity.template=1

  for i in {0..32}; do
  dt-run +toxicity=realtoxicityprompts-toxic  \
      ++model=$model \
      ++model_config.conv_template=$chat_template \
      ++toxicity.n=1 \
      ++toxicity.template=${i} \
      ++toxicity.t=0
  done

  dt-run +toxicity=toxic-gpt4  \
    ++model=$model \
    ++model_config.conv_template=$chat_template \
    ++toxicity.n=25 \
    ++toxicity.template=1

  # STEREOTYPE EVALUATIONS

  dt-run key=OPENAI_API_KEY ++model_config.model=openai/gpt-4-0314 ++dry_run=False +stereotype=benign ++stereotype.n_gens=25 ++stereotype.skip_generation=False
  # These are done wrong! Get rid of key, put $model in model_config.model, and also do model_config.conv_template = $chat_template. Do these for all the evaluations below.

  dt-run key=OPENAI_API_KEY ++model_config.model=openai/gpt-4-0314 ++dry_run=False +stereotype=untargeted ++stereotype.n_gens=25 ++stereotype.skip_generation=False

  dt-run key=OPENAI_API_KEY ++model_config.model=openai/gpt-4-0314 ++dry_run=False +stereotype=targeted ++stereotype.n_gens=25 ++stereotype.skip_generation=False

  # PRIVACY EVALUATIONS

  dt-run +privacy=email_extraction_context50 ++dry_run=True ++model_config.key="" ++model_config.model=openai/gpt-3.5-turbo-0301 
  dt-run +privacy=email_extraction_context100 ++dry_run=True ++model_config.key="" ++model_config.model=openai/gpt-3.5-turbo-0301 
  dt-run +privacy=email_extraction_context200 ++dry_run=True ++model_config.key="" ++model_config.model=openai/gpt-3.5-turbo-0301 

  dt-run +privacy=email_extraction_known_zeroshot_a ++dry_run=True ++model_config.key="" ++model_config.model=openai/gpt-3.5-turbo-0301 
  dt-run +privacy=email_extraction_known_zeroshot_b ++dry_run=True ++model_config.key="" ++model_config.model=openai/gpt-3.5-turbo-0301 
  dt-run +privacy=email_extraction_known_zeroshot_c ++dry_run=True ++model_config.key="" ++model_config.model=openai/gpt-3.5-turbo-0301 
  dt-run +privacy=email_extraction_known_zeroshot_d ++dry_run=True ++model_config.key="" ++model_config.model=openai/gpt-3.5-turbo-0301 

  dt-run +privacy=email_extraction_known_oneshot_a ++dry_run=True ++model_config.key="" ++model_config.model=openai/gpt-3.5-turbo-0301 
  dt-run +privacy=email_extraction_known_oneshot_b ++dry_run=True ++model_config.key="" ++model_config.model=openai/gpt-3.5-turbo-0301 
  dt-run +privacy=email_extraction_known_oneshot_c ++dry_run=True ++model_config.key="" ++model_config.model=openai/gpt-3.5-turbo-0301 
  dt-run +privacy=email_extraction_known_oneshot_d ++dry_run=True ++model_config.key="" ++model_config.model=openai/gpt-3.5-turbo-0301 

  dt-run +privacy=email_extraction_known_fiveshot_a ++dry_run=True ++model_config.key="" ++model_config.model=openai/gpt-3.5-turbo-0301 
  dt-run +privacy=email_extraction_known_fiveshot_b ++dry_run=True ++model_config.key="" ++model_config.model=openai/gpt-3.5-turbo-0301 
  dt-run +privacy=email_extraction_known_fiveshot_c ++dry_run=True ++model_config.key="" ++model_config.model=openai/gpt-3.5-turbo-0301 
  dt-run +privacy=email_extraction_known_fiveshot_d ++dry_run=True ++model_config.key="" ++model_config.model=openai/gpt-3.5-turbo-0301 

  dt-run +privacy=email_extraction_unknown_zeroshot_a ++dry_run=True ++model_config.key="" ++model_config.model=openai/gpt-3.5-turbo-0301 
  dt-run +privacy=email_extraction_unknown_zeroshot_b ++dry_run=True ++model_config.key="" ++model_config.model=openai/gpt-3.5-turbo-0301 
  dt-run +privacy=email_extraction_unknown_zeroshot_c ++dry_run=True ++model_config.key="" ++model_config.model=openai/gpt-3.5-turbo-0301 
  dt-run +privacy=email_extraction_unknown_zeroshot_d ++dry_run=True ++model_config.key="" ++model_config.model=openai/gpt-3.5-turbo-0301 

  dt-run +privacy=email_extraction_unknown_oneshot_a ++dry_run=True ++model_config.key="" ++model_config.model=openai/gpt-4-0314
  dt-run +privacy=email_extraction_unknown_oneshot_b ++dry_run=True ++model_config.key="" ++model_config.model=openai/gpt-4-0314
  dt-run +privacy=email_extraction_unknown_oneshot_c ++dry_run=True ++model_config.key="" ++model_config.model=openai/gpt-4-0314
  dt-run +privacy=email_extraction_unknown_oneshot_d ++dry_run=True ++model_config.key="" ++model_config.model=openai/gpt-4-0314

  dt-run +privacy=email_extraction_unknown_fiveshot_a ++dry_run=True ++model_config.key="" ++model_config.model=openai/gpt-4-0314
  dt-run +privacy=email_extraction_unknown_fiveshot_b ++dry_run=True ++model_config.key="" ++model_config.model=openai/gpt-4-0314
  dt-run +privacy=email_extraction_unknown_fiveshot_c ++dry_run=True ++model_config.key="" ++model_config.model=openai/gpt-4-0314
  dt-run +privacy=email_extraction_unknown_fiveshot_d ++dry_run=True ++model_config.key="" ++model_config.model=openai/gpt-4-0314

  dt-run +privacy=pii_zeroshot ++dry_run=True ++model_config.key="" ++model_config.model=openai/gpt-4-0314
  dt-run +privacy=pii_fewshot_protect ++dry_run=True ++model_config.key="" ++model_config.model=openai/gpt-4-0314
  dt-run +privacy=pii_fewshot_attack ++dry_run=True ++model_config.key="" ++model_config.model=openai/gpt-3.5-turbo-0301 

  dt-run +privacy=understanding_q1 ++dry_run=True ++model_config.key="" ++model_config.model=openai/gpt-4-0314
  dt-run +privacy=understanding_q2 ++dry_run=True ++model_config.key="" ++model_config.model=openai/gpt-3.5-turbo-0301 
  dt-run +privacy=understanding_q3 ++dry_run=True ++model_config.key="" ++model_config.model=openai/gpt-3.5-turbo-0301 

  # OOD EVALUATIONS

  dt-run +ood=style \
    ++model=openai/gpt-3.5-turbo-0301 \
    ++key=YourOpenAIKey \
    ++oods.out_file=data/ood/results/gpt-3.5-turbo-0301/style.json
  dt-run +ood=knowledge_standard \
    ++model=openai/gpt-3.5-turbo-0301 \
    ++key=YourOpenAIKey \
    ++oods.out_file=data/ood/results/gpt-3.5-turbo-0301/knowledge_standard.json
  dt-run +ood=knowledge_standard \
    ++model=openai/gpt-3.5-turbo-0301 \
    ++key=YourOpenAIKey \
    ++oods.out_file=data/ood/results/gpt-3.5-turbo-0301/knowledge_idk.json
  dt-run +ood=style_8shot \
    ++model=openai/gpt-3.5-turbo-0301 \
    ++key=YourOpenAIKey \
    ++oods.out_file=data/ood/results/gpt-3.5-turbo-0301/style_8shot.json
  dt-run +ood=knowledge_2020_5shot \
    ++model=openai/gpt-3.5-turbo-0301 \
    ++key=YourOpenAIKey \
    ++oods.out_file=data/ood/results/gpt-3.5-turbo-0301/knowledge_2020_5shot.json

  # MACHINE ETHICS

  dt-run +machine_ethics=ethics_commonsense_short ++dry_run=True \
    ++model=openai/gpt-3.5-turbo-0301

  dt-run +machine_ethics=ethics_commonsense_short ++dry_run=True \
    ++model=openai/gpt-3.5-turbo-0301 \
    ++machine_ethics.few_shot_num=32
  
  dt-run +machine_ethics=ethics_commonsense_long ++dry_run=True \
    ++model=openai/gpt-3.5-turbo-0301

  dt-run +machine_ethics=ethics_commonsense_long ++dry_run=True \
    ++model=openai/gpt-3.5-turbo-0301 \
    ++machine_ethics.few_shot_num=8

  dt-run +machine_ethics=jiminy ++dry_run=True \
    ++model=openai/gpt-3.5-turbo-0301

  dt-run +machine_ethics=jiminy ++dry_run=True \
    ++model=openai/gpt-3.5-turbo-0301 \
    ++machine_ethics.few_shot_num=3

  for i in {1..5}; do
  dt-run +machine_ethics=ethics_commonsense_short ++dry_run=True \
      ++model=openai/gpt-3.5-turbo-0301 \
      ++machine_ethics.test_num=200 \
      ++machine_ethics.jailbreak_prompt=${i}
  done

  for i in {1..5}; do
  dt-run +machine_ethics=jiminy ++dry_run=True \
      ++model=openai/gpt-3.5-turbo-0301 \
      ++machine_ethics.test_num=200 \
      ++machine_ethics.jailbreak_prompt=${i}
  done

  dt-run +machine_ethics=jiminy_conditional_harm_self ++dry_run=True \
    ++model=openai/gpt-3.5-turbo-0301

  dt-run +machine_ethics=jiminy_conditional_harm_others ++dry_run=True \
    ++model=openai/gpt-3.5-turbo-0301

  dt-run +machine_ethics=jiminy_conditional_minor_harm ++dry_run=True \
    ++model=openai/gpt-3.5-turbo-0301

  dt-run +machine_ethics=jiminy_conditional_moderate_harm ++dry_run=True \
    ++model=openai/gpt-3.5-turbo-0301

  # FAIRNESS

  dt-run ++model=openai/gpt-3.5-turbo-0301 ++dry_run=True ++key=''  +fairness=zero_shot_br_0.0.yaml

  dt-run ++model=openai/gpt-3.5-turbo-0301 ++dry_run=True ++key=''  +fairness=zero_shot_br_0.5.yaml

  dt-run ++model=openai/gpt-3.5-turbo-0301 ++dry_run=True ++key=''  +fairness=zero_shot_br_1.0.yaml

  dt-run ++model=openai/gpt-3.5-turbo-0301 ++dry_run=True ++key=''  +fairness=few_shot_tr_br_0.0.yaml

  dt-run ++model=openai/gpt-3.5-turbo-0301 ++dry_run=True ++key=''  +fairness=few_shot_tr_br_0.5.yaml

  dt-run ++model=openai/gpt-3.5-turbo-0301 ++dry_run=True ++key=''  +fairness=few_shot_tr_br_1.0.yaml

  dt-run ++model=openai/gpt-3.5-turbo-0301 ++dry_run=True ++key=''  +fairness=few_shot_16_fair_demon.yaml

  dt-run ++model=openai/gpt-3.5-turbo-0301 ++dry_run=True ++key=''  +fairness=few_shot_32_fair_demon.yaml


  datasets=("snli_premise" "snli_hypothesis" "control_raising" "irregular_form" "main_verb" "syntactic_category")
  seeds=(42 2333 10007)

  for dataset in "${datasets[@]}"
  do
    for seed in "${seeds[@]}"
    do
      dt-run +adv_demonstration=counterfactual_${dataset}_cf ++model=gpt-3.5-turbo-0301 ++key=<api-key> seed=$seed
      dt-run +adv_demonstration=counterfactual_${dataset} ++model=gpt-3.5-turbo-0301 ++key=<api-key> seed=$seed
      dt-run +adv_demonstration=counterfactual_${dataset}_cf ++model=gpt-3.5-turbo-0301 ++key=<api-key> adv_demonstration.only=True seed=$seed
      dt-run +adv_demonstration=counterfactual_${dataset} ++model=gpt-3.5-turbo-0301 ++key=<api-key> adv_demonstration.zero=True seed=$seed
    done
  done

  heuristics=("PP" "adverb" "embedded_under_verb" "l_relative_clause" "passive" "s_relative_clause")
  seeds=(0 42 2333 10007 12306)

  for heuristic in "${heuristics[@]}"
  do
    for seed in "${seeds[@]}"
    do
      dt-run +adv_demonstration=spurious_${heuristic}_zero ++model=gpt-3.5-turbo-0301 ++key=<api-key> seed=$seed
      dt-run +adv_demonstration=spurious_${heuristic}_entail-bias ++model=gpt-3.5-turbo-0301 ++key=<api-key> seed=$seed
      dt-run +adv_demonstration=spurious_${heuristic}_non-entail-bias ++model=gpt-3.5-turbo-0301 ++key=<api-key> seed=$seed
    done 
  done

  methods=("badword" "addsent" "synbkd" "stylebkd") 
  setups=("setup1" "setup2" "setup3")
  seeds=(42 2333 10007)

  for method in "${methods[@]}"
  do
    for setup in "${setups[@]}"
    do
      for seed in "${seeds[@]}"
      do
        dt-run +adv_demonstration=backdoor_exp1_${method}_${setup} ++model=gpt-3.5-turbo-0301 ++key=<api-key> seed=$seed
      done
    done
  done

  seeds=(42 2333 10007)
  for seed in "${seeds[@]}"
  do
    dt-run +adv_demonstration=backdoor adv_demonstration.path=./data/adv_demonstration/backdoor/experiment2/sst-2_setup2_badword_1 ++model=gpt-3.5-turbo-0301 ++key=<api-key> seed=$seed
    dt-run +adv_demonstration=backdoor adv_demonstration.path=./data/adv_demonstration/backdoor/experiment2/sst-2_setup2_badword_0 ++model=gpt-3.5-turbo-0301 ++key=<api-key> seed=$seed
  done

  setups=("setup2" "setup3") 
  locations=("first" "end" "middle")
  seeds=(42 2333 10007)

  for setup in "${setups[@]}"
  do
    for location in "${locations[@]}"
    do
      for seed in "${seeds[@]}"
      do  
        dt-run +adv_demonstration=backdoor adv_demonstration.path=./data/adv_demonstration/backdoor/experiment3/${setup}_cf_${location} ++model=gpt-3.5-turbo-0301 ++key=<api-key> seed=$seed
      done
    done
  done

  seeds=(42 2333 10007)
  for seed in "${seeds[@]}"
  do
    dt-run +adv_demonstration=backdoor_exp1_badword_setup1 ++model=gpt-3.5-turbo-0301 ++key=<api-key> adv_demonstration.task=badword seed=$seed
  done
  
  # echo "Finished evaluations for model: $model" | tee -a "$output_file"
  # echo "------------------------------------" | tee -a "$output_file"
done