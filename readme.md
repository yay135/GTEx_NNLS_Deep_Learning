# Project Deep Learning NNLS Tissue Deconvolution

## 1. Data availability
Datasets are partially released for confidentiality reasons. You can directly download the data and models using this link:
https://drive.google.com/file/d/163WrkVO9-WS7i4U4xdvLRl7QeAkSdm5s/view?usp=sharing  

Note: Do not download the data into the project root folder, it will cause the following run steps to freeze.

## 2. How to use this repo
### 2.1 System requirements
You must have at least 20GB free disk space, at least 8GB RAM and a dual core CPU.
A Windows or Linux or Mac OS system that is compatible with the lastest docker engine.

### 2.2 Download and install docker
Why use docker? docker allows us to distribute softwares consistently across all platforms. Check out this link on how to install docker on your machine.
https://docs.docker.com/engine/install/  
We recommend installing docker desktop for simplicity.

Note: after docker is installed, the commands bellow can be used across platforms such as Windows, Linux ans Max OS.

### 2.3 Clone the current project
Run the following command to clone the project  
``git clone https://github.com/yay135/GTEx_NNLS_Deep_Learning``  
### 2.4 Build a docker image 
Change the directory to the project root folder  
``cd GTEx_NNLS_Deep_Learning``  
Run the docker build command  
``docker build -t gtex_nnls_deep .``  
Note: building the docker image will download the data and models for you automatically.  

### 2.5 Prepare your data
#### 2.5.1 Data folder
Create an empty data folder and move all the csv files that you want to run tasks with into this folder. Refer to the sample csv files in the test folder to format your own file. Your data folder can be anywhere in your local machine.

#### 2.5.2 Data types
Note: Make sure your csv files have gene ensembl id without version as the headers. The expression data must be RNA-seq TPM normalized. Do not make further normalizations, the program has built in log2 transformation and min-max scaling functions.

#### 2.5.3 Data shapes
Note: Do not mix files for different tasks, the columns of your files can be different to the sample test file, the program will match as much columns as possible, the missing ones will be filled with 0. Each file may have different of columns. Each column is a gene, each row is a sample. 



Let's assume your task ready csv files are gathered in folder "test"  
### cd into your data folder:
``cd test``  

### 2.6 Run a deconvolution task
``docker run --env RUN_TYPE=deconvolute --rm -v .:/app gtex_nnls_deep``  
Here "test" is the folder where your deconvolution task files are gathered. RUN_TYPE=deconvolute specifies the task you are running, it can be either RUN_TYPE=deconvolute or RUN_TYPE=single_t
### 2.7 Run a single-tissue-type prediction task
``docker run --env RUN_TYPE=single_t --rm -v .:/app gtex_nnls_deep``  
### 2.8 Run a customized task with customized data folder
cd into your data folder first  
``cd [path/to/data]``  
Run the desired task  
``docker run --env RUN_TYPE=[single_t|deconvolute] --rm -v .:/app gtex_nnls_deep``  
Replace the task parameters and data folder parameters for your own usage.
### 2.9 Output
For deconvolution task, the output files are created in the same folder, each new file has a prefix added to the front such as "deconvolute_[csv file name].csv"  

For single-tissue-type prediction task, the output files are created in the same folder, each new file has a prefix added to the front such as "tissue_type_[csv file name].csv"  

## Team
Fengyao Yan fxy134@miami.edu 