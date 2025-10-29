# Project Deep Learning NNLS Tissue Deconvolution
## 1. Introduction
This project allows you to deconvolute tissue types from RNA-seq expression data by leveraging a pretrained deep neural network.
The nueral network is extensively trained using GTEx datasets v8.
We also include other functions such deep-learning single tissue type prediction and tissue type deconvolution using NNLS.
15 different tissue type deconvolutions are included in this project, refer to section 3.5.4 for more details. 
The neural network is trained using TSG genes, in total, 6500 TSG genes are selected as the features of training. To get the TSG genes used in our traininig refer to the sample data in the test folder. 


## 2. Data and model availability
Datasets are partially released for confidentiality reasons. You can directly download the data and models using this link:
https://drive.google.com/file/d/163WrkVO9-WS7i4U4xdvLRl7QeAkSdm5s/view?usp=sharing  


## 3. How to use this repo
### 3.1 System requirements
You must have at least 20GB free disk space, at least 8GB RAM and a dual core CPU.
A Windows or Linux or Mac OS system that is compatible with the lastest docker engine.

### 3.2 Download and install docker
Why use docker? docker allows us to distribute softwares consistently across all platforms. Check out this link on how to install docker on your machine.
https://docs.docker.com/engine/install/  
We recommend installing docker desktop for simplicity.

Note: after docker is installed, the commands bellow can be used across platforms such as Windows, Linux and Mac OS.

### 3.3 Clone the current project
Run the following command to clone the project.  
``git clone https://github.com/yay135/GTEx_NNLS_Deep_Learning``  

Download data.7z using the link in section2 and copy data.7z to he cloned project folder.  
### 3.4 Build a docker image 
Change the directory to the project root folder.  
``cd GTEx_NNLS_Deep_Learning``  

Run the docker build command.  
``docker build -t gtex_nnls_deep .``  

Note: building the docker image will download the data and models for you automatically. The build process might take 5-10 minutes depending on your network speed and available processing power.

### 3.5 Prepare your data
#### 3.5.1 Data folder
Create an empty data folder and move all the csv files that you want to run tasks with into this folder. Refer to the sample csv files in the test folder to format your own file. Your data folder can be anywhere in your local machine.

#### 3.5.2 Data types
Make sure your csv files have gene ensembl id without version as the headers. The expression data must be RNA-seq TPM normalized. Do not make further normalizations, the program has built in log2 transformation and min-max scaling functions.

#### 3.5.3 Data shapes
Do not mix files for different tasks, the columns of your files can be different to the sample test file, the program will match as many columns as possible, the missing ones will be filled with 0. Files in your data folder may have different columns. Each column is a gene, each row is a sample. 
The models favor csv files with more matched TSG genes.

#### 3.5.4 Output tissue types
The following tissue types are included in the output:
"Brain","Breast","Colon","Esophagus","Kidney","Liver","Lung","Ovary","Pancreas","Prostate","Skin","Small Intestine","Stomach","Thyroid","Uterus"

### 3.6 Example tasks on Linux

#### 3.6.1 cd into your data folder:
The test folder already contains some test csv files, you can use these data to test the build or you can create your own data folder.
Let's assume your task ready csv files are gathered in folder "test".  
``cd test``  

#### 3.6.2 Run a deep learning tissue deconvolution task
``docker run --env RUN_TYPE=deconvolute_deep --rm -v "$(pwd)":/app gtex_nnls_deep``  
RUN_TYPE=deconvolute specifies the task you are running, it can be either RUN_TYPE=deconvolute or RUN_TYPE=single_t.
#### 3.6.3 Run a NNLS tissue deconvolution task
``docker run --env RUN_TYPE=deconvolute_nnls --rm -v "$(pwd)":/app gtex_nnls_deep``  
#### 3.6.3 Run a deep learning single-tissue-type prediction task
``docker run --env RUN_TYPE=single_t --rm -v "$(pwd)":/app gtex_nnls_deep``    
#### 3.6.4 Run a customized task with customized data folder
cd into your data folder first.  
``cd [path/to/data]``  

Run the desired task.  
``docker run --env RUN_TYPE=[single_t|deconvolute_deep|deconvolute_nnls] --rm -v "$(pwd)":/app gtex_nnls_deep``  

Replace the RUN_TYPE parameters and data folder parameters for your own usage.
### 3.10 Output
The output files will be in the same folder as your csv data files with added prefix.
For deconvolution task, each new file has a prefix added to the front such as "deconvolute_[csv file name].csv".
For single-tissue-type prediction task, each new file has a prefix added to the front such as "tissue_type_[csv file name].csv".

## Team
Fengyao Yan fxy134@miami.edu 