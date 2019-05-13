# Welcome to the A1 Instance Workshop!

## Prerequisites: <a name="prerequisites"></a>
  - A 12-digit code (aka "hash") provided to you by the workshop instructor.
  
  - A laptop computer running Windows, OSX, or Linux

  - A Remote Desktop Services client.
    - If you are running Windows, you will already have one installed.
    - If you have a Mac, you may need to install a client. You can download the Microsoft Remote Desktop Services client by clicking
    [here](https://itunes.apple.com/us/app/microsoft-remote-desktop-10/id1295203466)
    (or navigate to
    <https://itunes.apple.com/us/app/microsoft-remote-desktop-10/id1295203466>).
    - If you are running a Linux distribution, you may need to install a client using your Linux distribution's package manager.

# Instructions
For this workshop, we have provided a temporary AWS account that you will use to explore how you can migrate an existing ASP.NET Core Web Application from Windows running on x86_64 EC2 instances against a SQL Server database, to Linux running on the new Graviton ARM64 instances against an Amazon Aurora database.

## Connecting to your team dashboard
Let's get started! Login to the team dashboard at the following URL:
    https://dashboard.eventengine.run/login

You will be prompted to enter a 12-character hash code for your team; this will be on the card provided to you at the beginning of the workshop.

Once you enter your hash code and click Proceed, you will be presented with your team dashboard. Click the "AWS Console" button to navigate to the credentials page for your account.

![](https://s3.amazonaws.com/andyhopp-content/Conferences/2019/DotNetSouth/Launch+the+AWS+Console.png)

## Logging into the AWS Console
You will see a section entitled "login link" with a button labeled "Open Console." Click this button to open your account's console.

![](https://s3.amazonaws.com/andyhopp-content/Images/Open+Console.png)

This will bring you to the AWS Console for your temporary account. Take a moment to familiarize yourself with this page; from here, you can navigate to one of the over 165 services AWS offers.

<div style="text-align:center;border:thin solid red;background-color:lightgray;color:black">
NOTE: For the purposes of this workshop, we have purposefully limited access to only the services needed. You may encounter error messages if you navigate to services other than those used for this workshop.
</div>

![](https://s3.amazonaws.com/andyhopp-content/Images/AWS+Console.png)

## Opening the CloudFormation dashboard
We are using the CloudFormation service to automatically provision the AWS resources that you will be using for this workshop. CloudFormation allows you to create documents known as `Templates` which describe the AWS resources you would like to provision, along with any configuration data for those resources. When you supply a template to CloudFormation, it will create a `Stack` that contains the resources. We will be using CloudFormation again later on in this workshop, but for now, let's examine the stack we created for you.

In the "Find Services" search bar, enter "CloudFormation" and click the link that appears below the search bar.

![](https://s3.amazonaws.com/andyhopp-content/Images/Search+for+Cloudformation.png)

This will bring you to the CloudFormation dashboard.

## Viewing the outputs of our stack
There will be multiple stacks listed in CloudFormation, but only one named "module-XXXXXXX" (Note: this is simply the name generated by our workshop's provisioning tool; you can provide the name for a stack when you create your own). To the right of the stack, you will see a tabbed details view. The tabs contain information regarding the stack, the events that occurred during the stack's lifecyle, the resources that were created by the stack, and any outputs that the stack returns. In our case, we're interested in the outputs, so click the `Outputs` tab.

![](https://s3.amazonaws.com/andyhopp-content/Images/Outputs+tab.png)

### Set up Workshop Prerequisites

One of the output parameters in this list will contain the URL for our Cloud9 IDE (Cloud9Url). Click this link to open the IDE. It will take a moment to load and initialize your environment. In the Cloud9 'Terminal' window on the lower-right, run the following commands:

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

The initial version is built for the Windows operating system running on Intel x86_64 processors using SQL Server as the database engine. Let's connect to the Web application using the URL for the load balancer created by the stack. 

Navigate back to the CloudFormation Outputs tab. The name of the output parameter containing the URL is `AlbUrlForx86`, and we can access the site by clicking the hyperlink.

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

        1. Navigate back to the CloudFormation stack's Outputs tab, and click the hyperlink next to the `CodePipelineUrl` output parameter.

        1. On the CodePipeline's dashboard, click the `Release Change` button to start a new build, and confirm your decision by clicking the `Release` button on the pop-up dialog that appears.  

        1. Wait for the Source and Build stages to complete.

    1. Check on the deployment process.
        
        The build process takes roughly 5 minutes to complete. After the build completes, a CodeDeploy deployment is started on our Arm instances. You can view the progress of this deployment by navigating to the CodeDeploy console by opening the CloudFormation stack's `Outputs` tab and clicking the URL for the `CodeDeployApplcationUrl` output parameter.
        You'll see the deployment group ending in "-arm64" change to `SUCCEEDED` when it's finished. 

    1. View the application running on Arm:

        After the deployment completes, we can navigate to the Web application by returning to the CloudFormation stack's `Outputs` tab and clicking the URL for the `AlbUrlForArm64` output parameter.

        If you scroll to the bottom of the home page, you will see a line that indicates the new CPU architecture _(now Arm64)_ and database engine _(still SQL Server)._
    
We now have our .NET Core application running on Arm, on EC2 A1 instances powered by the AWS Graviton Processor. 

Next, we'll migrate off of SQL Server onto Amazon Aurora.

### Changing our Database Engine to Aurora

#### Remote into the AWS SCT Instance
Next, we'll use the Schema Conversion Tool to convert our SQL Server schema into Aurora.

Navigate back to the CloudFormation Outputs tab. There will be an output parameter named "" that contains the name of a Systems Manager parameter that contains the random password that was generated for our Visual Studio instance. Systems Manager is an AWS Service that allows you to manage, patch, and store configuration parameters for EC2 instances and other AWS resources. In this case, we're using the `Parameter Store` feature to store the generated password.

## View our Systems Manager parameter

<div style="text-align:center;border:thin solid red;background-color:lightgray;color:black">
NOTE: For the purposes of this workshop, we are storing the password as plaintext. This is NOT considered to be a best practice; in a production environment, you would either store this as an encrypted ("secure") string with restricted permissions for decryption, use an RSA keypair, or join the machine to an Active Directory domain.
</div>

Let's open the Systems Manager console to retrieve our password. Click the "Services" drop-down on the upper-left of your AWS Console. This will open a search pane. In the search box, enter "systems manager" and click the Systems Manager entry in the results. 
<div style="text-align:center;border:thin solid green">
Pro tip: we will be returning to the CloudFormation Outputs tab in a moment; if you hold the Control key (Windows) or the Command key (Mac), you will open Systems Manager in a new tab so we don't lose our place.
</div>

![](https://s3.amazonaws.com/andyhopp-content/Images/Search+for+Systems+Manager.png)

This will open the Systems Manager dashboard. In the left-hand pane, select "Parameter Store" to navigate to the parameters (you may need to scroll down).

![](https://s3.amazonaws.com/andyhopp-content/Images/Select+Parameter+Store.png)

with a name ending in "SCTPassword". Click the parameter to view it, and copy the password to a temporary file for future reference.

![View the parameter details](https://s3.amazonaws.com/andyhopp-content/Images/Click+on+Parameter.png)

![Copy the password](https://s3.amazonaws.com/andyhopp-content/Images/Copy+password.png)

## Connecting to our EC2 instance
Now it's time to connect to the EC2 instance. We have provisioned an EC2 instance running Windows Server 2019 for this workshop, and we have installed Visual Studio 2019 Community edition for you. Let's return to the CloudFormation Outputs tab for our stack by either returning to that browser tab or by searching for CloudFormation service from the Services drop-down and clicking the Outputs tab again. Copy the value for the `SchemaConversionToolInstanceName` parameter; this is the DNS name for the EC2 instance. Use your Remote Desktop Services client (see [Prerequisites](#prerequisites) above) to connect to this instance at this address. The username for the instance will be "Administrator" and the password will be the value copied from the Systems Manager parameter above.

#### Install JDBC Drivers

Unfortunately for legal reasons we are not allowed to pre-install the drivers for you. Only install the drivers needed for your lab though the document lists several more.

You will need to install both SQL Server and MySQL drivers in order to connect to your source and target databases. 

Instructions are on the desktop in the file "JDBC Driver Install Instructions." Follow these instructions to download and install the drivers.

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
 Microsoft SQL Server driver path: C:\JDBC Drivers\Microsoft JDBC Driver 7.0 for SQL Server\sqljdbc_7.0\enu\mssql-jdbc-7.0.0.jre8.jar
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
 MySQL driver path: C:\JDBC Drivers\MySQL\mysql-connector-java-8.XX.XX.jar (the X-es will be replaced with version numbers)
```

Click "Test connection" _(in the lower left corner of the dialog)_

Click "Finish"

_(Ignore any warnings about SQL version recommendations, if one appears.)_

#### Import the Transform Rules

Launch PowerShell from the Taskbar of the Windows instance.

Run the following commands (you may have to right-click to paste them in PowerShell):

```
cd Downloads
curl https://s3.amazonaws.com/us-east-1.andyhoppatamazon.com/cloudformation/cpu-workshop/Drop-dbo-suffix.json -OutFile ~\Downloads\Drop-dbo-suffix.json
```
In SCT, Click the `Settings` menu, then `Mapping Rules`

Click `"Import script into SCT"` and navigate to the `Drop-dbo-suffix.json` file in your Downloads folder.

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
CPU Architecture: Arm64  Database Engine: Aurora
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
