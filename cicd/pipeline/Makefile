region=eu-north-1
infra-pipeline-stack-name=joneteus-spring-petclinic-cicd

deploy-infra-pipeline:
		@aws cloudformation deploy \
			--region $(region) \
			--stack-name $(infra-pipeline-stack-name) \
			--template-file cf_infra_pipeline.yaml \
			--capabilities CAPABILITY_NAMED_IAM
