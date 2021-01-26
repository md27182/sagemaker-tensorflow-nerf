# Lightbox Sagemaker set up repo
Notebook instance for use with SageMaker; intended for processing nerfs using the original tensorflow-based code

## Quickstart ##

Create new notebook instance in SageMaker with the following options:

| Property                | Value                                     | 
| ---                     | ---                                       |
| Notebook instance type  | ml.p2.xlarge                              |
| Lifecycle configuration | lifecycle-setup-tflow-nerf-on-start-only  |
| Volume size in GB       | 61                                        | 
| Git repository          | sagemaker-tensorflow-nerf - GitHub        |

Any options not listed above should be left at their default values.

Once you've started the instance, create a new terminal, navigate to this repo, and type
~~~
bash create-nerf-conda-env.sh
~~~
This could take up to 10 minutes to run. Once it's finished, refresh the jupyter page and you should see a new conda environment called "Custom (NERF)". This new environment is permanently installed and should persist when you stop/start the instance.

## Notes / Learnings ##
### Lifecycle scripts ###
When the on-create script involves installing a large number of libraries, it is best to move that to a bash script and run it manually - otherwise the lifecycle script may timeout after 5 minutes. In our case that bash script is "create-nerf-conda-env.sh".

Our bash script, as well as this [best-practices on-create lifecycle script](https://github.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples/blob/master/scripts/persistent-conda-ebs/on-create.sh), creates a separate conda installation in "custom-miniconda/miniconda". This is the installation that gets used when you want to use the custom nerf environment. If you simply open up a fresh terminal and type
~~~
source activate nerf
~~~
it wont work because it's looking for the nerf environment in the main Anaconda installation, not the secondary one we created. In order to fire up the nerf environment from the terminal we need to use
~~~
source ~/SageMaker/custom-miniconda/miniconda/bin/activate
source activate nerf
~~~

To create the on-start lifecycle script included in the configuration "lifecycle-setup-tflow-nerf-on-start-only", I modified this [best-practices on-start script](https://github.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples/blob/master/scripts/persistent-conda-ebs/on-start.sh) to check to see if the bash script above has been run yet. If not, it does nothing to avoid errors when starting the instance for the first time.
