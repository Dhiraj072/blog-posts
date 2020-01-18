So you built a [static](https://www.staticapps.org/articles/defining-static-web-apps/) react web app, and you want the world to see it. This post provides a step-by-step guide on deploying your static web app on Amazon S3 for free. 


For this tutorial, you will need 
* a basic understanding of react web apps, terraform and AWS S3
* an activated AWS account. If you don't have one yet, you can follow [instructions here](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/) to set it up
* an AWS IAM user with 
  * AWS API keys (Access Key ID and Secret Access Key) set up. You can follow instructions here to [setup](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html) and [configure](https://docs.aws.amazon.com/en_en/IAM/latest/UserGuide/id_credentials_access-keys.html) the IAM user.
  * Permissions to create/delete S3 buckets, add IAM policies
* [Terraform CLI](https://www.terraform.io/downloads.html) to set up our infrastructure on AWS
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv1.html) which has been [configured](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) with the IAM user API keys

AWS has a [free tier](https://aws.amazon.com/free/?all-free-tier.sort-by=item.additionalFields.SortRank&all-free-tier.sort-order=asc) so running the steps below should not cost you anything. In any case, make sure you [TERMINATE](#terminating-created-resources) all your resources after completing this tutorial to avoid any unwanted charges in your AWS account.

## Preparing the package
I presume you already have a static react web app which you want to deploy. If not, you can pull a sample web application from my repository. I will be writing this guide using the indecision-app below. It has been build using yarn and webpack, though the steps should be easily reproducible with other package managers (npm, gulp, etc.)
```
$ git clone https://github.com/Dhiraj072/indecision-app.git
```

Once you have the app, build a production package.
```
$ yarn webpack -p
```

This above command will create a <code>public/</code> directory inside your project folder, containing everything required to host your web application, including an <code>index.html</code>, <code>bundle.js</code>, etc.


## Setting up AWS infrastructure

We will write the terraform configuration file main.tf step-by-step in this section. This file tells terraform which AWS resources to instantiate, and their respective configuration. Full version of the file can be found [here](https://github.com/Dhiraj072/indecision-app/blob/master/main.tf).

* Create a blank main.tf file in your project dir

* Add below to our main.tf to tell terraform we are using AWS for our infrastructure
```tf
provider "aws" {
  # region you want your resource to be in
  region = "ap-southeast-1" 
}
```

* We store our terraform states locally for now, so add
```tf
terraform {
  backend = "local"
}
```

* To define local variables we will be using later on, add
```tf
locals {
  s3_origin_id = "myappS3Origin"
  app_name = "my_app"
}
```

* Finally, add the config to create the S3 bucket we want our app to be hosted in. This also sets the IAM policy to allow public read as we want everyone to be able to access our web app.
```tf
resource "aws_s3_bucket" "my_app" {
  bucket = "${local.app_name}" # S3 bucket name
  acl    = "public-read"
  website {
    index_document = "index.html" # our web app's entry point
  }
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowPublicReadAccess",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::${local.app_name}/*"
      ]
    }
  ]
}
POLICY
}
```
* Save your main.tf file

* Set the environment variable for terraform to be able to access AWS
```
$ export AWS_SECRET_ACCESS_KEY=<YOUR_AWS_SECRET_ACCESS_KEY>
$ export AWS_ACCESS_KEY_ID=<YOUR_AWS_ACCESS_KEY_ID>
```

* Initialize terraform
```
$ terraform init
```

* Spin up the AWS infra, type <code>y</code> when asked for confirmation
```
$ terraform apply
```

Terraform may take 5-10 minutes to spin everything up. Once complete, you can login to you AWS account and you should see you AWS bucket created.

Your AWS infrastructure is now ready to host your web application.

## Deploying the package
Finally, you can deploy the package we built earlier to S3 by running the following AWS CLI command in the project dir
```
$ aws s3 sync public/ s3://my_app
```

## Accessing deployed web app
You should be able to access the application at https://s3-ap-southeast-1.amazonaws.com/my_app/index.html. This is basically the <code>Object URL</code> of the <code>index.html</code> file inside our S3 bucket <code>my_app</code>.

## Terminating created resources
AWS has a [free tier](https://aws.amazon.com/free/?all-free-tier.sort-by=item.additionalFields.SortRank&all-free-tier.sort-order=asc) so running the steps in this tutorial should not cost you anything. In any case, do TERMINATE all your resources to avoid any unwanted charges by running the following command in your project dir
```
$ terraform destroy
```

