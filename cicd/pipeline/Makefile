region=eu-north-1
infra-pipeline-stack-name=joneteus-spring-petclinic-infra-pipeline
app-pipeline-stack-name=joneteus-spring-petclinic-app-pipeline

deploy-infra-pipeline:
		@aws cloudformation deploy \
			--region $(region) \
			--stack-name $(infra-pipeline-stack-name) \
			--template-file cf_infra_pipeline.yaml \
			--capabilities CAPABILITY_NAMED_IAM

deploy-app-pipeline:
		@aws cloudformation deploy \
			--region $(region) \
			--stack-name $(app-pipeline-stack-name) \
			--template-file cf_app_pipeline.yaml \
			--capabilities CAPABILITY_NAMED_IAM
