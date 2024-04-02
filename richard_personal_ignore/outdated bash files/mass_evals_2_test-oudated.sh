datasets=("snli_premise" "snli_hypothesis" "control_raising" "irregular_form" "main_verb" "syntactic_category")
seeds=(42 2333 10007)

for dataset in "${datasets[@]}"
do
  for seed in "${seeds[@]}"
  do
    dt-run +adv_demonstration=counterfactual_${dataset}_cf +seed=$seed
    dt-run +adv_demonstration=counterfactual_${dataset} +seed=$seed
    dt-run +adv_demonstration=counterfactual_${dataset}_cf adv_demonstration.only=True +seed=$seed
    dt-run +adv_demonstration=counterfactual_${dataset} adv_demonstration.only=True +seed=$seed
  done
done