# Hello and welcome to this workshop!

## Prerequisites:
  - A laptop computer running Windows, OSX, or Linux
  
  - An AWS Account with Administrator or AdminAccess privileges. We will provide Workshop Credits to apply to your account that will offset the charges incurred in the normal course of the workshop. 

  **IMPORTANT: At the end of the workshop, please follow the clean-up instructions to delete all of the resources created during the workshop, or else you will be charged significantly more than Workshop Credits will cover!**

  - A Remote Desktop Services client.
    - If you are running Windows, you will already have one installed.
    - If you have a Mac, you may need to install a client. You can download the Microsoft Remote Desktop Services client by clicking
    [here](https://itunes.apple.com/us/app/microsoft-remote-desktop-10/id1295203466)
    (or navigate to
    <https://itunes.apple.com/us/app/microsoft-remote-desktop-10/id1295203466>).
    - If you are running a Linux distribution, you may need to install a client using your Linux distribution's package manager.
  
  - The .pem file for an EC2 keypair that will be used for connecting to your EC2 instances. If you do not have a keypair already created, or you cannot find the .pem file, you can follow the instructions for creating one here: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html (under the section entitled _"Creating a Key Pair"_)

We will explore how to create and run a standard 3-tier Web App on both x86 and Arm processors. 

## Instructions

### Create the AWS Environment

This section walks you through the creating the workshop environment using [AWS Cloud9](https://aws.awazon.com/cloud9).

This workshop provides you with a complete CI/CD pipeline including a cloud-based integrated development environment (IDE) that will let you write, run, and test workloads using just a web browser.

1. We can create our development and test environments via CloudFormation.
This CloudFormation template will create a Cloud9 IDE, as well as configure the AWS environment for the rest of the workshop. Click the below _"Deploy to AWS"_ button to create this stack.

| Region | Launch template with a new VPC | 
| -------| ------- |
| **N. Virginia** (us-east-1) | [Deploy to AWS](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/new?stackName=cpu-workshop&templateURL=https://s3.amazonaws.com/us-east-1.andyhoppatamazon.com/cloudformation/cpu-workshop/master-template.yaml) |

1. Click the `Next` button to open the `Specify stack details` screen. The name will already be populated with "cpu-workshop," and should not be changed.
1. Choose a keypair for the Schema Conversion Tool (SCT) Instance. We will use this key to connect to the SCT EC2 instance later in this workshop.
1. Click the `Next` button.
1. On the "Configure stack options" screen, accept the default values by clicking the `Next` button again.
1. On the "Review `<stack name>`" view, scroll to the bottom and check the following checkboxes in the "Capabilities and transforms" section:
   
    * I acknowledge that AWS CloudFormation might create IAM resources.
    * I acknowledge that AWS CloudFormation might create IAM resources with custom names.
    * I acknowledge that AWS CloudFormation might require the following capability: CAPABILITY_AUTO_EXPAND
1. Click the "Create Stack" button to launch the stack. This process should take approximately 15 minutes. You can check the progress of the launch process by clicking your stack's name and choosing the `Events` tab.

When all the stacks show _CREATE COMPLETE_, click on the 'Outputs' tab in the Cloudformation UI to get the URL for the Cloud9 IDE.

Take a few minutes to familiarize yourself with the Cloud9 interface.

Most of the commands will be run in the 'Terminal' window, while most of the file editing will be done in the frame above.

### Set up Workshop Prerequisites

In the Cloud9 'Terminal' window, run the following commands:

```
cd /home/ec2-user/environment/workshop/
sh install-dotnet-2.2.sh
```

This will install a number of tools we will use for the rest of the workshop. 

After it completes, we will need to refresh the path variable for our current session by running the below command:

```
source ~/.bash_profile
```

### Viewing our Windows-based Web Application

After our CloudFormation stack has launched, the latest version of our code will be deployed. 

The initial version is built for the Windows operating system running on Intel x86_64 processors using SQL Server as the database engine. 

Let's connect to the Web application using the URL for the load balancer created by the stack. 

You can find the URL to use by navigating to the details for our `cpu-workshop` CloudFormation stack and clicking the `Outputs` tab. 

The name of the output parameter containing the URL is `AlbUrlForx86`, and we can access the site by clicking the hyperlink.

If you scroll to the bottom of the home page, you will see a line that indicates the CPU architecture _(currently x64)_ and database engine _(currently SQL Server)_.

### Changing the CPU Architecture to Arm

For this workshop, we're developing our application using .NET Core, which supports compilation for a number of operating systems and CPU architectures. 

Our build process reads a parameter from the Systems Manager Parameter store to determine which platform to target during builds. 

This parameter will use a name that is prefixed with our CloudFormation stack name (e.g. `/cpu-workshop`) and uses the name `platform-architecture`.

1. Let's see the current value for this parameter by running the following command from our Cloud9 IDE's terminal window:

    ```
    aws ssm get-parameter --name="/cpu-workshop/platform-architecture" --query="Parameter.Value" --output=text
    ```

    You will see a value of 

    ```
    win-x64
    ```

1. Let's change our applicaton to run on Linux on Arm - using EC2 A1 instances powered by the AWS Graviton Processor - by changing the value of this parameter and starting a new build:

   1. Change to the Linux/Arm platform by changing the parameter's value to `linux-arm64` by running the below command in the Cloud9 IDE's terminal window:
   
   ```
   aws ssm put-parameter --name="/cpu-workshop/platform-architecture" --type String --overwrite --value="linux-arm64"
   ```
   
   If successful, you should see something similar to the following: 
   ```
   {
    "Version": 2
   }
   ```

   1. Start a new build.

        1. Navigate to the CloudFormaton stack's Outputs tab, and click the hyperlink next to the `CodePipelineUrl` output parameter.

        1. On the CodePipeline's dashboard, click the `Release Change` button to start a new build, and confirm your decision by clicking the `Release` button on the pop-up dialog that appears.  

        1. Wait for the Source and Build stages to complete.

    1. Check on the deployment process.
        
        The build process takes roughly 5 minutes to complete. After the build completes, a CodeDeploy deployment is started on our Arm instances. You can view the progress of this deployment by navigating to the CodeDeploy console by opening the CloudFormation stack's `Outputs` tab and clicking the URL for the `CodeDeployApplcationUrl` output parameter.
        You'll see the deployment group ending in "-amr64" change to `SUCCEEDED` when it's finished. 

    1. View the application running on Arm:

        After the deployment completes, we can navigate to the Web application by returning to the CloudFormation stack's `Outputs` tab and clicking the URL for the `AlbUrlForArm64` output parameter.

        If you scroll to the bottom of the home page, you will see a line that indicates the new CPU architecture _(now Arm64)_ and database engine _(still SQL Server)._
    
We now have our .NET Core application running on Arm, on EC2 A1 instances powered by the AWS Graviton Processor. 

Next, we'll migrate off of SQL Server onto Amazon Aurora.

### Changing our Database Engine to Aurora

#### Remote into the AWS SCT Instance
First, We'll use the Schema Conversion Tool to convert our SQL Server schema into Aurora.

In the CloudFormation `Outputs` tab, locate the `SchemaConversionToolInstanceUrl` output parameter and open that link in a new browser tab.

You should see the AWS EC2 Console.  Click the Connect button at the top of the instance lists.

Using the .pem file you indicated in the initial CloudFormation template launch, retrieve the Administrator Password for the SCT Instance, and copy it to your clipboard.

You can use the "Download Remote Desktop File" button to automatically download a RDP profile for the SCT Instance.

When prompted, paste in the password.

You are now remoted into a Windows instance in which we'll run the Schema Conversion Tool

#### Install JDBC Drivers

Unfortunately for legal reasons we are not allowed to pre-install the drivers for you. Only install the drivers needed for your lab though the document lists several more.

You will need to install both SQL Server and MySQL drivers in order to connect to your source and target databases. 

Instructions are on the desktop in the file "JDBC Driver Install Instructions"

Follow the instructions and install the appropriate drivers you need.

#### Launch the Schema Conversion Tool and Connect to the Databases

Before launching the SCT, go back to the CloudFormation Outputs tab and locate the `DBSqlServerAddress` and `DBAuroraAddress` output parameters.  
You'll need to copy-paste them into the SCT Wizard in future steps.

The icon for the Schema Conversion Tool is on your desktop - double click and launch it! 

_Note: We purposely installed a prior instance so you could see the prompt when a new version is available. Choose "Not Now" and launch the current instance._

Follow the wizard! 

Set your _"Source Database Engine"_ to `Microsoft SQL Server` 

Click "Next" and enter the following...

```
--> Choose your source database:
 Server Name: [Replace this with the DBSqlServerAddress CloudFormation Output Paramter]
 Port: 1433 
 Instance Name: [Leave Blank]
 User Name: awsadmin
 Password: Reind33rFl0tilla 
 Microsoft SQL Server driver path: C:\JDBC Drivers\SQLServer\mssql-jdbc-7.0.0.jre8.jar
```
Click "Test connection" _(in the lower left corner of the dialog)_

Click "Next"

Choose any of the schemas to analyze - we will override this selection manually later...

Click "Next" and then "Next" again.

Pull down the `Target Database Engine:` selector to `Amazon Aurora (MySQL Compatible)`

```
--> Choose your target database
 Server Name: [Replace this with the DBAuroraAddress CloudFormation Output Paramter] 
 Port: 3306 
 User Name: awsadmin
 Password: Reind33rFl0tilla 
 MySQL driver path: C:\JDBC Drivers\MySQL\mysql-connector-java-8.0.13.jar
```

Click "Test connection" _(in the lower left corner of the dialog)_

Click "Finish"

_(Ignore any warnings about SQL version recommendations, if one appears.)_

#### Import the Transform Rules

Launch Powershell from the Taskbar of the Windows instance.

Run the following commands (you may have to right-click to paste them in Powershell):

```
cd Downloads
curl https://s3.amazonaws.com/us-east-1.andyhoppatamazon.com/cloudformation/cpu-workshop/Drop-dbo-suffix.json -OutFile Drop-dbo-suffix.json
```
In SCT, Click the `Settings` menu, then `Mapping Rules`

Click `"Import script into SCT"` and navigate to JSON file in your Downloads folder.

Click `"Save to All"` and then `"Close"`

#### Convert the Schemas for the two databases

Expand CatalogDb and navigate down to "dbo." 

Right-click and choose "convert schema" - note the appearance of a new database in the right-hand (target) database named "CatalogDb" _(if the name ends in _dbo, the rules were not imported. Please repeat the "Import the Transform Rules" step above)_

Expand Identity and navigate down to "dbo." 

Right-click and choose "convert schema" - note the appearance of a new database in the right-hand (target) database named "Identity" _(if the name ends in _dbo, the rules were not imported. Please repeat the "Import the Transform Rules" step above)_

In the right-hand pane, right-click each of CatalogDb and Identity and choose `"Apply to database"`

Close / Disconnect from the Remote Desktop Connection Session.

#### Migrate the Database itself

1. Open the DMS console at https://console.aws.amazon.com/dms/v2/home?region=us-east-1#tasks. 

1. There will be two tasks named `<stack name>-load-catalog` and `<stack name>-load-identity`. 

1. Click the checkbox next to each of these, then click the Actions menu and choose `Restart/Resume`. 

1. Wait two minutes for the migration to complete successfully.

#### Change the DB engine for our application

Back in the Cloud9 IDE, navigate to appSettings.json _(workshop/src/Web/appSettings.json)_ and change "DatabaseEngine" to "Aurora" (case-sensitive!). 
Then press CTRL-S to save.

Type the following commands in the Cloud9 Terminal:
```
cd /home/ec2-user/environment/workshop
git add *
git status
```
You should see: _"modified: src/Web/appSettings.json"_ in green.

Now enter these commands:
```
git commit -a -m "Change DB Engine"
git push 
```

Navigate to the CloudFormaton stack's Outputs tab, and click the hyperlink next to the `CodePipelineUrl` output parameter.
(You may have this tab opened already - we visited it earlier)

Wait for CodePipeline to pick up the latest commit to the CodeCommit Repository, and for it to automatically trigger the "Source" and "Build" stages.

When the "Build" stage completes (it will take ~5 minutes or less), a CodeDeploy deployment is started on our Arm instances. 
You can view the progress of this deployment by navigating to the CodeDeploy console by opening the CloudFormation stack's `Outputs` tab and clicking the URL for the `CodeDeployApplcationUrl` output parameter. You'll see the deployment group ending in "-amr64" change to `SUCCEEDED` when it's finished. 

Lastly, locate once again the `AlbUrlForArm64` output parameter in the CloudFormation `Outputs` tab.  
Launch that URL and scroll to the bottom.
You should see:
```
CPU Architecure: Arm64  Database Engine: Aurora
```

**We've successfully migrated a .NET Core application from Windows/x86/SQL Server to Linux/Arm/Aurora !**

### Clean up

In the Cloud9 IDE, run the following command:

``` 
aws cloudformation delete-stack --stack-name="cpu-workshop"
```

Close the Cloud9 IDE browser tab.  

Open this link: https://console.aws.amazon.com/cloudformation/home?region=us-east-1 and make sure it shows `DELETE_IN_PROGRESS` for all stacks.

Refresh the CloudFormation stack list until the list of stacks is empty.  
Fully deleting the `cpu-workshop` stack may take some time; feel free to bookmark the page and check it later to make sure all the stacks are gone.

_In a rare corner case, you may get a `DELETE_FAILED` on the main `cpu-workshop` stack._
_If this happen click this link: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#NIC:sort=networkInterfaceId_
_Type `cpu-workshop` in the search field and delete any Network Interfaces that appear with that tag, then go back to the CloudFormation console and delete the stack again._

This concludes the workshop! Thank you!
